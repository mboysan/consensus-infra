#!/bin/bash

set -m

SERVER_NAME="{{ _server_name }}"
echo "on server=$SERVER_NAME"

NODE_ID=$(echo $SERVER_NAME | tr -dc '0-9')
echo "node id=$NODE_ID"

STORE_ID="{{ lookup('env','NODE_ID_TO_USE_AS_STORE') | mandatory }}"
echo "store id=$STORE_ID"

CONDITION="{{ _condition }}"
echo "condition='$CONDITION'"

PORT="{{ nodes_GROUP_node_serving_port }}"
DELAY_SEC="{{ delay_sec | default(0) }}"
DURATION_SEC="{{ duration_sec | default(0) }}"

CURR_DIR=$(pwd)
NETWORK_SCRIPT_DIR="{{ _home_dir }}"
CONSENSUS_PROJ_DIR="{{ nodes_GROUP_working_dir }}"

if [ $NODE_ID = $STORE_ID ]; then
  echo "I am the store, exiting."
  exit 0
fi

sendCommand() {
  cd $CONSENSUS_PROJ_DIR
  routeTo=$1
  java \
    -cp *.jar \
    com.mboysan.consensus.KVStoreClientCLI {{ _mandatory_params }} cmd=checkIntegrity level=1 to=$routeTo > /tmp/sendCommand.out 2>&1
  cd $CURR_DIR
}

sendCommand $NODE_ID
result=$(cat /tmp/sendCommand.out)

PROTOCOL=$(echo $result | grep -oP 'protocol=\K[^ ]+' | tr -d "'" | tr -d ",")
echo "protocol=$PROTOCOL"
echo $PROTOCOL

ROLE=$(echo $result | grep -oP 'role=\K[^ ]+'| tr -d "'" | tr -d ",")
echo "role=$ROLE"


disconnect() {
  # manipulate network firewall
  cd $NETWORK_SCRIPT_DIR
  ./network_partition.sh disconnect --port "$PORT" --delay "$DELAY_SEC" --duration "$DURATION_SEC"
  cd $CURR_DIR
}

if [ "$PROTOCOL" = "raft" ]; then
  echo "protocol is raft, checking conditions..."
  if [ "$CONDITION" = "disconnect leader" ]; then
    echo "condition is disconnect leader"
    if [ "$ROLE" = "LEADER" ]; then
      echo "I am the leader. Disconnecting..."
      disconnect
    else
      echo "I am the follower. exiting."
      exit 0
    fi
  else
    echo "condition is disconnect follower"
    if [ "$ROLE" = "LEADER" ]; then
      echo "I am the leader. exiting."
      exit 0
    else
      echo "I am the follower. Disconnecting..."
      disconnect
    fi
  fi
else
  echo "protocol is not raft, selecting nodeId to disconnect..."
  nodeIdToDisconnect=0
  if [ STORE_ID = 0]; then
    nodeIdToDisconnect=1
  fi
  echo "nodeIdToDisconnect=$nodeIdToDisconnect"

  if [ $NODE_ID = $nodeIdToDisconnect ]; then
    echo "I am the node to disconnect. Disconnecting..."
    disconnect
  else
    echo "I am not the node to disconnect. exiting."
    exit 0
  fi
fi
