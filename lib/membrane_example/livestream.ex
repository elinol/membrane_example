defmodule MembraneExample.LiveStream do
  use Membrane.Pipeline

  require Logger

  alias Membrane.Element.Tee
  alias Membrane.Audiometer.Peakmeter
  alias Membrane.Element.Fake

  @port 5000

  @impl true
  def handle_init(name) do
    path = Path.join("priv/static/livestream", name)
    File.mkdir_p!(path)
    Process.register(self(), :livestream)
    children = %{
      rtmp_server: %Membrane.RTMP.Bin{port: @port},
      hls: %Membrane.HTTPAdaptiveStream.SinkBin{
        manifest_module: Membrane.HTTPAdaptiveStream.HLS,
        target_window_duration: :infinity,
        muxer_segment_duration: 5 |> Membrane.Time.seconds(),
        persist?: true,
        storage: %Membrane.HTTPAdaptiveStream.Storages.FileStorage{directory: path}
      }
    }

    links = [
      link(:rtmp_server)
      |> via_out(:audio)
      |> via_in(Pad.ref(:input, :audio), options: [encoding: :AAC])
      |> to(:hls),
      link(:rtmp_server)
      |> via_out(:video)
      |> via_in(Pad.ref(:input, :video), options: [encoding: :H264])
      |> to(:hls)
    ]

    spec = %ParentSpec{children: children, links: links}
    {{:ok, spec: spec}, %{name: name}}
  end

  @impl true
  def handle_notification({:track_playable, ref}, :hls, _, state) do
    started = state
    |> Map.get(:started, %{})
    |> Map.put(ref, true)

    if Enum.count(started) >= 2 do
      Phoenix.PubSub.broadcast!(MembraneExample.PubSub, "livestream:#{state.name}", :started)
    end

    {:ok, Map.put(state, :started, started)}
  end

  @impl true
  def handle_notification(:end_of_stream, :hls, _, state) do
    ended = Map.get(state, :ended, [])
    ended = [true | ended]

    if Enum.count(ended) >= 2 do
      Phoenix.PubSub.broadcast!(MembraneExample.PubSub, "livestream:#{state.name}", :ended)
    end

    {:ok, Map.put(state, :ended, ended)}
  end

  @impl true
  def handle_notification(msg, element, context, state) do
    {:ok, state}
  end
end
