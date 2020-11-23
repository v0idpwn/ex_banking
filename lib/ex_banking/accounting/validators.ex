defmodule ExBanking.Accounting.Validators do
  @moduledoc """
  Validation helpers
  """

  def validate_user(user) when is_binary(user), do: {:ok, user}
  def validate_user(_), do: {:error, :wrong_arguments}

  def validate_currency(currency) when is_binary(currency), do: {:ok, currency}
  def validate_currency(_), do: {:error, :wrong_arguments}

  def validate_amount(amount) when is_integer(amount), do: {:ok, amount / 1}

  def validate_amount(amount) when is_float(amount) do
    rounded = Float.round(amount, 2)
    {:ok, rounded}
  end

  def validate_amount(_), do: {:error, :wrong_arguments}
end
