#!/bin/bash -e

source .env

# Source directory
source_dir="apps/"

# Destination directory
destination_dir="${NODE_DATA_DIR}"

mkdir -p $destination_dir

# rsync folders matching the pattern */data/*
rsync -avm --include='*/' --include='*/data/**' --exclude='*' "$source_dir" "$destination_dir"/
