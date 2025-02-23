PROVER_DB="postgres://rollup:rollup_AA9944@127.0.0.1:5433/rollup"
ROLLUP_DB="postgres://rollup:rollup_AA9944@127.0.0.1:5433/rollup"
EXCHANGE_DB="postgres://exchange:exchange_AA9944@127.0.0.1:5432/exchange"

# db related
prover_status:
	psql $(PROVER_DB) -c "select status, count(*) from task group by status UNION ALL SELECT null status, COUNT(status) from task"
block_status:
	psql $(PROVER_DB) -c "select status, count(*) from l2block group by status UNION ALL SELECT null status, COUNT(status) from l2block"
new_trades:
	psql $(EXCHANGE_DB) -c 'select * from market_trade order by time desc limit 10;'
new_blocks:
	psql $(PROVER_DB) -c 'select status, created_time, updated_time from task order by created_time desc limit 5' | cat
	psql $(PROVER_DB) -c "select status, created_time, updated_time from task where status = 'proved' order by created_time desc limit 5" | cat
block_input:
	psql $(ROLLUP_DB) -c 'select block_id, witness from l2block order by block_id desc limit 1' | cat
block_root:
	psql $(ROLLUP_DB) -c 'select block_id, new_root from l2block order by block_id desc limit 1' | cat
prover_db:
	psql $(PROVER_DB) 
exchange_db:
	psql $(EXCHANGE_DB)
rollup_db:
	psql $(ROLLUP_DB)

# process related
list:
	ps aux|grep fluidex-backend|grep -v grep || true

# log related
tail_log:
	docker-compose --file orchestra/docker/docker-compose.yaml --project-name orchestra logs > orchestra/docker-compose.log
	docker-compose --file regnbue-bridge/docker/docker-compose.yaml --project-name faucet logs > regnbue-bridge/docker-compose.log
	docker-compose --file blockscout/docker/docker-compose.yaml --project-name blockscout logs > blockscout/docker-compose.log
	ls rollup-state-manager/*.log prover-cluster/*.log dingir-exchange/*.log dingir-exchange/logs/*.log orchestra/*.log regnbue-bridge/*.log blockscout/*.log contracts/*.log | xargs tail -n 3
clean_log:
	ls rollup-state-manager/*.log prover-cluster/*.log dingir-exchange/*.log dingir-exchange/logs/*.log orchestra/*.log regnbue-bridge/*.log blockscout/*.log contracts/*.log | xargs rm

# code related
shfmt:
	shfmt -i 2 -sr -w *.sh */*.sh
upgrade_all:
	git submodule foreach git pull origin master
