defmodule ExBanking.Accounting.UserServer do
  use GenServer

  ## Client 
  def start_link(name) do
    GenServer.start_link(__MODULE__, [], name: {:global, name})
  end

  def available?(pid) do
    pid
    |> Process.info(:message_queue_len)
    |> case do
      {:message_queue_len, n} when n < 10 ->
        true

      _ ->
        false
    end
  end

  def deposit(pid, amount, currency) do 
    with {:available?, true} <- {:available?, available?(pid)} do
      GenServer.call(pid, {:deposit, amount, currency})
    else
      {:available?, false} ->
        {:error, :too_many_requests_to_user}
    end
  end

  def withdraw(pid, amount, currency) do 
    with {:available?, true} <- {:available?, available?(pid)} do
      GenServer.call(pid, {:withdraw, amount, currency})
    else
      {:available?, false} ->
        {:error, :too_many_requests_to_user}
    end
  end

  ## Server
  def init(_opts), do: {:ok, %{}}

  def handle_call({:deposit, amount, currency}, _from, state) do
    new_amount = amount + (state[currency] || 0)

    {:reply, {:ok, new_amount}, Map.put(state, currency, new_amount)}
  end

  def handle_call({:withdraw, amount, currency}, _from, state) do
    case (state[currency] || 0) - amount do
      new_amount when new_amount >= 0 ->
        {:reply, {:ok, new_amount}, Map.put(state, currency, new_amount)}
      
      _invalid ->
        {:reply, {:error, :not_enough_money}, state}
    end
  end
end
