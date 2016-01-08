#!/bin/bash -e

mustHave() {
  var=$1
  shift

  if [ -z "${!var}" ]
  then
    echo "must set $var" >&2
    exit 1
  fi
}

for v in BOSH_URL BOSH_USERNAME BOSH_PASSWORD
do
  mustHave $v
done


bosh -n -t $BOSH_URL -u $BOSH_USERNAME -p $BOSH_PASSWORD delete deployment service-backup-ci
