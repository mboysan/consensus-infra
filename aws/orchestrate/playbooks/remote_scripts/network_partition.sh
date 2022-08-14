#!/bin/bash

function info() {
    echo "$(date +"%Y-%m-%d %T") [INFO] $1"
}

function iptablesStatus() {
  info "iptables status:"
  sudo iptables -L INPUT -n -v
  sudo iptables -L OUTPUT -n -v
}

function disconnect() {
  port="$1"
  sudo iptables -A INPUT -p tcp --destination-port "$port" -j REJECT
  sudo iptables -A OUTPUT -p tcp --destination-port "$port" -j REJECT
  info "disconnected I/O for tcp port=$port"
  iptablesStatus
}

function restore() {
  sudo iptables -F
  info "restored firewall settings"
  iptablesStatus
}

command="$1"
#--port
portPlaceholder="$2"
port="$3"
#--delay
delayPlaceholder="$4"
delay="$5"
#--duration
durationPlaceholder="$6"
duration="$7"

if [ "$command" == "disconnect" ]; then
  info "disconnecting port $port with delay $delay seconds"
  sleep "$delay"
  disconnect "$port"
  if [ "$durationPlaceholder" == "--duration" ]; then
    if [ "$duration" == "0" ]; then
      exit 0;
    fi
    info "restoring network in $duration seconds"
    sleep "$duration"
    restore
    info "done"
  fi
elif [ "$command" == "restore" ]; then
  info "restoring network"
  restore
fi

# To enable firewall for a port for a provided period of time with delay:
# ./network_partition.sh disconnect --port <tcp_port> --delay <delay_in_seconds> --duration <time_in_seconds>

# To enable firewall for a port indefinitely:
# ./network_partition.sh disconnect --port <tcp_port> --delay 0
# ./network_partition.sh disconnect --port <tcp_port> --delay 0 --duration 0

# To restore the firewall
# ./network_partition.sh restore