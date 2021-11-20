defmodule Drake.BoardChange do
  alias Drake.{Board, Tile, Troop, Position}

  @type t :: %{type: change_type, board: Board.t(), origin: Position.t(), target: Position.t()}
  @type change_type :: :step_only | :capture_only | :step_and_capture

  @spec step_only(Board.t(), Position.t(), Position.t()) :: t
  def step_only(board, origin, target) do
    %{type: :step_only, board: board, origin: origin, target: target}
  end

  @spec capture_only(Board.t(), Position.t(), Position.t()) :: t
  def capture_only(board, origin, target) do
    %{type: :capture_only, board: board, origin: origin, target: target}
  end

  @spec step_and_capture(Board.t(), Position.t(), Position.t()) :: t
  def step_and_capture(board, origin, target) do
    %{type: :step_and_capture, board: board, origin: origin, target: target}
  end

  @spec result_board(t) :: Board.t()
  def result_board(change) do
    if change.type == :step_only do
      Board.with_tiles(change.board, changed_tiles(change))
    else
      Board.with_capture_and_tiles(change.board, targeted_troop(change), changed_tiles(change))
    end
  end

  @spec changed_tiles(t) :: list(Tile.t())
  defp changed_tiles(%{type: :step_only} = change) do
    [
      Tile.empty(change.origin),
      Tile.with_troop(change.target, troop_after_action(change))
    ]
  end

  defp changed_tiles(%{type: :capture_only} = change) do
    [
      Tile.with_troop(change.origin, troop_after_action(change)),
      Tile.empty(change.target)
    ]
  end

  defp changed_tiles(%{type: :step_and_capture} = change) do
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
