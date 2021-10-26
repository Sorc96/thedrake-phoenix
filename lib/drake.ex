defmodule Drake do
  alias Drake.{Board, GameState, TroopStacks, Troop}

  @spec new :: GameState.t()
  def new do
    board = Board.empty(4, TroopStacks.new())
    troops = TroopStacks.new(troop_set())

    GameState.initial(board, troops, :blue)
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
