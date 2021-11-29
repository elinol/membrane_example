defmodule MembraneExampleWeb.PageController do
  use MembraneExampleWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
