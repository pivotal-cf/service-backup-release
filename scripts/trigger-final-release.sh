#!/bin/bash -e

if [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "must set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY" >&2
  exit 1
fi

if [ -z "$1" ]; then
  echo "Usage: trigger-final-release.sh sha-to-release" >&2
  exit 1
fi

sha_to_release=$1
shift

sha_file=$PWD/service-backup-release.sha
function cleanup() {
  rm $sha_file
}
trap cleanup EXIT

echo $sha_to_release > $sha_file

aws s3 cp $sha_file s3://services-enablement-ci-triggers/
