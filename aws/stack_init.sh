#!/bin/bash
# ---------------------------------------------
# Provisions the load testing stack.
# ---------------------------------------------

source env_setup.sh || exit 1

# ---------------------------------------------
cd "$TERRAFORM_WORKING_DIR" || exit 1

echo "[INFO] preparing terraform..."
# prepare terraform
terraform init

echo "[INFO] provisioning the stack..."
# provision the stack (asks for confirmation)
terraform apply

echo "[INFO] waiting 2 minutes for the stack to be ready..."
sleep 2m

# ---------------------------------------------
cd "$ANSIBLE_WORKING_DIR" || exit 1
./prepare_orchestration.sh

cd "$ANSIBLE_WORKING_DIR" || exit 1

echo "[INFO] setting up VM-s..."
ansible-playbook playbooks/P1_setup_vm.yaml

echo "[INFO] setting up the workers..."
ansible-playbook playbooks/P2_setup_workers.yaml

echo "[INFO] stack ready!"
