# Self-hosted Bitcoin Node

A fully self-hosed Bitcoin node with supporting applications such as blockchain explorer.
The Bitcoin software installed are built from the source code on your own machine,
so you don't have to trust binary package maintainers.
This project was inspired by [Umbrel](https://github.com/getumbrel).

**Applications:**
* [bitcoincore](https://github.com/lncm/docker-bitcoind) - Bitcoin Core, a full Bitcoin node
* [bitcoinknots](https://github.com/bitcoinknots/bitcoin) - Bitcoin Knots, an alternative implementation of Bitcoin Core
* [electrs](https://github.com/romanz/electrs) - efficient Electrum Server implemented in Rust
* [mempool](https://github.com/mempool/mempool) - fully-featured mempool visualizer, explorer and API service

**Endpoints**

The following endpoints will be exposed on all network interfaces unless you change `$NODE_HAPROXY_EXPOSE_IP`.
* http://bitcoind.local:8332 - bitcoind RPC API
* http://electrs.local:50001 - Electrum JSON RPC API
* http://mempool.local - mempool blockchain explorer
* http://datumgateway.local - DATUM Gateway admin UI

See also mDNS configuration further below.

## Setup

### Prerequisites

* [Docker](https://docs.docker.com/get-docker/) - for building application images locally and running them in containers
* [Docker Compose](https://docs.docker.com/compose/install/) - for orchestrating all applications of a self-hosted Bitcoin node
* [Docker Buildx](https://github.com/docker/buildx#installing) - for building application images locally in a more efficient way
* [git](https://git-scm.com/) - typically installed as an OS package
* [make](https://www.gnu.org/software/make/) - typically installed as an OS package
* [direnv](https://direnv.net/) - typically installed as an OS package

### Limitations

The application data is stored on the host filesystem in plain directories under the logged-in user's home directory.
As a result, the Docker application containers will need to be able to write the `$NODE_DATA_DIR` (`~/.bitcoin-node` by default)
with 1000:1000 uid and gid. If you run linux as a solo user this might already be the case, but sometimes not.

### Initialization

Before building and running the node, initialize the project. This will create the app data directory structure and clone all git submodules for building the app docker images from source.
```bash
make init
```

Make sure you set up `direnv` in your shell (see `man direnv`) and that the environment variables are automatically loaded from `.envrc`.

Customizations in environment variables can be added in a local `.env` file, for example:
```
APP_BITCOINCORE_VERSION=28.0
APP_BITCOIND_USER_RPCAUTH='user:9999111919191....'
```

### Build

The command below will build all Bitcoin application images locally.

**Note**: some well-known open-source supporting applications such as MySQL and HAProxy will not be built from source.
Instead, a pre-built image will be pulled from Docker Hub.

```bash
make all
```

### Start

Before you start the node, it is recommended to review the `.env` file and make necessary customizations.
Typically, you might want to change the below, but you can also just go with defaults and change them later:
* `APP_BITCOIND_USER_RPCAUTH` - this is your username and password for use by your wallets when connecting to your self-hosted node. Use `rpcauth.py` to generate a password. Important to quote the value with single quotes otherwise the `$` sign in the generated password will be interpreted incorrectly.
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

### Local DNS Resolution (mDNS)

This project has built-in **mDNS (Multicast DNS) support**. If your client computer (macOS, Windows, or Linux with Avahi/systemd-resolved) supports mDNS, these endpoints will resolve automatically on your local network without any extra configuration.

Typically, you want to advertise the service names on your local network. For exmaple, if the IP address of your Bitcoin Node is 192.168.1.100 then you would set the following in your `.env` file: 
```bash
NODE_MDNS_ADVERTISE_IP=192.168.1.100
```
NOTE: leaving `NODE_MDNS_ADVERTISE_IP` at 0.0.0.0 (default), the mDNS service will stay inactive.

If your network or client devices do not support mDNS, you will have to manually add something like below to `/etc/hosts` on the machines you want to connect to your bitcoin node:

```text
192.168.1.100 bitcoind.local electrs.local mempool.local datumgateway.local
```

