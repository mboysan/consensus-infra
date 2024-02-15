#!/bin/bash

#----------------------------------------------------------------------------------------------------------
# Script to check state of node/client/store. i.e, tries to find the given input from the log file
# run it as:
# ./check_state.sh "string-to-search" <file-to-search>
#----------------------------------------------------------------------------------------------------------

checkString="$1"
logFile="$2"
started=0
retries=10
while [[ $started != 1 ]]; do
  started=$(grep -Fc "$checkString" "$logFile")
  echo "state=$started ($retries retries left)"
  retries=$((retries-1))
  if [[ $retries == 0 ]]; then
    exit 1
  fi
  sleep 5
done
exit 0