defmodule DrakeTest do
  alias Drake.{Board, Tile, TroopStacks}

  use ExUnit.Case

  test "play a game" do
    result =
      Drake.new()
      # Place leaders
      |> move(:stack, {2, 1})
      |> move(:stack, {3, 4})
      # Place guards
      |> move(:stack, {2, 2})
      |> move(:stack, {2, 4})
      |> move(:stack, {3, 1})
      |> move(:stack, {3, 3})
      # Middle game
      |> move(:stack, {1, 2})
      |> move(:stack, {2, 3})
      |> move({1, 2}, {2, 3})
      |> move({2, 4}, {2, 3})
      |> move(:stack, {4, 1})
      |> move(:stack, {1, 3})
      |> move({2, 1}, {1, 1})
      |> move(:stack, {3, 2})
      |> move({1, 1}, {1, 3})
      |> move({3, 2}, {2, 2})
      |> move({3, 1}, {3, 2})
      |> move({2, 3}, {3, 2})
      |> move({4, 1}, {3, 3})
      |> move(:stack, {3, 3})
      |> move({4, 1}, {3, 2})
      |> move({3, 4}, {1, 4})
      |> move({1, 3}, {3, 3})
      |> move({1, 4}, {1, 3})
      |> move({3, 3}, {3, 4})
      |> move({1, 3}, {3, 3})
      # Winning move
      |> move({3, 2}, {3, 3})

    assert result.status == :victory
    assert result.side_on_turn == :orange
    assert result.leaders == {:one_leader, :blue, {3, 4}}
    assert TroopStacks.length(result.board.captured_troops, :blue) == 3
    assert TroopStacks.length(result.board.captured_troops, :orange) == 7

    drake =
      result.board
      |> Board.tile_at!({3, 4})
      |> Tile.get_troop()

    assert drake == {:drake, :front, :blue}

    other_troop =
      result.board
      |> Board.tile_at!({3, 3})
      |> Tile.get_troop()

    assert other_troop == {:spearman, :back, :blue}

    empty_positions = Map.keys(result.board.tiles) -- [{3, 4}, {3, 3}]

    refute Enum.any?(empty_positions, fn position ->
             result.board
             |> Board.tile_at!(position)
             |> Tile.has_troop?()
           end)
  end

  defp move(state, origin, target) do
    {:ok, new_state} = Drake.perform_move(state, origin, target)
    new_state
  end
end
