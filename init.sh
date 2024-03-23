#!/bin/bash -e

DIR=$(dirname "$0")
APPS_DIR="$DIR/apps"

if [ ! -f "$DIR/.env" ]; then
  echo "Creating .env file..."
  cp -iv "$DIR"/{.env.default,.env}
fi

source .env

echo "Creating app data folders..."
mkdir -p "$NODE_DATA_DIR"
rsync -avm --include='*/' --include='*/data/**' --exclude='*' "$APPS_DIR"/ "$NODE_DATA_DIR"/

echo "Initializing git submodules (this can take a minute or two)..."
git submodule init
git submodule update
