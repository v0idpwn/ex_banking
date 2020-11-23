defmodule ExBanking.Accounting do
  @moduledoc """

  """

  alias ExBanking.Accounting.AccountSupervisor
  alias ExBanking.Accounting.UserServer

  def create_user(user) do
    AccountSupervisor
    |> DynamicSupervisor.start_child({UserServer, user})
    |> case do
      {:ok, _pid} ->
        :ok

      {:error, {:already_started, _}} ->
        {:error, :user_already_exists}
    end
  end

  def find_user(name) do 
    name
    |> :global.whereis_name()
    |> case do 
      :undefined ->
        {:error, :user_does_not_exist}
      pid ->
        {:ok, pid}
    end
  end

  def deposit(name, amount, currency) do 
    with {:ok, pid} <- find_user(name) do
      UserServer.deposit(pid, amount, currency)
    end
  end

  def withdraw(name, amount, currency) do 
    with {:ok, pid} <- find_user(name) do
      UserServer.withdraw(pid, amount, currency)
    end
  end

  def send(sender, receiver, amount, currency) do 
    with {:ok, sender_pid} <- find_user(sender),
         {:ok, receiver_pid} <- find_user(receiver) do
      UserServer.send(sender_pid, receiver_pid, amount, currency)
    end
  end
end
