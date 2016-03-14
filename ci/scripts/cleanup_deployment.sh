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

for v in BOSH_URL BOSH_USERNAME BOSH_PASSWORD BOSH_DEPLOYMENT_NAMES
do
  mustHave $v
done

for BOSH_DEPLOYMENT_NAME in $BOSH_DEPLOYMENT_NAMES
do
  bosh -n -t $BOSH_URL -u $BOSH_USERNAME -p $BOSH_PASSWORD delete deployment $BOSH_DEPLOYMENT_NAME
done
