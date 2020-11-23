defmodule ExBanking.Application do
  use Application

  alias ExBanking.Accounting.AccountSupervisor

  def start(_type, _args) do
    Supervisor.start_link(
      [{AccountSupervisor, []}],
      strategy: :one_for_one,
      name: ExBanking.Supervisor
    )
  end
end
