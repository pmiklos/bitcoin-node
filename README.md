# Self-hosted Bitcoin Node

A fully self-hosed Bitcoin node with supporting applications such as blockchain explorer.
The Bitcoin software installed are built from the source code on your own machine,
so you don't have to trust binary package maintainers.
This project was inspired by [Umbrel](https://github.com/getumbrel).

**Applications:**
* [bitcoind](https://github.com/lncm/docker-bitcoind) - Bitcoin Core, a full Bitcoin node
* [mempool](https://github.com/mempool/mempool) - fully-featured mempool visualizer, explorer and API service


## Setup

### Prerequisites

* [Docker](https://docs.docker.com/get-docker/) - for building application images locally and running them in containers
* [Docker Compose](https://docs.docker.com/compose/install/) - for orchestrating all applications of a self-hosted Bitcoin node
* [git](https://git-scm.com/) - typically installed as an OS package
* [make](https://www.gnu.org/software/make/) - typically installed as an OS package

### Limitations

The application data is stored on the host filesystem in plain directories under the logged-in user's home directory.
As a result, the Docker application containers will need to be able to write the `$NODE_DATA_DIR` (`~/.bitcoin-node` by default)
with 1000:1000 uid and gid. If you run linux as a solo user this might already be the case, but sometimes not.

### Initialization

Before building and running the node, initialize the project:
```bash
make init
```

This will create the app data directory structure and copy the `.env.default` to `.env`.
Make any customizations in the `.env` file you need.

It will also clone all git submodules for building the app docker images from source.

### Build

The command below will build all Bitcoin application images locally.

**Note**: some well-known open-source supporting applications such as MySQL and HAProxy will not be built from source.
Instead, a pre-built image will be pulled from Docker Hub.

```bash
make all
```

### Start

Before you start the node, it is recommended to review the `.env` file and make necessary customizations.
Typically, you might want to change:
* `APP_BITCOIND_USER_RPCAUTH` - this is your username and password for use by your wallets when connecting to your self-hosted node. Use `rpcauth.py` to generate a password. Important that you will need to escape the `$` separator sign in the generated output as `$$`.
* `APP_BITCOIND_MEMPOOL_RPCAUTH` - similar to the above, but used by the mempool app to fetch blockchain data
* `APP_MEMPOOL_BITCOIND_PASSWORD` - set to the password generated above

To start the node execute the command below.
This will create isolated networks each application, start the application containers
and expose useful ports to the host machine.
```bash
make up
```

### Stop
To stop all services run the below command. This will remove the docker networks and stop the application containers.
The application data will be kept intact under `$NODE_DATA_DIR` (or `~/.bitcoin-node` by default).
```bash
make down
```
