defmodule DrakeWeb.GameLive.Show do
  alias Drake.{Board, Tile, GameState}
  import DrakeWeb.GameLive.Components

  use DrakeWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, game: Drake.new(), selected: nil, moves: %{})}
  end

  @impl true
  def handle_event("click-tile", %{"x" => x, "y" => y}, socket) do
    target = {String.to_integer(x), String.to_integer(y)}
    game = socket.assigns.game

    changed_socket =
      if is_nil(socket.assigns.selected) do
        try_select_tile(socket, game, target)
      else
        origin = parse_origin(socket)

        case Drake.perform_move(game, origin, target) do
          {:ok, new_state} -> assign(socket, selected: nil, moves: %{}, game: new_state)
          :error -> try_select_tile(socket, game, target)
        end
      end

    {:noreply, changed_socket}
  end

  def handle_event("click-stack", %{"side" => side}, socket) do
    changed_socket =
      if side == Atom.to_string(socket.assigns.game.side_on_turn) do
        assign(socket,
          selected: side,
          moves: GameState.stack_moves(socket.assigns.game)
        )
      else
        socket
      end

    {:noreply, changed_socket}
  end

  defp try_select_tile(socket, game, target) do
    tile = Board.tile_at!(game.board, target)

    if Tile.has_troop?(tile) && Board.troop_side(tile) == game.side_on_turn do
      assign(socket,
        selected: target,
        moves: GameState.board_moves(game, target)
      )
    else
      socket
    end
  end

  defp parse_origin(socket) do
    case socket.assigns.selected do
      "blue" -> :stack
      "orange" -> :stack
      position -> position
    end
  end
end
