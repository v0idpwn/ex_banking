defmodule ExBanking do
  @moduledoc """
  Documentation for `ExBanking`.
  """

  alias ExBanking.Users

  @type banking_error ::
          {:error,
           :wrong_arguments
           | :user_already_exists
           | :user_does_not_exist
           | :not_enough_money
           | :sender_does_not_exist
           | :receiver_does_not_exist
           | :too_many_requests_to_user
           | :too_many_requests_to_sender
           | :too_many_requests_to_receiver}

  def create_user(user) do 
    Users.create(user)
  end

  def deposit(user, amount, currency) do 
  end

  def withdraw(user, amount, currency) do 
  end

  def get_balance(user, currency) do 
  end

  def send(from_user, to_user, amount, currency) do 
  end
end
