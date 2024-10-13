#!/bin/bash

echo "Copying grafana dashboards..."
docker cp grafana:/var/lib/grafana/dashboards/dashboard-main.json ./config/grafana_dashboards/work/dashboard-main-$(date +%d%m%Y_%H%M).json

echo "Stopping containers..."
docker compose down

echo "Removing volumes..."
docker volume prune -f
docker volume rm grafana_grafana_data
docker volume rm grafana_influxdb_data
