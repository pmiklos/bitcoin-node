#!/bin/bash -e

DIR=$(dirname "$0")

if [ ! -f "$DIR/.env" ]; then
  echo "Creating .env file..."
  cp -iv "$DIR"/{.env.default,.env}
fi

source .env

APPS_DIR="$DIR/apps"

mkdir -p "$NODE_DATA_DIR"

echo "Creating app data folders..."

# rsync folders matching the pattern */data/*
rsync -avmn --include='*/' --include='*/data/**' --exclude='*' "$APPS_DIR"/ "$NODE_DATA_DIR"/
