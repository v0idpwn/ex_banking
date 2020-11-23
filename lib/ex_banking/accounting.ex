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
end
