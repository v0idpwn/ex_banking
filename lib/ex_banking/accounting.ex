defmodule ExBanking.Accounting do
  @moduledoc """
  Accounting context for the ExBanking Application
  """

  import ExBanking.Accounting.Validators

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

  def get_balance(name, currency) do 
    with {:ok, pid} <- find_user(name) do
      UserServer.get_balance(pid, currency)
    end
  end

  def send(sender, receiver, amount, currency) do 
    with {:sender, {:ok, sender_pid}} <- {:sender, find_user(sender)},
         {:receiver, {:ok, receiver_pid}} <- {:receiver, find_user(receiver)} do
      UserServer.send(sender_pid, receiver_pid, amount, currency)
    else
      {:sender, {:error, :user_does_not_exist}} ->
        {:error, :sender_does_not_exist}
      {:receiver, {:error, :user_does_not_exist}} ->
        {:error, :receiver_does_not_exist}
    end
  end
end
