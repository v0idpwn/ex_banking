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
  end

  describe "withdraw/3" do
  end
end
