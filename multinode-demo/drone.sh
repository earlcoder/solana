#!/usr/bin/env bash
#
# Starts an instance of solana-drone
#
here=$(dirname "$0")

# shellcheck source=multinode-demo/common.sh
source "$here"/common.sh

usage() {
  if [[ -n $1 ]]; then
    echo "$*"
    echo
  fi
  echo "usage: $0]"
  echo
  echo " Run an airdrop drone"
  echo
  exit 1
}

[[ -f "$SOLANA_CONFIG_PRIVATE_DIR"/mint.json ]] || {
  echo "$SOLANA_CONFIG_PRIVATE_DIR/mint.json not found, create it by running:"
  echo
  echo "  ${here}/setup.sh -t leader"
  exit 1
}

set -ex

trap 'kill "$pid" && wait "$pid"' INT TERM
$solana_drone \
  --keypair "$SOLANA_CONFIG_PRIVATE_DIR"/mint.json \
  > >($drone_logger) 2>&1 &
pid=$!
wait "$pid"
