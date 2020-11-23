:ok = LocalCluster.start()

Application.ensure_all_started(:ex_banking)

ExUnit.start()
