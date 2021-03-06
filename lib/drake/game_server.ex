defmodule Drake.GameServer do
  use GenServer

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, :empty, name: __MODULE__)
  end

  def new do
    identifier = generate_identifier()
    GenServer.call(__MODULE__, {:put, identifier, Drake.new()})
    identifier
  end

  def perform_move(identifier, origin, target) do
    with {:ok, game} <- find_game(identifier),
         {:ok, new_state} <- Drake.perform_move(game, origin, target) do
      GenServer.call(__MODULE__, {:put, identifier, new_state})
    end
  end

  def find_game(identifier) do
    case GenServer.call(__MODULE__, {:get, identifier}) do
      nil -> :error
      game -> {:ok, game}
    end
  end

  @impl true
  def init(:empty), do: {:ok, %{}}

  @impl true
  def handle_call({:put, identifier, game}, _from, state) do
    {:reply, :ok, Map.put(state, identifier, game)}
  end

  def handle_call({:get, identifier}, _from, state) do
    {:reply, state[identifier], state}
  end

  defp generate_identifier do
    id = for _ <- 1..32, do: Enum.random('0123456789abcdefghijklmnopqrstuvwxyz')
    List.to_string(id)
  end
end
