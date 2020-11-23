defmodule ExBanking.Accounting.UserServer do
  use GenServer

  @max_message_queue 10

  ## Client 
  def start_link(name) do
    GenServer.start_link(__MODULE__, [], name: {:global, name})
  end

  def available?(pid) do
    case :erpc.call(node(pid), Process, :info, [pid, :message_queue_len]) do
      {:message_queue_len, n} when n < @max_message_queue ->
        true

      _ ->
        false
    end
  end

  def deposit(pid, amount, currency) do
    case available?(pid) do
      true ->
        GenServer.call(pid, {:deposit, amount, currency})

      false ->
        {:error, :too_many_requests_to_user}
    end
  end

  def withdraw(pid, amount, currency) do
    case available?(pid) do
      true ->
        GenServer.call(pid, {:withdraw, amount, currency})

      false ->
        {:error, :too_many_requests_to_user}
    end
  end

  def get_balance(pid, currency) do
    case available?(pid) do
      true ->
        GenServer.call(pid, {:get_balance, currency})

      false ->
        {:error, :too_many_requests_to_user}
    end
  end

  def send(sender_pid, receiver_pid, amount, currency) do
    with {:sender_available?, true} <- {:sender_available?, available?(sender_pid)},
         {:receiver_available?, true} <- {:receiver_available?, available?(receiver_pid)},
         {:ok, new_sender_amount} <- GenServer.call(sender_pid, {:withdraw, amount, currency}),
         {:ok, new_receiver_amount} <- GenServer.call(receiver_pid, {:deposit, amount, currency}) do
      {:ok, new_sender_amount, new_receiver_amount}
    else
      {:sender_available?, false} ->
        {:error, :too_many_requests_to_sender}

      {:receiver_available?, false} ->
        {:error, :too_many_requests_to_receiver}

      error ->
        error
    end
  end

  ## Server
  def init(_opts), do: {:ok, %{}}

  def handle_call({:deposit, amount, currency}, _from, state) do
    new_amount = Float.round(amount + (state[currency] || 0), 2)

    {:reply, {:ok, new_amount}, Map.put(state, currency, new_amount)}
  end

  def handle_call({:withdraw, amount, currency}, _from, state) do
    case (state[currency] || 0.0) - amount do
      new_amount when new_amount >= 0 ->
        {:reply, {:ok, new_amount}, Map.put(state, currency, new_amount)}

      _invalid ->
        {:reply, {:error, :not_enough_money}, state}
    end
  end

  def handle_call({:get_balance, currency}, _from, state) do
    {:reply, {:ok, state[currency] || 0.0}, state}
  end
end
