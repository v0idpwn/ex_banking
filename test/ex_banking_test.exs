defmodule ExBankingTest do
  use ExUnit.Case, async: false
  doctest ExBanking

  describe "create_user/1" do
    test "creates a genserver in the dynamic supervisor" do
      assert :ok = ExBanking.create_user("v0idpwn")
    end

    test "fails if process exists on the same node" do
      assert :ok = ExBanking.create_user("foobar")
      assert {:error, :user_already_exists} = ExBanking.create_user("foobar")
    end

    test "fails if process exists on another node" do
      [node1, node2] = LocalCluster.start_nodes("my_cluster", 2)

      assert :ok = :erpc.call(node1, ExBanking, :create_user, ["node1user"])

      assert {:error, :user_already_exists} =
               :erpc.call(node2, ExBanking, :create_user, ["node1user"])
    end
  end

  describe "deposit/3" do
    test "increases a currency" do 
      ExBanking.create_user("deposit-1")

      assert {:ok, 1000} = ExBanking.deposit("deposit-1", 1000, "BRL")
      assert {:ok, 2000} = ExBanking.deposit("deposit-1", 1000, "BRL")
    end

    test "works with multiple currencies" do 
      ExBanking.create_user("deposit-2")

      assert {:ok, 1000} = ExBanking.deposit("deposit-2", 1000, "BRL")
      assert {:ok, 1000} = ExBanking.deposit("deposit-2", 1000, "EUR")
      assert {:ok, 2000} = ExBanking.deposit("deposit-2", 1000, "BRL")
    end

    test "fails if user does not exist" do 
      assert {:error, :user_does_not_exist} = ExBanking.deposit("deposit-3", 1000, "BRL")
    end
  end

  describe "withdraw/3" do
    test "decreases a currency" do 
      ExBanking.create_user("withdraw-1")
      ExBanking.deposit("withdraw-1", 5000, "BRL")

      assert {:ok, 4000} = ExBanking.withdraw("withdraw-1", 1000, "BRL")
      assert {:ok, 2000} = ExBanking.withdraw("withdraw-1", 2000, "BRL")
    end

    test "works with multiple currencies" do 
      ExBanking.create_user("withdraw-2")
      ExBanking.deposit("withdraw-2", 5000, "BRL")
      ExBanking.deposit("withdraw-2", 5000, "EUR")

      assert {:ok, 4000} = ExBanking.withdraw("withdraw-2", 1000, "BRL")
      assert {:ok, 2000} = ExBanking.withdraw("withdraw-2", 3000, "EUR")
      assert {:ok, 3000} = ExBanking.withdraw("withdraw-2", 1000, "BRL")
    end

    test "fails if user doesn't have enough money" do 
      ExBanking.create_user("withdraw-3")
      ExBanking.deposit("withdraw-3", 5000, "BRL")

      assert {:error, :not_enough_money} = ExBanking.withdraw("withdraw-3", 6000, "BRL")
      assert {:ok, 4000} = ExBanking.withdraw("withdraw-3", 1000, "BRL")
    end

    test "fails if user does not exist" do 
      assert {:error, :user_does_not_exist} = ExBanking.withdraw("withdraw-4", 1000, "BRL")
    end
  end

  describe "get_balance/3" do
    test "returns balance for a specific currency" do 
      ExBanking.create_user("balance-1")

      assert {:ok, 1000} = ExBanking.deposit("balance-1", 1000, "BRL")
      assert {:ok, 1000} = ExBanking.get_balance("balance-1", "BRL")
    end

    test "return 0 if never deposited" do 
      ExBanking.create_user("balance-2")

      assert {:ok, 0} = ExBanking.get_balance("balance-2", "BRL")
    end

    test "fails if user does not exist" do 
      assert {:error, :user_does_not_exist} = ExBanking.get_balance("balance-3", "BRL")
    end
  end

  describe "send/4" do 
    test "sends money" do 
      ExBanking.create_user("sender-1")
      ExBanking.create_user("receiver-1")
      assert {:ok, 3000} = ExBanking.deposit("sender-1", 3000, "BRL")

      assert {:ok, 2000, 1000} = ExBanking.send("sender-1", "receiver-1", 1000, "BRL")
      assert {:ok, 1000, 2000} = ExBanking.send("sender-1", "receiver-1", 1000, "BRL")
    end

    test "fails with specific error if sender doesn't exist" do 
      ExBanking.create_user("receiver-2")

      assert {:error, :sender_does_not_exist} = ExBanking.send("sender-2", "receiver-2", 1000, "BRL")
    end

    test "fails with specific error if receiver doesn't exist" do 
      ExBanking.create_user("sender-3")

      assert {:error, :receiver_does_not_exist} = ExBanking.send("sender-3", "receiver-3", 1000, "BRL")
    end

    test "fails if not enough money" do 
      ExBanking.create_user("sender-4")
      ExBanking.create_user("receiver-4")
      assert {:ok, 3000} = ExBanking.deposit("sender-4", 3000, "BRL")

      assert {:error, :not_enough_money} = ExBanking.send("sender-4", "receiver-4", 5000, "BRL")

      # ballances are not affected
      assert {:ok, 3000} = ExBanking.get_balance("sender-4", "BRL")
      assert {:ok, 0} = ExBanking.get_balance("receiver-4", "BRL")
    end
  end
end
