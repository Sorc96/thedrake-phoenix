defmodule Drake.Board do
  alias Drake.{Tile, TroopStacks, Position, Troop}

  @type t :: %{
          dimension: integer,
          tiles: %{Position.t() => Tile.t()},
          captured_troops: TroopStacks.t()
        }
   @type change :: {t, Position.t(), Position.t()}

  @spec empty(integer) :: t
  def empty(dimension, captured_troops \\ TroopStacks.new()) do
    %{
      dimension: dimension,
      tiles: make_empty_tiles(dimension),
      captured_troops: captured_troops
    }
  end

  @spec make_empty_tiles(integer) :: %{Position.t() => Tile.t()}
  defp make_empty_tiles(dimension) do
    for x <- 1..dimension, y <- 1..dimension, position = {x, y}, into: %{} do
      {position, Tile.empty(position)}
    end
  end

  @spec tile_at(t, Position.t()) :: {:ok, Tile.t()} | :error
  def tile_at(board, position) do
    Map.fetch(board.tiles, position)
  end

  @spec tile_at!(t, Position.t()) :: Tile.t()
  def tile_at!(board, position) do
    Map.fetch!(board.tiles, position)
  end

  @spec contains?(t, Position.t()) :: boolean
  def contains?(board, position) do
    Map.has_key?(board.tiles, position)
  end

  @spec can_take_from?(t, Position.t()) :: boolean
  def can_take_from?(board, position) do
    case tile_at(board, position) do
      {:ok, tile} -> Tile.has_troop?(tile)
      :error -> false
    end
  end

  @spec can_place_on?(t, Position.t()) :: boolean
  def can_place_on?(board, position) do
    case tile_at(board, position) do
      {:ok, tile} -> Tile.accepts_troop?(tile)
      :error -> false
    end
  end

  @spec available_action(change) :: nil | :step | :capture
  def available_action(change) do
    cond do
      can_step?(change) -> :step
      can_capture?(change) -> :capture
      true -> nil
    end
  end

  @spec can_step?(change) :: boolean
  defp can_step?({board, origin, target}) do
    can_take_from?(board, origin) && can_place_on?(board, target)
  end

  @spec can_capture?(change) :: boolean
  defp can_capture?({board, origin, target}) do
    with {:ok, origin_tile} <- tile_at(board, origin),
         {:ok, target_tile} <- tile_at(board, target),
         true <- Tile.has_troop?(origin_tile),
         true <- Tile.has_troop?(target_tile) do
      troop_side(origin_tile) != troop_side(target_tile)
    else
      _ -> false
    end
  end

  @spec with_tiles(t, list(Tile.t())) :: t
  def with_tiles(board, tiles) do
    new_tiles = for tile <- tiles, into: %{} do
      {Tile.position(tile), tile}
    end

    Map.update!(board, :tiles, &Map.merge(&1, new_tiles))
  end

  @spec with_capture_and_tiles(t, Troop.t(), list(Tile.t())) :: t
  def with_capture_and_tiles(board, capture, tiles) do
    board
    |> with_tiles(tiles)
    |> Map.update!(:captured_troops, fn stacks ->
      TroopStacks.add(stacks, Troop.get_type(capture), Troop.get_side(capture))
    end)
  end

  @spec troop_side(Tile.t()) :: PlayingSide.t()
  def troop_side(tile) do
    tile
    |> Tile.get_troop()
    |> Troop.get_side()
  end
end
