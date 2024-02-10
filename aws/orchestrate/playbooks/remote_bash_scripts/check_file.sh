#!/bin/bash

#----------------------------------------------------------------------------------------------------------
# Script to check if a file exists
# run it as:
# ./check_file.sh <file-to-search>
#----------------------------------------------------------------------------------------------------------

file="$1"
while [[ true ]]; do
  if test -f $file; then
    echo "found"
    exit 0
  fi
  sleep 5
done
exit 0