#!/bin/bash

# NB! Assuming the script is run from the orchestrate directory, we go to the parent
cd ..

# prepare the environment variables and additional config
source ./env_setup.sh

function installJq() {
    echo "[INFO] super user permissions are required to install package 'jq'"
    # we need the jq library for parsing json outputs
    sudo apt-get update
    echo "[INFO] installing package 'jq'..."
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

processorPrivateIpTmp=$tmpDir/ppi
truncate -s 0 $processorPrivateIpTmp

function populateProcessorsInventory() {
    # create clients group
    echo "[INFO] creating 'processors' group"

    echo "[processors]" >> "$ANSIBLE_INVENTORY_FILE"

    # a temporary file for terraform output
    local processorsTmpJsonFile=$tmpDir/processors.json

    # get output from terraform
    terraform output -json processor > $processorsTmpJsonFile

    # get inventory variables
    processorName=$(jq -r '.ec2_instance[0] | (.tags.Name)' $processorsTmpJsonFile)
    processorPublicIp=$(jq -r '.ec2_instance[0] | (.public_ip)' $processorsTmpJsonFile)
    processorPrivateIp=$(jq -r '.ec2_instance[0] | (.private_ip)' $processorsTmpJsonFile)

    # populate clients group
    echo "[INFO] group=processors, name=$processorName, public_ip=$processorPublicIp, private_ip=$processorPrivateIp"
    echo "processor ansible_host=$processorPublicIp" >> "$ANSIBLE_INVENTORY_FILE"
    echo "" >> "$ANSIBLE_INVENTORY_FILE"

    echo "$processorPrivateIp" >> "$processorPrivateIpTmp"
}

function populateClientsInventory() {
    # create clients group
    echo "[INFO] creating 'clients' group"

    echo "[clients]" >> "$ANSIBLE_INVENTORY_FILE"

    # a temporary file for terraform output
    local clientsTmpJsonFile=$tmpDir/clients.json

    # get output from terraform
    terraform output -json client > $clientsTmpJsonFile

    # get inventory variables
    clientName=$(jq -r '.ec2_instance[0] | (.tags.Name)' $clientsTmpJsonFile)
    clientPublicIp=$(jq -r '.ec2_instance[0] | (.public_ip)' $clientsTmpJsonFile)

    # populate clients group
    echo "[INFO] group=clients, name=$clientName, public_ip=$clientPublicIp"
    echo "client ansible_host=$clientPublicIp" >> "$ANSIBLE_INVENTORY_FILE"
    echo "" >> "$ANSIBLE_INVENTORY_FILE"
}

# a tmp variable for node destinations used by workers (for consensus)
nodeDestinationsTmp=$tmpDir/ndt
truncate -s 0 $nodeDestinationsTmp

# a tmp variable for node destinations used by workers (for etcd)
etcdNodeDestinationsTmp=$tmpDir/endt
truncate -s 0 $etcdNodeDestinationsTmp

# a tmp variable for store destinations used by clients
storeDestinationsTmp=$tmpDir/sdt
truncate -s 0 $storeDestinationsTmp

# a tmp variable for peer destinations used by etcd
etcdStoreDestinationsTmp=$tmpDir/epdt
truncate -s 0 $etcdStoreDestinationsTmp

# a tmp variable for nodes that will act as key-value store
storeNodesTmp=$tmpDir/snt
truncate -s 0 $storeNodesTmp

totalNodeCount=0
totalNodeCountTmp=$tmpDir/tnc
truncate -s 0 $totalNodeCountTmp

function populateNodesInventory() {
    # create nodes group
    echo "[INFO] creating 'nodes' group"

    echo "[nodes]" >> "$ANSIBLE_INVENTORY_FILE"

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

        # append node destinations configuration (for consensus project)
        echo "$nodeIndex-$nodePrivateIp:$NODE_SERVING_PORT" >> "$nodeDestinationsTmp"

        # append node destinations configuration (for etcd project)
        echo "$nodeName=http://$nodePrivateIp:$NODE_SERVING_PORT" >> "$etcdNodeDestinationsTmp"

        # append store destinations configuration
        if [ "$nodeIdToUseAsStore" -eq -1 ] || [ "$nodeIndex" -eq "$nodeIdToUseAsStore" ]; then
          echo "[INFO] using $nodeName as key-value store"
          echo "$nodeName" >> "$storeNodesTmp"

          # append store destinations configuration (for consensus project)
          echo "$nodeIndex-$nodePrivateIp:$CLIENT_SERVING_PORT" >> "$storeDestinationsTmp"

          # append store destinations configuration (for etcd project)
          echo "$nodeName=http://$nodePrivateIp:$CLIENT_SERVING_PORT" >> "$etcdStoreDestinationsTmp"
        fi

        # write to inventory file
        echo "$nodeName ansible_host=$nodePublicIp" >> "$ANSIBLE_INVENTORY_FILE"

        totalNodeCount=$((totalNodeCount+1))
        echo "$totalNodeCount" > "$totalNodeCountTmp"
    done

    echo "[INFO] total node count = $(xargs printf ',%s' < "$totalNodeCountTmp" | cut -b 2-)"
    echo "" >> "$ANSIBLE_INVENTORY_FILE"
}

function populateStoresInventory() {
    # create stores group
    echo "[INFO] creating 'stores' group"

    echo "[stores]" >> "$ANSIBLE_INVENTORY_FILE"
    cat "$storeNodesTmp" >> "$ANSIBLE_INVENTORY_FILE"
    echo "" >> "$ANSIBLE_INVENTORY_FILE"
}

function populateWorkersInventory() {
    # create workers group
    echo "[INFO] creating 'workers' group with children"

    echo "[workers:children]" >> "$ANSIBLE_INVENTORY_FILE"
    echo "nodes" >> "$ANSIBLE_INVENTORY_FILE"
    echo "clients" >> "$ANSIBLE_INVENTORY_FILE"
    echo "" >> "$ANSIBLE_INVENTORY_FILE"

    # populate variables
    echo "[workers:vars]" >> "$ANSIBLE_INVENTORY_FILE"
    nodeDestinations="$(xargs printf ',%s' < "$nodeDestinationsTmp" | cut -b 2-)"
    echo "workers_GROUP_node_destinations=$nodeDestinations" >> "$ANSIBLE_INVENTORY_FILE"
    etcdNodeDestinations="$(xargs printf ',%s' < "$etcdNodeDestinationsTmp" | cut -b 2-)"
    echo "workers_GROUP_etcd_node_destinations=$etcdNodeDestinations" >> "$ANSIBLE_INVENTORY_FILE"
    storeDestinations="$(xargs printf ',%s' < "$storeDestinationsTmp" | cut -b 2-)"
    echo "workers_GROUP_store_destinations=$storeDestinations" >> "$ANSIBLE_INVENTORY_FILE"
    etcdStoreDestinations="$(xargs printf ',%s' < "$etcdStoreDestinationsTmp" | cut -b 2-)"
    echo "workers_GROUP_etcd_store_destinations=$etcdStoreDestinations" >> "$ANSIBLE_INVENTORY_FILE"
    processorPrivateIp="$(xargs printf ',%s' < "$processorPrivateIpTmp" | cut -b 2-)"
    echo "workers_GROUP_processor_destination=$processorPrivateIp" >> "$ANSIBLE_INVENTORY_FILE"
    totalNodeCount=$(xargs printf ',%s' < "$totalNodeCountTmp" | cut -b 2-)
    echo "workers_GROUP_total_node_count=$totalNodeCount" >> "$ANSIBLE_INVENTORY_FILE"
    echo "" >> "$ANSIBLE_INVENTORY_FILE"
}

echo "[INFO] populating ansible inventory file"
echo "" > "$ANSIBLE_INVENTORY_FILE"
populateProcessorsInventory
populateClientsInventory
populateNodesInventory "$NODE_ID_TO_USE_AS_STORE"
populateStoresInventory
populateWorkersInventory
