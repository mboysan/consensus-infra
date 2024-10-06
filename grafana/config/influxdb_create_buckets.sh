#!/bin/bash

export INFLUX_ORG="mboysan_org"

influx bucket create -n "client_metrics_raw" -o "$INFLUX_ORG"
influx bucket create -n "client_metrics_summary" -o "$INFLUX_ORG"
influx bucket create -n "store_metrics" -o "$INFLUX_ORG"
