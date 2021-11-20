defmodule Drake.TroopAction do
  alias Drake.{Position, PlayingSide, Board, BoardChange, Troop}

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

  @spec changes_from(t, Position.t(), PlayingSide.t(), Board.t()) :: list(BoardChange.t())
  def changes_from({:shift, action_position}, origin, side, board) do
    target = Position.step_by_playing_side(origin, action_position, side)

    case Board.available_action(board, origin, target) do
      :step -> [BoardChange.step_only(board, origin, target)]
      :capture -> [BoardChange.step_and_capture(board, origin, target)]
      _ -> []
    end
  end

  def changes_from({:slide, direction}, origin, side, board) do
    target = Position.step_by_playing_side(origin, direction, side)

    case Board.available_action(board, origin, target) do
      :step ->
        change = BoardChange.step_only(board, origin, target)
        [change | changes_from({:slide, Position.advance(direction)}, origin, side, board)]

      :capture ->
        [BoardChange.step_and_capture(board, origin, target)]

      nil ->
        []
    end
  end

  def changes_from({:strike, action_position}, origin, side, board) do
    target = Position.step_by_playing_side(origin, action_position, side)

    if Board.can_capture?(board, origin, target) do
      [BoardChange.capture_only(board, origin, target)]
    else
      []
    end
  end

  @spec for_troop(Troop.troop_type(), Troop.face()) :: list(t)
  def for_troop(:drake, :front), do: [slide(1, 0), slide(-1, 0)]
  def for_troop(:drake, :back), do: [slide(0, 1), slide(0, -1)]

  def for_troop(:clubman, :front), do: [shift(1, 0), shift(-1, 0), shift(0, 1), shift(0, -1)]
  def for_troop(:clubman, :back), do: [shift(1, 1), shift(-1, -1), shift(-1, 1), shift(1, -1)]

  def for_troop(:monk, :front), do: [slide(1, 1), slide(-1, -1), slide(-1, 1), slide(1, -1)]
  def for_troop(:monk, :back), do: [shift(1, 0), shift(-1, 0), shift(0, 1), shift(0, -1)]

  def for_troop(:spearman, :front), do: [shift(0, 1), strike(1, 2), strike(-1, 2)]
  def for_troop(:spearman, :back), do: [shift(1, 1), shift(-1, 1), shift(0, -1)]

  def for_troop(:swordsman, :front), do: [strike(1, 0), strike(-1, 0), strike(0, 1), strike(0, -1)]
  def for_troop(:swordsman, :back), do: [shift(1, 0), shift(-1, 0), shift(0, 1), shift(0, -1)]

  def for_troop(:archer, :front), do: [shift(1, 0), shift(-1, 0), shift(0, -1)]
  def for_troop(:archer, :back), do: [shift(0, 1), strike(-1, 1), strike(1, 1), strike(0, 2)]
end
