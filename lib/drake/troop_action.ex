defmodule Drake.TroopAction do
  alias Drake.{Position, PlayingSide, Board, BoardChange, Troop}

  @type t :: {action_type, Position.t()}
  @type action_type :: :shift | :slide | :strike

  @spec shift(integer, integer) :: t
  def shift(x, y), do: {:shift, {x, y}}

  @spec slide(integer, integer) :: t
  def slide(x, y), do: {:slide, {x, y}}

  @spec strike(integer, integer) :: t
  def strike(x, y), do: {:strike, {x, y}}

  @spec changes_from(t, Position.t(), PlayingSide.t(), Board.t()) :: list(BoardChange.t())
  def changes_from({action_type, position} = action, origin, side, board) do
    target = Position.step_by_playing_side(origin, position, side)
    change = {board, origin, target}

    case Board.available_action(change) do
      :step -> step_changes(action, change, side)
      :capture -> capture_changes(action_type, change)
      nil -> []
    end
  end

  @spec step_changes(t, Board.change(), PlayingSide.t()) :: list(BoardChange.t())
  defp step_changes({:shift, _}, change, _), do: [BoardChange.step_only(change)]
  defp step_changes({:slide, direction}, {board, origin, _} = change, side) do
    change = BoardChange.step_only(change)
    [change | changes_from({:slide, Position.advance(direction)}, origin, side, board)]
  end
  defp step_changes({:strike, _},  _, _), do: []

  @spec capture_changes(action_type, Board.change()) :: list(BoardChange.t())
  defp capture_changes(:shift, change), do: [BoardChange.step_and_capture(change)]
  defp capture_changes(:slide, change), do: [BoardChange.step_and_capture(change)]
  defp capture_changes(:strike, change), do: [BoardChange.capture_only(change)]

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
