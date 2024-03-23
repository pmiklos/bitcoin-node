## Setup

### Initialize

```bash
make init
```

This will create the app data directory structure and copy the `.env.default` to `.env`.
Make any customizations in the `.env` file you need.

### Build

To build all docker images locally:
```bash
make all
```

### Start

To start all services:
```bash
make up
```

### Stop
To stop all services:
```bash
make down
```