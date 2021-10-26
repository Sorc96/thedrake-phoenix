defmodule Drake.Tile do
  alias Drake.{Position, Troop}

  @type t :: empty_tile | troop_tile
  @type empty_tile :: {:empty_tile, Position.t()}
  @type troop_tile :: {:troop_tile, Position.t(), Troop.t()}

  @spec empty(Position.t()) :: empty_tile
  def empty(position), do: {:empty_tile, position}

  @spec with_troop(Position.t(), Troop.t()) :: troop_tile
  def with_troop(position, troop), do: {:troop_tile, position, troop}

  @spec position(t) :: Position.t()
  def position({:empty_tile, position}), do: position
  def position({:troop_tile, position, _}), do: position

  @spec has_troop?(t) :: boolean
  def has_troop?({:empty_tile, _}), do: false
  def has_troop?({:troop_tile, _, _}), do: true

  @spec accepts_troop?(t) :: boolean
  def accepts_troop?({:empty_tile, _}), do: true
  def accepts_troop?({:troop_tile, _, _}), do: false

  @spec get_troop(troop_tile) :: Troop.t()
  def get_troop({:troop_tile, _, troop}), do: troop
end
