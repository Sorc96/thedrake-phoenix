defmodule DrakeWeb.PageController do
  use DrakeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
