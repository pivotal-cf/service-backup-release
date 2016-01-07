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

for v in AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY BOSH_KEY_RELATIVE_PATH BOSH_HOST BOSH_USERNAME BOSH_PASSWORD BOSH_MANIFEST_RELATIVE_PATH
do
  mustHave $v
done

export BOSH_PRIVATE_KEY_FILE=$PWD/$BOSH_KEY_RELATIVE_PATH
export BOSH_MANIFEST=$PWD/$BOSH_MANIFEST_RELATIVE_PATH

for file in $BOSH_PRIVATE_KEY_FILE $BOSH_PRIVATE_KEY_FILE
do
  if [ ! -f $file ]; then
    echo "$file must exist" >&2
    exit 1
  fi
done

chmod 400 $BOSH_PRIVATE_KEY_FILE # TODO do we need this?

cd service-backup-release
export GOPATH=$PWD
export PATH=$PATH:$GOPATH/bin
go install github.com/onsi/ginkgo/ginkgo

cd src/github.com/pivotal-cf-experimental/service-backup/release_tests
ginkgo
