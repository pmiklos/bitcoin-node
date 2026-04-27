# bitcoind (Meta App)

This is a meta app designed to provide a unified data directory (`data/bitcoin`) shared by multiple Bitcoin node implementations.

Both `bitcoincore` and `bitcoinknots` are configured to mount the data directory from this location. This ensures they share the same blockchain state and avoids the need for re-syncing when switching between implementations.
