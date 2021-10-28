defmodule Drake.Leaders do
  alias Drake.{PlayingSide, Position}

  @type t :: no_leaders | one_leader | both_leaders
  @type no_leaders :: :no_leaders
  @type one_leader :: {:one_leader, PlayingSide.t(), Position.t()}
  @type both_leaders :: {:both_leaders, Position.t(), Position.t()}

  @spec no_leaders :: no_leaders
  def no_leaders, do: :no_leaders

  @spec one_leader(PlayingSide.t(), Position.t()) :: one_leader
  def one_leader(side, position), do: {:one_leader, side, position}

  @spec both_leaders(Position.t(), Position.t()) :: both_leaders
  def both_leaders(blue, orange), do: {:both_leaders, blue, orange}

  @spec leader_placed?(t, PlayingSide.t()) :: boolean
  def leader_placed?(:no_leaders, _), do: false
  def leader_placed?({:one_leader, leader_side, _}, side), do: side == leader_side
  def leader_placed?({:both_leaders, _, _}, _), do: true

  @spec place(t, PlayingSide.t(), Position.t()) :: t
  def place(:no_leaders, side, position), do: one_leader(side, position)

  def place({:one_leader, leader_side, leader_position}, side, position)
      when side != leader_side do
    case side do
      :blue ->both_leaders(position, leader_position)
      :orange -> both_leaders(leader_position, position)
    end
  end

  @spec remove(both_leaders, PlayingSide.t()) :: one_leader
  def remove({:both_leaders, blue, orange}, side) do
    case side do
      :blue -> one_leader(:orange, orange)
      :orange -> one_leader(:blue, blue)
    end
  end

  @spec move(both_leaders, PlayingSide.t(), Position.t()) :: both_leaders
  def move({:both_leaders, blue, orange}, side, position) do
    case side do
      :blue -> both_leaders(position, orange)
      :orange -> both_leaders(blue, position)
    end
  end

  @spec leader_on?(t, PlayingSide.t(), Position.t()) :: boolean
  def leader_on?(:no_leaders, _, _), do: false

  def leader_on?({:one_leader, leader_side, leader_position}, side, position) do
    if side == leader_side do
      position == leader_position
    else
      false
    end
  end

  def leader_on?({:both_leaders, blue, orange}, side, position) do
    case side do
      :blue -> position == blue
      :orange -> position == orange
    end
  end

  @spec position(both_leaders, PlayingSide.t()) :: Position.t()
  def position({:both_leaders, blue, orange}, side) do
    case side do
      :blue -> blue
      :orange -> orange
    end
  end
end
