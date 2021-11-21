defmodule Drake.BoardChange do
  alias Drake.{Board, Tile, Troop, Position}

  @type t :: %{type: change_type, board: Board.t(), origin: Position.t(), target: Position.t()}
  @type change_type :: :step_only | :capture_only | :step_and_capture

  @spec step_only(Board.change()) :: t
  def step_only(change) do
    new(change, :step_only)
  end

  @spec capture_only(Board.change()) :: t
  def capture_only(change) do
    new(change, :capture_only)
  end

  @spec step_and_capture(Board.change()) :: t
  def step_and_capture(change) do
    new(change, :step_and_capture)
  end

  @spec new(Board.change(), change_type) :: t
  defp new({board, origin, target}, type) do
    %{type: type, board: board, origin: origin, target: target}
  end

  @spec result_board(t) :: Board.t()
  def result_board(%{type: :step_only} = change) do
    Board.with_tiles(change.board, changed_tiles(change))
  end

  def result_board(change) do
    Board.with_capture_and_tiles(
      change.board,
      targeted_troop(change),
      changed_tiles(change)
    )
  end

  @spec changed_tiles(t) :: list(Tile.t())
  defp changed_tiles(%{type: :capture_only} = change) do
    [
      Tile.with_troop(change.origin, troop_after_action(change)),
      Tile.empty(change.target)
    ]
  end

  defp changed_tiles(change) do
    [
      Tile.empty(change.origin),
      Tile.with_troop(change.target, troop_after_action(change))
    ]
  end

  @spec troop_after_action(t) :: Troop.t()
  def troop_after_action(%{board: board, origin: origin}) do
    board
    |> Board.tile_at!(origin)
    |> Tile.get_troop()
    |> Troop.flip()
  end

  @spec targeted_troop(t) :: Troop.t()
  def targeted_troop(action) do
    action.board
    |> Board.tile_at!(action.target)
    |> Tile.get_troop()
  end
end
