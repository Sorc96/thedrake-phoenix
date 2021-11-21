defmodule Drake.TroopStacks do
  alias Drake.{PlayingSide, Troop}

  @type t :: {list(Troop.troop_type()), list(Troop.troop_type())}

  @spec new(list(Troop.troop_type())) :: t
  def new(troops \\ []), do: {troops, troops}

  @spec peek(t, PlayingSide.t()) :: Troop.troop_type() | nil
  def peek({[], _}, :blue), do: nil
  def peek({[troop | _], _}, :blue), do: troop
  def peek({_, []}, :orange), do: nil
  def peek({_, [troop | _]}, :orange), do: troop

  @spec pop(t, PlayingSide.t()) :: t
  def pop({blue, orange}, side) do
    case side do
      :blue -> {tl(blue), orange}
      :orange -> {blue, tl(orange)}
    end
  end

  @spec add(t, Troop.t()) :: t
  def add({blue, orange}, troop) do
    troop_type = Troop.get_type(troop)

    case Troop.get_side(troop) do
      :blue -> {[troop_type | blue], orange}
      :orange -> {blue, [troop_type | orange]}
    end
  end

  @spec empty?(t, PlayingSide.t()) :: boolean
  def empty?({blue, _}, :blue), do: Enum.empty?(blue)
  def empty?({_, orange}, :orange), do: Enum.empty?(orange)

  @spec length(t, PlayingSide.t()) :: integer
  def length({blue, orange}, side) do
    case side do
      :blue -> length(blue)
      :orange -> length(orange)
    end
  end
end
