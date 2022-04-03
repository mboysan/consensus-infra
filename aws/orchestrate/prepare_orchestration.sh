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
    echo "tmp dir is not writable"
    exit 1
fi

# check if ansible inventory file exists
if [ ! -f "$ANSIBLE_INVENTORY_FILE" ]; then
    echo "ansible inventory file doesn't exist"
    exit 1
fi

if [ ! -d "$TERRAFORM_WORKING_DIR" ]; then
    echo "terraform working dir doesn't exist"
    exit 1
fi

# switch to terraform working dir
cd "$TERRAFORM_WORKING_DIR" || exit 1

function populateClientsInventory() {
    # a temporary file for terraform output
    local clientsTmpJsonFile=$tmpDir/clients.json

    # get output from terraform
    terraform output -json client > $clientsTmpJsonFile

    # get inventory variables
    clientsGroup=$(jq -r '.ec2_instance[0] | (.tags.Group)' $clientsTmpJsonFile)
    clientName=$(jq -r '.ec2_instance[0] | (.tags.Name)' $clientsTmpJsonFile)
    clientPublicIp=$(jq -r '.ec2_instance[0] | (.public_ip)' $clientsTmpJsonFile)

    echo "group=$clientsGroup, name=$clientName, public_ip=$clientPublicIp"

    echo "[$clientName]" >> "$ANSIBLE_INVENTORY_FILE"
    echo "$clientPublicIp" >> "$ANSIBLE_INVENTORY_FILE"
    echo "" >> "$ANSIBLE_INVENTORY_FILE"
    echo "[$clientsGroup:children]" >> "$ANSIBLE_INVENTORY_FILE"
    echo "$clientName" >> "$ANSIBLE_INVENTORY_FILE"
    echo "" >> "$ANSIBLE_INVENTORY_FILE"
}

function populateNodesInventory() {
  # a temporary file for terraform output
    nodesTmpJsonFile=$tmpDir/nodes.json

    # get output from terraform
    terraform output -json nodes > /tmp/nodes.json

    # some tmp files for holding variables to get around sub-shell issues inside jq loop
    local nodesGroupTmp=$tmpDir/ngt
    echo "" > $nodesGroupTmp
    local nodesChildrenTmp=$tmpDir/nct
    echo "" > $nodesChildrenTmp
    local nodesTargetsTmp=$tmpDir/ntt
    echo "" > $nodesTargetsTmp

    # get inventory variables
    jq -c '.[] | .[]' $nodesTmpJsonFile | while read -r i; do
        nodesGroup=$(echo "$i" | jq -r '.[0] | .tags.Group')
        nodeName=$(echo "$i" | jq -r '.[0] | .tags.Name')
        nodeIndex=$(echo "$i" | jq -r '.[0] | .tags.Index')
        nodePublicIp=$(echo "$i" | jq -r '.[0] | .public_ip')
        nodePrivateIp=$(echo "$i" | jq -r '.[0] | .private_ip')

        echo "group=$nodesGroup, name=$nodeName, index=$nodeIndex, public_ip=$nodePublicIp, private_ip=$nodePrivateIp"
        echo "$nodesGroup" > $nodesGroupTmp

        # append node name to nodes children array
        echo "$nodeName" >> "$nodesChildrenTmp"

        # append target node configuration to targets array
        echo "$nodeIndex-$nodePrivateIp:$NODE_SERVING_PORT" >> "$nodesTargetsTmp"

        # write to inventory file
        echo "[$nodeName]" >> "$ANSIBLE_INVENTORY_FILE"
        echo "$nodePublicIp" >> "$ANSIBLE_INVENTORY_FILE"
    done

    echo "" >> "$ANSIBLE_INVENTORY_FILE"

    nodesGroup=$(cat "$nodesGroupTmp")
    nodesChildren=$(tail -n +2 "$nodesChildrenTmp")
    echo "[$nodesGroup:children]" >> "$ANSIBLE_INVENTORY_FILE"
    echo "$nodesChildren" >> "$ANSIBLE_INVENTORY_FILE"

    echo "" >> "$ANSIBLE_INVENTORY_FILE"

    targetNodes="$(xargs printf ',%s' < "$nodesTargetsTmp" | cut -b 2-)"
    echo "[$nodesGroup:vars]" >> "$ANSIBLE_INVENTORY_FILE"
    echo "transport.tcp.destinations=$targetNodes" >> "$ANSIBLE_INVENTORY_FILE"
    echo "" >> "$ANSIBLE_INVENTORY_FILE"
}

function populateWorkersInventory() {
    echo "[workers:children]" >> "$ANSIBLE_INVENTORY_FILE"
    echo "nodes" >> "$ANSIBLE_INVENTORY_FILE"
    echo "clients" >> "$ANSIBLE_INVENTORY_FILE"
    echo "" >> "$ANSIBLE_INVENTORY_FILE"
}

# finally, populate the ansible inventory
echo "" > "$ANSIBLE_INVENTORY_FILE"
populateClientsInventory
populateNodesInventory
populateWorkersInventory