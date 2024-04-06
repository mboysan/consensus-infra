#!/bin/bash

CONSUL_DIR="$HOME/consul"

nodeId={{ nodeId }}
nodeName="node$nodeId"
configDir="{{ nodes_GROUP_consul_config_dir }}/$nodeName"
consulPortGrpc={{ consulPortGrpc }}
consulPortSerfLan={{ consulPortSerfLan }}
consulPortServer={{ consulPortServer }}
consulPortHttp={{ consulPortHttp }}

read -r -d '' agentConfig << EOM
{
  "bootstrap_expect": {{ expected_number_of_nodes }},
  "client_addr": "0.0.0.0",
  "data_dir": "$configDir",
  "datacenter": "dc1",
  "node_name": "$nodeName",
  "leave_on_terminate": true,
  "log_level": "INFO",
  "rejoin_after_leave": true,
  "server": true,
  "ports": {
    "dns": -1,
    "grpc_tls": -1,
    "https": -1,
    "serf_wan": -1,
    "sidecar_min_port": 0,
    "sidecar_max_port": 0,
    "expose_min_port": 0,
    "expose_max_port": 0,
    "grpc": $consulPortGrpc,
    "serf_lan": $consulPortSerfLan,
    "server": $consulPortServer,
    "http": $consulPortHttp
  },
  "retry_join": {{ node_destinations_json_array }}
}
EOM

mkdir -p $configDir
echo -e "$agentConfig" > $configDir/config.json
