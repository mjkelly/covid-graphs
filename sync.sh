#!/bin/bash
set -u
set -e
cfg=$HOME/.aws/config
profile=mkorg-scratch
bucket=s3://scratch.michaelkelly.org/covid-report
dir=covid-report
scripts=$(dirname $0)

exec 1> >(logger -s -t $(basename $0)) 2>&1
echo "Beginning covid-graph run"

which aws || (echo "'aws' command not found. Aborting."; exit 2)
[ -f $cfg ] || (echo "Config file $cfg does not exist. Aborting."; exit 2)

cd "$scripts"
mkdir -p "$dir"
make update-pngs report REPORT_DIR="$dir"
aws --profile="$profile" \
  s3 sync "$dir" "$bucket" \
  --acl=public-read --cache-control=max-age=3600
echo "Finished covid-graph run successfully"
