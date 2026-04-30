## Configuration

### Datum

Location: `$NODE_DATA_DIR/datumgateway/data/config/config.json`

### Bitcoind

Location: `$NODE_DATA_DIR/bitcoind/data/bitcoin/bitcoin.conf`

Notifying Datum when new block is found:
```
blocknotify=wget -q -O /dev/null http://datumgateway.bitcoin.local:7152/NOTIFY
```
