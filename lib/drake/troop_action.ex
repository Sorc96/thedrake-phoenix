defmodule Drake.TroopAction do
  alias Drake.{Position, Tile, PlayingSide, Board, BoardChange, Troop}

  @type t :: shift | slide | strike
  @type shift :: {:shift, Position.t()}
  @type slide :: {:slide, Position.t()}
  @type strike :: {:strike, Position.t()}

  @spec shift(integer, integer) :: shift
  def shift(x, y), do: {:shift, {x, y}}

  @spec slide(integer, integer) :: slide
  def slide(x, y), do: {:slide, {x, y}}

  @spec strike(integer, integer) :: strike
  def strike(x, y), do: {:strike, {x, y}}

  @spec changes_from(t, Tile.troop_tile(), PlayingSide.t(), Board.t()) :: list(BoardChange.t())
  def changes_from({:shift, action_position}, origin, side, board) do
    origin_position = Tile.position(origin)
    target_position = Position.step_by_playing_side(origin_position, action_position, side)

    case Board.available_action(board, origin_position, target_position) do
      :step -> [BoardChange.step_only(board, origin_position, target_position)]
      :capture -> [BoardChange.step_and_capture(board, origin_position, target_position)]
      _ -> []
    end
  end

  def changes_from({:slide, direction} = action, origin, side, board) do
    origin_position = Tile.position(origin)
    next_position = Position.step_by_playing_side(origin_position, direction, side)

    case Board.available_action(board, origin_position, next_position) do
      :step ->
        target = Board.tile_at!(board, next_position)
        change = BoardChange.step_only(board, origin_position, next_position)
        [change | changes_from(action, target, side, board)]

      :capture ->
        [BoardChange.step_and_capture(board, origin_position, next_position)]

      _ ->
        []
    end
  end

  def changes_from({:strike, action_position}, origin, side, board) do
    origin_position = Tile.position(origin)
    target_position = Position.step_by_playing_side(origin_position, action_position, side)

    if Board.can_capture?(board, origin_position, target_position) do
      [BoardChange.capture_only(board, origin_position, target_position)]
    else
      []
    end
  end

  @spec for_troop(Troop.troop_type(), Troop.face()) :: list(t)
  def for_troop(:drake, face) do
    case face do
      :front -> [slide(1, 0), slide(-1, 0)]
      :back -> [slide(0, 1), slide(0, -1)]
    end
  end

  def for_troop(:clubman, face) do
    case face do
      :front -> [shift(1, 0), shift(-1, 0), shift(0, 1), shift(0, -1)]
      :back -> [shift(1, 1), shift(-1, -1), shift(-1, 1), shift(1, -1)]
    end
  end

  def for_troop(:monk, face) do
    case face do
      :front -> [slide(1, 1), slide(-1, -1), slide(-1, 1), slide(1, -1)]
      :back -> [shift(1, 0), shift(-1, 0), shift(0, 1), shift(0, -1)]
    end
  end

  def for_troop(:spearman, face) do
    case face do
      :front -> [shift(0, 1), strike(1, 2), strike(-1, 2)]
      :back -> [shift(1, 1), shift(-1, 1), shift(0, -1)]
    end
  end

  def for_troop(:swordsman, face) do
    case face do
      :front -> [strike(1, 0), strike(-1, 0), strike(0, 1), strike(0, -1)]
      :back -> [shift(1, 0), shift(-1, 0), shift(0, 1), shift(0, -1)]
    end
  end

  def for_troop(:archer, face) do
    case face do
      :front -> [shift(1, 0), shift(-1, 0), shift(0, -1)]
      :back -> [shift(0, 1), strike(-1, 1), strike(1, 1), strike(0, 2)]
    end
  end
end
