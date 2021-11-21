defmodule DrakeWeb.GameLive.Show do
  alias Drake.{Board, Tile, GameState, GameServer}
  import DrakeWeb.GameLive.Components

  use DrakeWeb, :live_view

  @impl true
  def mount(%{"identifier" => identifier, "side" => side_name}, _session, socket) do
    if connected?(socket) do
      DrakeWeb.Endpoint.subscribe(identifier)
    end

    {:ok, game} = GameServer.find_game(identifier)
    side = String.to_existing_atom(side_name)

    {:ok,
     assign(socket,
       identifier: identifier,
       side: side,
       game: game,
       selected: nil,
       moves: %{}
     )}
  end

  @impl true
  def handle_event("click-tile", %{"x" => x, "y" => y}, socket) do
    if on_turn?(socket) do
      target = {String.to_integer(x), String.to_integer(y)}

      case socket.assigns.moves[target] do
        nil ->
          {:noreply, try_select_tile(socket, target)}

        _ ->
          origin = parse_origin(socket)
          :ok = GameServer.perform_move(socket.assigns.identifier, origin, target)
          DrakeWeb.Endpoint.broadcast(socket.assigns.identifier, "turn", nil)
          {:noreply, socket}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_event("click-stack", %{"side" => side}, socket) do
    if on_turn?(socket) && side == Atom.to_string(socket.assigns.game.side_on_turn) do
      moves = GameState.stack_moves(socket.assigns.game)
      {:noreply, assign(socket, selected: side, moves: moves)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(%{event: "turn"}, socket) do
    {:ok, new_state} = GameServer.find_game(socket.assigns.identifier)
    {:noreply, assign(socket, game: new_state, selected: nil, moves: %{})}
  end

  defp try_select_tile(socket, target) do
    game = socket.assigns.game
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

  defp on_turn?(socket) do
    socket.assigns.side == socket.assigns.game.side_on_turn
  end
end
