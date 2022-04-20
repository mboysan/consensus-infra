#!/bin/bash

# ---------------------------------------------
# Destroys the load testing stack.
# ---------------------------------------------

source env_setup.sh || exit 1

cd provision || exit 1

echo "[INFO] destroying stack..."
# destroy provisioned environment (asks for confirmation)
terraform destroy

echo "[INFO] stack destroyed."