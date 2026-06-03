## Architecture

Participating systems:
* **Local Bitcoin Node (`bitcoind` / `bitcoinknots`)**: A fully synchronized node that compiles transaction lists and generates block templates.
* **DATUM Gateway**: The local coordinator that manages block templates, handles the Stratum server endpoint, negotiates payout splits with the pool, and submits winning blocks.
* **External Hasher (Rented Hashpower)**: Mining hardware (e.g., rented from Braiins) acting as a Stratum client that connects to the DATUM Gateway to receive jobs and compute hashes.
* **DATUM-Supporting Mining Pool (e.g., OCEAN)**: The pool that coordinates the coinbase transaction payout splits (such as via TIDES) and validates submitted shares to distribute rewards proportionate to the hashpower contributed.

Collaboration flow:
* Hashpower is rented from the external hasher.
* The hasher connects to the DATUM Gateway via the Stratum TCP protocol on port `23334` over the public internet.
* The DATUM Gateway continually queries the local Bitcoin node for block templates using the RPC `getblocktemplate` method.
* The DATUM Gateway communicates with the mining pool via the encrypted, custom **DATUM Protocol** to obtain the required coinbase payout splits for the local templates.
* The DATUM Gateway constructs mining jobs (incorporating local transactions and the pool's payout splits) and sends them to the hasher.
* The hasher computes hashes and sends completed shares (solved nonces) back to the DATUM Gateway.
* The DATUM Gateway submits valid shares matching the pool's difficulty to the pool via the DATUM protocol.
* The mining pool records the shares and distributes payouts directly to the miner's payout address.

When a block is found (a share meets the Bitcoin network difficulty):
* The hasher submits the winning share to the DATUM Gateway.
* The DATUM Gateway reconstructs the full solved block.
* The DATUM Gateway submits the solved block directly to the local Bitcoin node (and any configured upstream backup nodes) using the `submitblock` RPC method.
* The local Bitcoin node validates and broadcasts the solved block directly to the Bitcoin P2P network.
* The DATUM Gateway notifies the pool of the won block via the DATUM protocol to coordinate payout distribution.

Collaboration diagram:
```mermaid
graph TD
    subgraph "Local Environment (Miner)"
        Bitcoind["bitcoind / Bitcoin Knots"] <-->|RPC / GBT & NOTIFY| Gateway["DATUM Gateway"]
    end

    subgraph Public Internet
        Hasher["External Hasher (e.g., Braiins Renting)"] <-->|"Stratum v1 (Port 23334)"| Gateway
        Gateway <-->|"DATUM Protocol (Encrypted)"| Pool["DATUM Pool (e.g., OCEAN)"]
        Bitcoind --->|P2P Broadcast| BitcoinNet["Bitcoin P2P Network"]
    end

    classDef local fill:#2a4d6c,stroke:#3b5e7c,stroke-width:2px,color:#fff;
    classDef external fill:#2c3e50,stroke:#34495e,stroke-width:2px,color:#fff;
    class Bitcoind,Gateway local;
    class Hasher,Pool,BitcoinNet external;
```

Sequence diagram:
```mermaid
sequenceDiagram
    autonumber
    participant Hasher as External Hasher (Rented Hash)
    participant Gateway as DATUM Gateway
    participant Node as Local Bitcoin Node (bitcoind)
    participant Pool as DATUM Supporting Pool

    Note over Gateway, Node: Continuous Loop (Template Updates)
    Node-->>Gateway: BlockNotify (New block found on network)
    Gateway->>Node: RPC getblocktemplate
    Node-->>Gateway: Block Template data

    Note over Gateway, Pool: Coinbase Split Negotiation
    Gateway->>Pool: Register Template & Payout Request (DATUM Protocol)
    Pool-->>Gateway: Payout splits & coinbase requirements

    Note over Gateway, Hasher: Stratum Job Distribution
    Gateway->>Gateway: Construct Job (incl. Pool splits & local txs)
    Gateway->>Hasher: Stratum mining jobs (mining.notify)

    Note over Hasher, Pool: Hashing & Share Submission
    loop Hashing
        Hasher->>Hasher: Compute hashes
    end
    Hasher->>Gateway: Submit completed share (mining.submit)

    alt Share meets Pool Difficulty
        Gateway->>Pool: Forward Share (DATUM Protocol)
        Pool-->>Gateway: Accept Share
        Pool->>Pool: Record share for payout distribution
    end

    alt Share meets Bitcoin Network Difficulty (Block Found!)
        Gateway->>Gateway: Reconstruct full solved block
        Gateway->>Node: RPC submitblock
        Node->>Node: Validate block
        Node->>Node: Broadcast block to Bitcoin P2P Network
        Gateway->>Pool: Notify found block (with PoW)
    end
```

## Recommended partners

* [Braiins](https://hashpower.braiins.com/) - rent hashpower
* [OCEAN mining](https://ocean.xyz/) - minin pool that supports DATUM

## Configuration

### Datum

Location: `$NODE_DATA_DIR/datumgateway/data/config/config.json`

```json
{
    "bitcoind": {
        "rpccookiefile": "/var/run/bitcoin/.cookie",
        "rpcurl": "http://bitcoind.bitcoin.local:8332"
    },
    "mining": {
        "pool_address": "<bitcoin payout address>",
        "coinbase_tag_secondary": "myminername"
    },
    "api": {
        "admin_password": "secret",
        "listen_port": 7152,
        "modify_conf": false
    }
}
```

*Exposed ports:*
* `23334` - default Stratum TCP endpoint to which the hasher connects to, it must be exposed on the public internet
* `7152` (Internal) -  Your DATUM Gateway admin UI, accessible externally via HAProxy at http://datumgateway.local 


### Bitcoind

Location: `$NODE_DATA_DIR/bitcoind/data/bitcoin/bitcoin.conf`

Notifying Datum when new block is found:
```
blocknotify=wget -q -O /dev/null http://datumgateway.bitcoin.local:7152/NOTIFY
```
