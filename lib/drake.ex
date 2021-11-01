defmodule Drake do
  alias Drake.{Board, GameState, TroopStacks, Troop, Position}

  @spec new :: GameState.t()
  def new do
    board = Board.empty(4, TroopStacks.new())
    troops = TroopStacks.new(troop_set())

    GameState.initial(board, troops, :blue)
  end

  @spec perform_move(GameState.t(), Position.t() | :stack, Position.t()) ::
          {:ok, GameState.t()} | :error
  def perform_move(state, origin_or_stack, target) do
    moves =
      case origin_or_stack do
        :stack -> GameState.stack_moves(state)
        origin -> GameState.board_moves(state, origin)
      end

    case moves[target] do
      nil -> :error
      move -> {:ok, GameState.execute_move(state, move)}
    end
  end

  @spec troop_set :: list(Troop.troop_type())
  defp troop_set do
    [
      :drake,
      :clubman,
      :clubman,
      :monk,
      :spearman,
      :swordsman,
      :archer
    ]
  end
end
