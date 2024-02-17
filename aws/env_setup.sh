#!/bin/bash

export LC_ALL="C.UTF-8";

CURRENT_DIR=$(pwd)

function checkExecutionDirectory() {
  if [ ! -f "$1" ]; then
    echo "executing this script from the wrong directory, exiting..."
    exit 1
  fi
}
# you might want to rename the file being checked
checkExecutionDirectory "$CURRENT_DIR/env_setup.sh"

# see https://www.geeksforgeeks.org/histcontrol-command-in-linux-with-examples/
export HISTCONTROL=ignorespace

# Project related variables
 # port that the nodes participating in consensus protocol exchanges use to accept other nodes to connect
 export NODE_SERVING_PORT=33330
 # port that the kv stores use to accept clients to connect
 export CLIENT_SERVING_PORT=33331
 # port for graphite to bind to serve web browsers
 export GRAPHITE_WEB_PORT=33330
 # port for graphite to bind to serve netcat requests
 export GRAPHITE_NC_PORT=33331
 # reserve some more ports just in case
 export RESERVED_PORT_START=$NODE_SERVING_PORT
 export RESERVED_PORT_END=$((CLIENT_SERVING_PORT + 4))
 # reserved node-id that will be used as the KV Store, other nodes will only be started as nodes that participate
 # in consensus mechanism.
 export NODE_ID_TO_USE_AS_STORE=2

# AWS credentials and properties
 # the aws profile used in aws/credentials file.
 export AWS_PROFILE=consensus
 # if you define a region parameter in aws/credentials file, this variable should align with that.
 export AWS_REGION=eu-west-1
 export AWS_DEFAULT_REGION=$AWS_REGION
 # if you define a region parameter in aws/credentials file, this variable should align with that.
 export AWS_DEFAULT_AVAILABILITY_ZONE=eu-west-1a
 # Ubuntu-20.04, note that Amazon might regularly update this id, so feel free to insert the most recent one. But
 # keep in mind that package manager and firewall alterations requires certain packages. So, we suggest you stick with
 # this Ubuntu version for now. Also note that ami ids depend on the aws region as well.
 export AWS_AMI_ID="ami-08031206a0ff5a6ac"

# Terraform variables
 export TERRAFORM_WORKING_DIR=$CURRENT_DIR/provision
 export TF_VAR_reserved_port_start=$RESERVED_PORT_START
 export TF_VAR_reserved_port_end=$RESERVED_PORT_END
 export TF_VAR_aws_profile=$AWS_PROFILE
 export TF_VAR_aws_region=$AWS_REGION
 export TF_VAR_aws_availability_zone=$AWS_DEFAULT_AVAILABILITY_ZONE
 export TF_VAR_aws_ec2_ami_id=$AWS_AMI_ID
 export TF_VAR_aws_ec2_ssh_public_key_path=$TERRAFORM_WORKING_DIR/access/aws_instance_key.pub

# Packer variables
 export PKR_VAR_aws_profile=$AWS_PROFILE
 export PKR_VAR_aws_region=$AWS_REGION
 export PKR_VAR_aws_availability_zone=$AWS_DEFAULT_AVAILABILITY_ZONE
 export PKR_VAR_aws_ec2_ami_name=$AWS_AMI_NAME

# Ansible variables
 export ANSIBLE_WORKING_DIR=$CURRENT_DIR/orchestrate
 export ANSIBLE_CONFIG=$ANSIBLE_WORKING_DIR/ansible.cfg
 # use the private key to allow ansible connect to ec2 instances.
 # to create key pairs for instances, see: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html
 export ANSIBLE_PRIVATE_KEY_FILE="~/.ssh/aws/aws_instance_key.pem"
 export ANSIBLE_INVENTORY_FILE=$ANSIBLE_WORKING_DIR/inventory/aws_ec2_static.ini

 # Controller specific environment variables
 # The path where the collected data from instances will be stored.
 export COLLECTED_DATA_PATH=$ANSIBLE_WORKING_DIR/playbooks/collected_data
 export COLLECTED_LOGS_PATH=$COLLECTED_DATA_PATH/logs
 export COLLECTED_METRICS_PATH=$COLLECTED_DATA_PATH/metrics
