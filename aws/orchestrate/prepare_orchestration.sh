#!/bin/bash

# NB! Assuming the script is run from the orchestrate directory, we go to the parent
cd ..

# prepare the environment variables and additional config
source ./env_setup.sh

function installJq() {
 # we need the jq library for parsing json outputs
 sudo apt-get update
 sudo apt-get install -y jq
}
installJq

tmpDir=/tmp

# check if we tmp dir is writable
if [ ! -w "$tmpDir" ]; then
    echo "[ERROR] tmp dir is not writable"
    exit 1
fi

# check if ansible inventory file exists
if [ ! -f "$ANSIBLE_INVENTORY_FILE" ]; then
    echo "[ERROR] ansible inventory file doesn't exist"
    exit 1
fi

if [ ! -d "$TERRAFORM_WORKING_DIR" ]; then
    echo "[ERROR] terraform working dir doesn't exist"
    exit 1
fi

# switch to terraform working dir
cd "$TERRAFORM_WORKING_DIR" || exit 1

function populateClientsInventory() {
    echo "[INFO] adding clients"

    # a temporary file for terraform output
    local clientsTmpJsonFile=$tmpDir/clients.json

    # get output from terraform
    terraform output -json client > $clientsTmpJsonFile

    # get inventory variables
    clientName=$(jq -r '.ec2_instance[0] | (.tags.Name)' $clientsTmpJsonFile)
    clientPublicIp=$(jq -r '.ec2_instance[0] | (.public_ip)' $clientsTmpJsonFile)

    echo "[INFO] group=clients, name=$clientName, public_ip=$clientPublicIp"

    # populate clients group
    echo "[client]" >> "$ANSIBLE_INVENTORY_FILE"
    echo "$clientPublicIp" >> "$ANSIBLE_INVENTORY_FILE"
    echo "" >> "$ANSIBLE_INVENTORY_FILE"

    # populate clients children
    echo "[clients:children]" >> "$ANSIBLE_INVENTORY_FILE"
    echo "$clientName" >> "$ANSIBLE_INVENTORY_FILE"
    echo "" >> "$ANSIBLE_INVENTORY_FILE"
}

# a tmp variable for node destinations used by everyone
nodeDestinationsTmp=$tmpDir/ndt
echo "" > $nodeDestinationsTmp

# a tmp variable for store destinations used by clients
storeDestinationsTmp=$tmpDir/sdt
echo "" > $storeDestinationsTmp

# a tmp variable for nodes that will act as key-value store
storeNodesTmp=$tmpDir/snt
echo "" > $storeNodesTmp

function populateNodesInventory() {
    echo "[INFO] adding nodes"

    nodeIdToUseAsStore=$1

    # a temporary file for terraform output
    nodesTmpJsonFile=$tmpDir/nodes.json

    # get output from terraform
    terraform output -json nodes > /tmp/nodes.json

    # some tmp files for holding variables to get around sub-shell issues inside jq loop
    local nodesChildrenTmp=$tmpDir/nct
    echo "" > $nodesChildrenTmp

    # get inventory variables
    jq -c '.[] | .[]' $nodesTmpJsonFile | while read -r i; do
        nodeName=$(echo "$i" | jq -r '.[0] | .tags.Name')
        nodeIndex=$(echo "$i" | jq -r '.[0] | .tags.Index')
        nodePublicIp=$(echo "$i" | jq -r '.[0] | .public_ip')
        nodePrivateIp=$(echo "$i" | jq -r '.[0] | .private_ip')

        echo "[INFO] group=nodes, name=$nodeName, index=$nodeIndex, public_ip=$nodePublicIp, private_ip=$nodePrivateIp"

        # append node name to node children holder
        echo "$nodeName" >> "$nodesChildrenTmp"

        # append node destinations configuration
        echo "$nodeIndex-$nodePrivateIp:$NODE_SERVING_PORT" >> "$nodeDestinationsTmp"

        # append store destinations configuration
        if [ "$nodeIndex" -eq "$nodeIdToUseAsStore" ]; then
          echo "[INFO] using $nodeName as key-value store"
          echo "$nodeName" >> "$storeNodesTmp"
          echo "$nodeIndex-$nodePrivateIp:$CLIENT_SERVING_PORT" >> "$storeDestinationsTmp"
        fi

        # write to inventory file
        echo "[$nodeName]" >> "$ANSIBLE_INVENTORY_FILE"
        echo "$nodePublicIp" >> "$ANSIBLE_INVENTORY_FILE"
    done

    echo "" >> "$ANSIBLE_INVENTORY_FILE"

    # populate nodes children
    nodesChildren=$(tail -n +2 "$nodesChildrenTmp")
    echo "[nodes:children]" >> "$ANSIBLE_INVENTORY_FILE"
    echo "$nodesChildren" >> "$ANSIBLE_INVENTORY_FILE"

    echo "" >> "$ANSIBLE_INVENTORY_FILE"
}

function populateStoresInventory() {
    echo "[INFO] adding key-value stores"
    echo "[stores:children]" >> "$ANSIBLE_INVENTORY_FILE"
    storeNodes="$(xargs printf ',%s' < "$storeNodesTmp" | cut -b 2-)"
    echo "$storeNodes" >> "$ANSIBLE_INVENTORY_FILE"
    echo "" >> "$ANSIBLE_INVENTORY_FILE"
}

function populateWorkersInventory() {
    echo "[INFO] adding workers"

    echo "[workers:children]" >> "$ANSIBLE_INVENTORY_FILE"
    echo "nodes" >> "$ANSIBLE_INVENTORY_FILE"
    echo "clients" >> "$ANSIBLE_INVENTORY_FILE"
    echo "" >> "$ANSIBLE_INVENTORY_FILE"

    # populate variables
    echo "[workers:vars]" >> "$ANSIBLE_INVENTORY_FILE"
    nodeDestinations="$(xargs printf ',%s' < "$nodeDestinationsTmp" | cut -b 2-)"
    echo "workers_GROUP_node_destinations=$nodeDestinations" >> "$ANSIBLE_INVENTORY_FILE"
    storeDestinations="$(xargs printf ',%s' < "$storeDestinationsTmp" | cut -b 2-)"
    echo "workers_GROUP_store_destinations=$storeDestinations" >> "$ANSIBLE_INVENTORY_FILE"
    echo "" >> "$ANSIBLE_INVENTORY_FILE"
}

echo "[INFO] populating ansible inventory file"
echo "" > "$ANSIBLE_INVENTORY_FILE"
populateClientsInventory
populateNodesInventory 0
populateStoresInventory
populateWorkersInventory
