defmodule Drake.Position do
  alias Drake.PlayingSide

  @type t :: {integer, integer}

  @spec step(t, t) :: t
  def step({x1, y1}, {x2, y2}) do
    {x1 + x2, y1 + y2}
  end

  @spec step_by_playing_side(t, t, PlayingSide.t()) :: t
  def step_by_playing_side(origin, direction, side) do
    case side do
      :blue -> step(origin, direction)
      :orange -> step(origin, flip_y(direction))
    end
  end

  @spec flip_y(t) :: t
  defp flip_y({x, y}), do: {x, -y}

  @spec directions :: list(t)
  def directions do
    [{1, 0}, {-1, 0}, {0, 1}, {0, -1}]
  end
end
