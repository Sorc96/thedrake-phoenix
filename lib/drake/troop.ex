defmodule Drake.Troop do
  alias Drake.PlayingSide

  @type t :: {troop_type, face, PlayingSide.t()}
  @type troop_type :: :drake | :clubman | :monk | :spearman | :swordsman | :archer
  @type face :: :front | :back

  @spec new(Type.t(), face, PlayingSide.t()) :: t
  def new(type, face, side), do: {type, face, side}

  @spec flip(t) :: t
  def flip({type, :front, side}), do: {type, :back, side}
  def flip({type, :back, side}), do: {type, :front, side}

  @spec get_type(t) :: troop_type
  def get_type({type, _, _}), do: type

  @spec get_face(t) :: face
  def get_face({_, face, _}), do: face

  @spec get_side(t) :: PlayingSide.t()
  def get_side({_, _, side}), do: side
end
