#!/bin/bash

echo "Stopping containers..."
docker compose down

echo "Removing volumes..."
docker volume prune -f
docker volume rm grafana_grafana_data
docker volume rm grafana_influxdb_data
