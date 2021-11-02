defmodule DrakeWeb.GameController do
  alias Drake.GameServer

  use DrakeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def join(conn, %{"game" => %{"identifier" => identifier}}) do
    case GameServer.find_game(identifier) do
      {:ok, _} ->
        DrakeWeb.Endpoint.broadcast(identifier, "join", nil)
        path = Routes.live_path(conn, DrakeWeb.GameLive.Show, identifier: identifier, side: "orange")
        redirect(conn, to: path)
      :error ->
        conn
        |> put_flash(:alert, "No game available for the given identifier.")
        |> redirect(to: Routes.game_path(conn, :index))
    end
  end
end
