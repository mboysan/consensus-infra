#!/bin/bash

echo $(ip addr show eth0 | awk '$1 == "inet" {sub(/\/.*$/, "", $2); print $2}')
