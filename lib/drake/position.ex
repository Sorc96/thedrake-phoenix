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

  @spec advance(t) :: t
  def advance({x, y}) do
    {change_by_sign(x), change_by_sign(y)}
  end

  @spec change_by_sign(integer) :: integer
  defp change_by_sign(0), do: 0
  defp change_by_sign(n) when n > 0, do: n + 1
  defp change_by_sign(n) when n < 0, do: n - 1

  @spec directions :: list(t)
  def directions do
    [{1, 0}, {-1, 0}, {0, 1}, {0, -1}]
  end
end
