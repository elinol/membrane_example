defmodule MembraneExampleWeb.LiveLive do
  use MembraneExampleWeb, :live_view

  @impl true
  def mount(%{"name" => name}, session, socket) do
    index_path = Path.join(["/livestream", name, "index.m3u8"])
    local_path = Path.join("priv/static/", index_path)
    started? = case File.stat(local_path) do
      {:ok, _} -> true
      _ -> false
    end
    Phoenix.PubSub.subscribe(MembraneExample.PubSub, "livestream:#{name}")
    {:ok, assign(socket,
                 name: name,
                 index_path: index_path,
                 type_body_tag: "video",
                 immersive?: true,
                 live?: false,
                 started?: started?
                 )}
  end

  @impl true
  def handle_info(:started, socket) do
    {:noreply, assign(socket, started?: true, live?: true)}
  end

  @impl true
  def handle_info(:ended, socket) do
    {:noreply, assign(socket, live?: false, started?: true)}
  end

  def render(assigns) do
  ~H"""
  <%= if @started? do %>
  <video id="video" phx-hook="LiveVideoAdded" data-path={Routes.static_path(@socket, @index_path)} controls class="max-h-screen max-w-screen mx-auto"></video>
  <%= if @live? do %>
  <div class="absolute bottom-2 right-2 color-u-pink">
  Live!
  </div>
  <% end %>
  <% else %>
  <p class="mt-8 w-1/2 mx-auto text-center">Nothing yet, please hold on...</p>
  <% end %>
  """
  end
end
