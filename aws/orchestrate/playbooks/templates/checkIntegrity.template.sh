#!/bin/bash

set -m

VERBOSITY="{{ ansible_verbosity }}"

CURR_DIR=$(pwd)
CONSENSUS_PROJ_DIR="{{ nodes_GROUP_working_dir }}"

sendCommand() {
  cd $CONSENSUS_PROJ_DIR
  java \
    -cp *.jar \
    com.mboysan.consensus.KVStoreClientCLI {{ _mandatory_params }} cmd=checkIntegrity level={{ _level }} > /tmp/sendCommand.out 2>&1
  cd $CURR_DIR
}

sendCommand
result=$(cat /tmp/sendCommand.out)

if [ "$VERBOSITY" -gt 0 ]; then
  echo "$result"
fi

SUCCESS=$(echo $result | grep -oP 'success=\K[^ ]+' | tr -d "'" | tr -d ",")

if [ "$SUCCESS" = "true" ]; then
  echo "integrity check success"
  exit 0
else
  echo "integrity check failed"
  exit 1
fi
