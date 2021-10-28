defmodule DrakeWeb.GameLive.Show do
  alias Drake.{Board, Tile, TroopStacks, GameState, PlayingSide}

  use DrakeWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, game: Drake.new(), selected: nil, moves: %{})}
  end

  @impl true
  def handle_event("click-tile", %{"x" => x, "y" => y}, socket) do
    position = {String.to_integer(x), String.to_integer(y)}

    changed_socket =
      case socket.assigns.moves[position] do
        nil ->
          assign(socket,
            selected: position,
            moves: GameState.board_moves(socket.assigns.game, position)
          )

        move ->
          assign(socket,
            selected: nil,
            moves: %{},
            game: GameState.execute_move(socket.assigns.game, move)
          )
      end

    {:noreply, changed_socket}
  end

  def handle_event("click-stack", %{"side" => side}, socket) do
    changed_socket =
      assign(socket,
        selected: side,
        moves: GameState.stack_moves(socket.assigns.game)
      )

    {:noreply, changed_socket}
  end

  defp captured_count(state, side) do
    count = TroopStacks.length(state.board.captured_troops, side)
    "Captured: #{count}"
  end

  defp tile_image(socket, state, position) do
    tile = Board.tile_at!(state.board, position)

    if Tile.has_troop?(tile) do
      troop = Tile.get_troop(tile)
      "url(#{Routes.static_path(socket, image_for_troop(troop))})"
    else
      ""
    end
  end

  defp stack_image(socket, state, side) do
    case TroopStacks.peek(state.troops, side) do
      nil -> ""
      troop ->
        path = Routes.static_path(socket, image_for_troop({troop, :front, side}))
        "url(#{path})"
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

  defp winning_message(state) do
    player =
      state.side_on_turn
      |> PlayingSide.opposite()
      |> Atom.to_string()
      |> String.capitalize()

    "#{player} player won!"
  end
end
