# Fluidex Backend

Fludiex team is building the first permissionless layer2 orderbook DEX on Ethereum, powered by PLONK zk-rollup.

This repo contains all the backend stuff, including exchange match engine,rollup state manager, prover cluster(master and workers), zk circuit codes.

Currently it is only a demo/POC version, many features not implemented. 

# Components & Submodules

Submodules:

* zk circuits: ZK-Rollup circuits written in circom. It lies in the rollup-state-manager submodule.
* dingir-exchange: the match engine server. It matches eddsa-signed L2 orders from users, and generates trades. It writes all the 'events'(like orders/trades/balance updates) to the global Kafka message bus.
* rollup-state-manager: maintain the global rollup state Merkle tree. It fetches events/transactions from the Kafka message bus, and updates the Merkle tree accordingly, and generates L2 blocks.
* prover-cluster: a master-workers cluster for proving ZK-SNARK(PLONK) circuits. It loads L2 blocks generated by rollup-state-manager, and proves them, and writes the proofs to databases finally.
* regnbue-bridge: a L1-L2 bridge for fast withdraw/deposit. Currently in the demo version, it acts like a facuet, sending some initial tokens to each new user of the Fluidex zk-rollup network.

Some external services:

* Kafka: used as the global message bus.
* PostgreSQL: the main database we use. It stores the match engine history/state, prover-cluster state, rollup(L2 blocks/L2 txs) state etc. 
* TimescaleDB: time-series databases, used for exchange market data(like K-Line).

Some zero knowledge development tools developed by Fludiex team are used to process the circuits, including [snarkit](https://github.com/Fluidex/snarkit) and [plonkit](https://github.com/Fluidex/plonkit)



# How to run

Ubuntu 20.04 is the only supported environment currently.   

```
# install some dependencies and tools
# including rust / docker / docker-compose / nodejs etc
$ bash scripts/install_all.sh

# compile zk circuits and setup circuits locally
# start databases and message queue with docker compose
# and launch all the services
# and a fake orders/trades generator
$ bash run.sh

# stop all the processes and destroy docker compose clusters
$ bash stop.sh
```

Some useful commands have been added to Makefile:

```
# print the L2 blocks status, total block number, prover block number, etc
$ make prover_status

# print the latest trades generated by matchengine
$ make new_trades

```


# Todos

* Data availability. And make num of circuit public inputs to 1.
* Use a real k8s proving cluster rather than the local single node prover
* The rollup state persistence is not finished yet. It fetches txs from the beginning in this demo version.

# Known Issues

* Order signatures are not checked completely. Todo: user nonces and order ids should be signed.
* For convenience, PLONK is setup locally rather than by MPC. 
