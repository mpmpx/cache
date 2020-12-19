defmodule LruCache do
  use GenServer

  defstruct [:table_name, :max_size, :size, :history]

  # Client

  def start_link({name, max_size}) do
    GenServer.start_link(__MODULE__, {name, max_size}, name: Cache)
  end

  def put(key, value) do
    GenServer.cast(Cache, {:put, key, value})
  end

  def get(key) do
    GenServer.call(Cache, {:get, key})
  end

  def get_history() do
    GenServer.call(Cache, :get_all)
  end
  # Server (callbacks)

  @impl true
  def init({name, max_size}) do
    :ets.new(name, [:set, :public, :named_table])
    {:ok, %LruCache{table_name: name, max_size: max_size, size: 0, history: []}}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    case :ets.match(state.table_name, {key, :"$1"}) do
      [] ->
        {:reply, {:not_found, nil}, state}
      [[value]] ->
        new_history = update_history(key, state.history)
        {:reply, {:ok, value}, %{state | :history => new_history}}
    end
  end

  @impl true
  def handle_call(:get_history, _from, state) do
    {:reply, {:ok, state.history}, state}
  end

  @impl true
  def handle_cast({:put, key, value}, state) do
    case :ets.match(state.table_name, {key, :"$1"}) do
      [_] ->
        new_history = update_history(key, state.history)
        :ets.insert(state.table_name, {key, value})
        {:noreply, %{state | :history => new_history}}
      [] ->
        new_history = rest_history ++ [key]
        :ets.insert(state.table_name, {key, value})
        if state.size <= state.max_size do
          {:noreply, %{state | :history => new_history, :size => state.size + 1}}
        else
          [evict_key | rest_history] = state.history
          :ets.delete(state.table_name, evict_key)
          {:noreply, %{state | :history => rest_history}}
        end
    end
  end

  defp update_history(key, [head | tail], prev \\ []) do
    if key == head do
      prev ++ tail ++ [head]
    else
      update_history(key, tail, prev ++ [head])
    end
  end
end
