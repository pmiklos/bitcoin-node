#!/bin/bash -e

DIR=$(dirname "$0")
APPS_DIR="$DIR/apps"

if [[ -z "$NODE_DATA_DIR" ]]; then
	echo "ERROR: Environment is not set. Make sure direnv is configured and allowed" >&2
	exit 1
fi

echo "Creating app data folders..."
mkdir -p "$NODE_DATA_DIR"
rsync -avm --include='/*/' --include='/*/data/' --include='/*/data/**' --exclude='*' "$APPS_DIR"/ "$NODE_DATA_DIR"/

echo "Initializing git submodules (this can take a minute or two)..."
git submodule init
git submodule update
