defmodule MembraneExample do
  @moduledoc """
  MembraneExample keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  def go_live(name) do
    go_dead()
    {:ok, pid} = MembraneExample.LiveStream.start_link(name)
    MembraneExample.LiveStream.play(pid)
    pid
  end

  def go_dead do
    case Process.whereis(:livestream) do
      nil -> :already_gone
      pid ->
        MembraneExample.LiveStream.stop_and_terminate(pid)
        :ok
    end
  end
end
