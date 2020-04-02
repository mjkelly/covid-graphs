#!/bin/bash
set -u
set -e
cfg=$HOME/.aws/config
profile=mkorg-scratch
bucket=s3://scratch.michaelkelly.org
dir=covid-report
scripts=$(dirname $0)

which aws || (echo "'aws' command not found. Aborting."; exit 2)
[ -f $cfg ] || (echo "Config file $cfg does not exist. Aborting."; exit 2)

mkdir -p "$dir"
make update-pngs report REPORT_DIR="$dir"
aws --profile="$profile" \
  s3 sync "$dir" "$bucket" \
  --acl=public-read --cache-control=max-age=3600
