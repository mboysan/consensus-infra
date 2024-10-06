#!/bin/bash

export INFLUX_ORG="myorg"

# clientmetrics bucket already exists, skipping.
#influx bucket create -n "clientmetrics" -o "$INFLUX_ORG"

# create the storemetrics bucket.
influx bucket create -n "storemetrics" -o "$INFLUX_ORG"
