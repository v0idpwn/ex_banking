defmodule ExBanking.Accounting.UserServer do
  use GenServer

  ## Client 
  def start_link(name) do
    GenServer.start_link(__MODULE__, [], name: {:global, name})
  end

  def available?(name) do
    name
    |> :global.whereis_name()
    |> Process.info(:message_queue_len)
    |> case do
      {:message_queue_len, n} when n < 10 ->
        true

      _ ->
        false
    end
  end

  ## Server
  def init(_opts), do: {:ok, %{}}

  def handle_call({:deposit, amount, currency}, state) do
    :timer.sleep(100)

    case state do
      %{^currency => current_amount} ->
        Map.put(state, currency, amount + current_amount)

      %{} ->
        Map.put(state, currency, amount)
    end
    |> (&{:noreply, &1}).()
  end
end
