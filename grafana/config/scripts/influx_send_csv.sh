#!/bin/bash

export INFLUX_ORG="mboysan_org"

log () {
  echo "[$(date +"%Y-%m-%d %T")] $1"
}

parse_filename_array() {
  local filename="$1"
  local -n result=$2  # Use nameref for array reference

  IFS_BAK=$IFS
  IFS='.' read -ra result <<< "$filename"
  IFS=$IFS_BAK
}


write_client_metrics() {
  local filename="$1"
  parse_filename_array "$filename" fileMetadata

  workload="${fileMetadata[0]}"
  testName="${fileMetadata[1]}"

  log "Sending ${filename}"
  log "Workload: ${workload}"
  log "TestName: ${testName}"

  influx write \
  --bucket client_metrics_raw \
  --org ${INFLUX_ORG} \
  --precision ms \
  --file "$filename" \
  --format csv \
  --header "#constant measurement,client_metrics" \
  --header "#constant tag,filename,${filename}" \
  --header "#constant tag,tWorkload,${workload}" \
  --header "#constant tag,tName,${testName}" \
  --header "#constant tag,tId,${workload}.${testName}" \
  --header "metric|tag,timestamp|dateTime:number,value|double"
}

write_store_metrics() {
  local filename="$1"
  parse_filename_array "$filename" fileMetadata

  workload="${fileMetadata[0]}"
  testName="${fileMetadata[1]}"

  log "Sending ${filename}"
  log "Workload: ${workload}"
  log "TestName: ${testName}"

  influx write \
  --bucket store_metrics \
  --org ${INFLUX_ORG} \
  --precision s \
  --file "$filename" \
  --format csv \
  --header "#constant measurement,store_metrics" \
  --header "#constant tag,filename,${filename}" \
  --header "#constant tag,tWorkload,${workload}" \
  --header "#constant tag,tName,${testName}" \
  --header "#constant tag,tId,${workload}.${testName}" \
  --header "metric|tag,value|double,timestamp|dateTime:number"
}

pushd /var/log
#pushd ../../metrics/

log "Sending all client raw metrics to influxdb ..."
for filename in ./*.client.raw.csv; do
  write_client_metrics $(basename "$filename")
done

log "Sending all store metrics to influxdb ..."
for filename in ./*.store.*.csv; do
  write_store_metrics $(basename "$filename")
done

log "done"

popd

#
#influx write \
#--bucket client_metrics_raw \
#--org mboysan_org \
#--precision ms \
#--file /var/log/W0.T1.client.raw.csv \
#--format csv \
#--header "#constant measurement,client_metrics" \
#--header "#constant tag,filename,W0.T1.client.raw.csv" \
#--header "#constant tag,tWorkload,W0" \
#--header "#constant tag,tName,T1" \
#--header "#constant tag,tId,W0.T1" \
#--header "metric|tag,timestamp|dateTime:number,value|double"
#
#influx write \
#--bucket client_metrics_raw \
#--org mboysan_org \
#--precision ms \
#--file /var/log/W0.T2.client.raw.csv \
#--format csv \
#--header "#constant measurement,client_metrics" \
#--header "#constant tag,filename,W0.T2.client.raw.csv" \
#--header "#constant tag,tWorkload,W0" \
#--header "#constant tag,tName,T2" \
#--header "#constant tag,tId,W0.T2" \
#--header "metric|tag,timestamp|dateTime:number,value|double"
#
#influx write \
#--bucket client_metrics_raw \
#--org mboysan_org \
#--precision ms \
#--file /var/log/W2.T1.client.raw.csv \
#--format csv \
#--header "#constant measurement,client_metrics" \
#--header "#constant tag,filename,W2.T1.client.raw.csv" \
#--header "#constant tag,tWorkload,W2" \
#--header "#constant tag,tName,T1" \
#--header "#constant tag,tId,W2.T1" \
#--header "metric|tag,timestamp|dateTime:number,value|double"
#
#influx write \
#--bucket client_metrics_raw \
#--org mboysan_org \
#--precision ms \
#--file /var/log/W2.T2.client.raw.csv \
#--format csv \
#--header "#constant measurement,client_metrics" \
#--header "#constant tag,filename,W2.T2.client.raw.csv" \
#--header "#constant tag,tWorkload,W2" \
#--header "#constant tag,tName,T2" \
#--header "#constant tag,tId,W2.T2" \
#--header "metric|tag,timestamp|dateTime:number,value|double"
