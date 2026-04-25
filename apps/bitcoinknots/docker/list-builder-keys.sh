#!/bin/bash
set -e

urls=$(curl -s "https://api.github.com/repos/bitcoinknots/guix.sigs/contents/builder-keys" | jq -r '.[].download_url')
export GNUPGHOME=$(mktemp -d)

for url in $urls; do
    curl -s "$url" | gpg --batch --import >/dev/null 2>&1
done

gpg --with-colons --list-keys | awk -F: '$1 == "pub" {getline; if ($1 == "fpr") print $10}'
rm -rf "$GNUPGHOME"
