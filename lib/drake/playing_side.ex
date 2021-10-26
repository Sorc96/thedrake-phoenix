defmodule Drake.PlayingSide do
  @type t :: :blue | :orange

  @spec opposite(t) :: t
  def opposite(:blue), do: :orange
  def opposite(:orange), do: :blue
end
