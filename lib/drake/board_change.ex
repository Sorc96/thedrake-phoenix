defmodule Drake.BoardChange do
  alias Drake.{Board, Tile, Troop, Position}

  @type t :: {change_type, Board.t(), Position.t(), Position.t()}
  @type change_type :: :step_only | :capture_only | :step_and_capture

  @spec step_only(Board.t(), Position.t(), Position.t()) :: t
  def step_only(board, origin, target) do
    {:step_only, board, origin, target}
  end

  @spec capture_only(Board.t(), Position.t(), Position.t()) :: t
  def capture_only(board, origin, target) do
    {:capture_only, board, origin, target}
  end

  @spec step_and_capture(Board.t(), Position.t(), Position.t()) :: t
  def step_and_capture(board, origin, target) do
    {:step_and_capture, board, origin, target}
  end

  @spec origin(t) :: Position.t()
  def origin({_, _, origin, _}), do: origin

  @spec target(t) :: Position.t()
  def target({_, _, _, target}), do: target

  @spec result_board(t) :: Board.t()
  def result_board({change, board, origin, target}) do
    troop =
      board
      |> Board.tile_at!(origin)
      |> Tile.get_troop()
      |> Troop.flip()

    if change == :step_only do
      Board.with_tiles(board, [
        Tile.empty(origin),
        Tile.with_troop(target, troop)
      ])
    else
      captured = Tile.get_troop(Board.tile_at!(board, target))

      new_tiles =
        case change do
          :capture_only -> [Tile.with_troop(origin, troop), Tile.empty(target)]
          :step_and_capture -> [Tile.empty(origin), Tile.with_troop(target, troop)]
        end

      Board.with_capture_and_tiles(board, captured, new_tiles)
    end
  end
end
