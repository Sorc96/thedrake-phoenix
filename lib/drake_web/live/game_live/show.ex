defmodule DrakeWeb.GameLive.Show do
  alias Drake.{Board, Tile, TroopStacks}

  use DrakeWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, game: Drake.new(), selected: nil)}
  end

  @impl true
  def handle_event("click-tile", %{"x" => x, "y" => y}, socket) do
    position = {String.to_integer(x), String.to_integer(y)}

    {:noreply, assign(socket, :selected, position)}
  end

  def handle_event("click-stack", %{"side" => side}, socket) do
    {:noreply, assign(socket, :selected, side)}
  end

  defp captured_count(state, side) do
    count = TroopStacks.length(state.board.captured_troops, side)
    "Captured: #{count}"
  end

  defp tile_image(socket, state, position) do
    tile = Board.tile_at!(state.board, position)
    if Tile.has_troop?(tile) do
      Routes.static_path(socket, "/images/backArcherO.png")
    else
      ""
    end
  end
end
