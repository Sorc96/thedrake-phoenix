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
      troop = Tile.get_troop(tile)
      Routes.static_path(socket, image_for_troop(troop))
    else
      ""
    end
  end

  defp stack_image(socket, state, side) do
    case TroopStacks.peek(state.troops, side) do
      nil -> ""
      troop -> Routes.static_path(socket, image_for_troop({troop, :front, side}))
    end
  end

  defp image_for_troop({type, face, side}) do
    type_name =
      type
      |> Atom.to_string()
      |> String.capitalize()

    face_name = Atom.to_string(face)

    side_initial =
      side
      |> Atom.to_string()
      |> String.upcase()
      |> String.first()

    "/images/#{face_name}#{type_name}#{side_initial}.png"
  end
end
