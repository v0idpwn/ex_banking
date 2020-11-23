defmodule ExBanking.Accounting do
  @moduledoc """

  """

  alias ExBanking.Accounting.AccountSupervisor
  alias ExBanking.Accounting.UserServer

  def create_user(user) do 
    DynamicSupervisor.start_child(AccountSupervisor, {UserServer, user})
  end
end
