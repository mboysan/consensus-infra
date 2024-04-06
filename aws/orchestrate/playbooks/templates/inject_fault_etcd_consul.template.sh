#!/bin/bash

set -m

SERVER_NAME="{{ _server_name }}"
echo "on server=$SERVER_NAME"

NODE_ID=$(echo $SERVER_NAME | tr -dc '0-9')
echo "node id=$NODE_ID"

STORE_ID="{{ lookup('env','NODE_ID_TO_USE_AS_STORE') | mandatory }}"
echo "store id=$STORE_ID"

PORT="{{ nodes_GROUP_node_serving_port }}"
DELAY_SEC="{{ delay_sec | default(0) }}"
DURATION_SEC="{{ duration_sec | default(0) }}"

CURR_DIR=$(pwd)
NETWORK_SCRIPT_DIR="{{ _home_dir }}"

if [ $NODE_ID = $STORE_ID ]; then
  echo "I am the store, exiting."
  exit 0
fi

disconnect() {
  # manipulate network firewall
  cd $NETWORK_SCRIPT_DIR
  ./network_partition.sh disconnect --port "$PORT" --delay "$DELAY_SEC" --duration "$DURATION_SEC"
  cd $CURR_DIR
}

echo "On etcd cluster, selecting nodeId to disconnect..."
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