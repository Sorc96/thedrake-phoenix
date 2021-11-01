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
    position = {String.to_integer(x), String.to_integer(y)}

    changed_socket =
      case socket.assigns.moves[position] do
        nil ->
          tile = Board.tile_at!(socket.assigns.game.board, position)

          if Tile.has_troop?(tile) && Board.troop_side(tile) == socket.assigns.game.side_on_turn do
            assign(socket,
              selected: position,
              moves: GameState.board_moves(socket.assigns.game, position)
            )
          else
            socket
          end

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
end
