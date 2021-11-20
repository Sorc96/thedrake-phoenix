defmodule Drake.BoardTest do
  alias Drake.{Board, TroopStacks}

  use ExUnit.Case
  doctest Drake.Board

  describe "empty board" do
    setup do
      %{
        board: Board.empty(4, TroopStacks.new()),
        positions: (for x <- 1..4, y <- 1..4, do: {x, y})
      }
    end

    test "contains all positions", %{board: board, positions: positions} do
      assert Enum.all?(positions, &Board.contains?(board, &1))
    end

    test "can get all tiles by position", %{board: board} do
      assert Enum.all?(board.tiles, fn {position, tile} ->
        {:ok, ^tile} = Board.tile_at(board, position)
      end)
    end

    test "can place on all tiles", %{board: board, positions: positions} do
      assert Enum.all?(positions, &Board.can_place_on?(board, &1))
    end

    test "cannot take from any tile", %{board: board, positions: positions} do
      refute Enum.any?(positions, &Board.can_take_from?(board, &1))
    end

    test "no available actions", %{board: board, positions: positions} do
      combinations = for a <- positions, b <- positions, do: {a, b}

      assert Enum.all?(combinations, fn {a, b} ->
        is_nil(Board.available_action({board, a, b}))
      end)
    end
  end
end
