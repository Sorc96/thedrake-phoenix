defmodule Drake.GameState do
  alias Drake.{
    Board,
    Leaders,
    TroopStacks,
    PlayingSide,
    Position,
    Troop,
    Tile,
    BoardChange,
    TroopAction
  }

  @type t :: %{
          status: :placing_leaders | :placing_guards | :middle_game | :victory,
          board: Board.t(),
          leaders: Leaders.t(),
          troops: TroopStacks.t(),
          side_on_turn: PlayingSide.t(),
          guards: integer
        }

  @type move :: board_move | stack_move
  @type board_move :: {:board_move, BoardChange.t()}
  @type stack_move :: {:stack_move, Position.t()}

  @spec initial(Board.t(), TroopStacks.t(), PlayingSide.t()) :: t
  def initial(board, troops, side) do
    %{
      status: :placing_leaders,
      board: board,
      leaders: Leaders.no_leaders(),
      troops: troops,
      side_on_turn: side,
      guards: 0
    }
  end

  @spec execute_move(t, move) :: t
  def execute_move(state, {:board_move, change}) do
    perform_board_change(state, change)
  end

  def execute_move(state, {:stack_move, target}) do
    place_from_stack(state, target)
  end

  @spec place_from_stack(t, Position.t()) :: t
  def place_from_stack(state, target) do
    troop = make_troop(state)
    opponent = PlayingSide.opposite(state.side_on_turn)
    new_tile = Tile.with_troop(target, troop)

    new_state = %{
      state
      | board: Board.with_tiles(state.board, [new_tile]),
        troops: TroopStacks.pop(state.troops, state.side_on_turn),
        side_on_turn: opponent
    }

    case state.status do
      :placing_leaders ->
        new_leaders = Leaders.place(state.leaders, state.side_on_turn, target)

        if Leaders.leader_placed?(state.leaders, opponent) do
          %{new_state | status: :placing_guards, leaders: new_leaders, guards: 0}
        else
          %{new_state | leaders: new_leaders}
        end

      :placing_guards ->
        if state.guards == 3 do
          %{new_state | status: :middle_game}
        else
          %{new_state | guards: state.guards + 1}
        end

      :middle_game ->
        new_state
    end
  end

  @spec perform_board_change(t, BoardChange.t()) :: t
  def perform_board_change(%{status: :middle_game} = state, change) do
    opponent = PlayingSide.opposite(state.side_on_turn)
    new_board = BoardChange.result_board(change)
    new_state = %{state | board: new_board, side_on_turn: opponent}

    cond do
      winning_change?(state, change) ->
        new_leaders = Leaders.remove(state.leaders, opponent)
        %{new_state | status: :victory, leaders: new_leaders}

      leader_moving?(state, change) ->
        new_leaders = Leaders.move(state.leaders, state.side_on_turn, change.target)
        %{new_state | leaders: new_leaders}

      true ->
        new_state
    end
  end

  @spec make_troop(GameState.t()) :: Troop.t()
  defp make_troop(state) do
    Troop.new(
      TroopStacks.peek(state.troops, state.side_on_turn),
      :front,
      state.side_on_turn
    )
  end

  @spec winning_change?(t, BoardChange.t()) :: boolean
  def winning_change?(state, change) do
    opponent = PlayingSide.opposite(state.side_on_turn)

    Leaders.leader_on?(state.leaders, opponent, change.target)
  end

  @spec leader_moving?(t, BoardChange.t()) :: boolean
  defp leader_moving?(state, change) do
    leader_position = Leaders.position(state.leaders, state.side_on_turn)

    change.origin == leader_position
  end

  @spec stack_moves(t) :: %{Position.t() => stack_move}
  def stack_moves(%{status: :placing_leaders} = state) do
    row =
      case state.side_on_turn do
        :blue -> 1
        :orange -> state.board.dimension
      end

    for {_, y} = position <- Map.keys(state.board.tiles),
        y == row,
        into: %{},
        do: {position, {:stack_move, position}}
  end

  def stack_moves(%{status: :placing_guards} = state) do
    for position <- Map.keys(state.board.tiles),
        can_place_guard?(state, position),
        into: %{},
        do: {position, {:stack_move, position}}
  end

  def stack_moves(%{status: :middle_game} = state) do
    if TroopStacks.empty?(state.troops, state.side_on_turn) do
      %{}
    else
      for position <- Map.keys(state.board.tiles),
          can_place_from_stack?(state, position),
          into: %{},
          do: {position, {:stack_move, position}}
    end
  end

  def stack_moves(%{status: :victory}), do: %{}

  @spec can_place_guard?(t, Position.t()) :: boolean
  defp can_place_guard?(state, position) do
    Board.can_place_on?(state.board, position) && leader_next_to?(state, position)
  end

  @spec leader_next_to?(t, Position.t()) :: boolean
  def leader_next_to?(state, position) do
    Enum.any?(Position.directions(), fn direction ->
      neighbour = Position.step(position, direction)
      Leaders.leader_on?(state.leaders, state.side_on_turn, neighbour)
    end)
  end

  @spec can_place_from_stack?(t, Position.t()) :: boolean
  defp can_place_from_stack?(state, position) do
    Board.can_place_on?(state.board, position) && allied_troop_next_to?(state, position)
  end

  @spec allied_troop_next_to?(t, Position.t()) :: boolean
  def allied_troop_next_to?(state, position) do
    Enum.any?(Position.directions(), fn direction ->
      neighbour = Position.step(position, direction)

      case Board.tile_at(state.board, neighbour) do
        {:ok, tile} -> Tile.has_troop?(tile) && Board.troop_side(tile) == state.side_on_turn
        :error -> false
      end
    end)
  end

  @spec board_moves(t, Position.t()) :: %{Position.t() => board_move}
  def board_moves(%{status: :middle_game} = state, position) do
    origin = Board.tile_at!(state.board, position)

    if Tile.has_troop?(origin) && Board.troop_side(origin) == state.side_on_turn do
      troop = Tile.get_troop(origin)

      Enum.flat_map(
        TroopAction.for_troop(Troop.get_type(troop), Troop.get_face(troop)),
        &TroopAction.changes_from(&1, position, state.side_on_turn, state.board)
      )
      |> Enum.map(&{&1.target, {:board_move, &1}})
      |> Map.new()
    else
      %{}
    end
  end

  def board_moves(_, _), do: %{}

  @spec victory?(t) :: boolean
  def victory?(%{status: :victory}), do: true
  def victory?(_), do: false
end
