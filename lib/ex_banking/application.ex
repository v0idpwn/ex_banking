defmodule ExBanking.Application do
  use Application

  def start(_type, _args) do
    Supervisor.start_link(
      [],
      strategy: :one_for_one,
      name: ExBanking.Supervisor
    )
  end
end
