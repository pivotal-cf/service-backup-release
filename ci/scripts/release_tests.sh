#!/bin/bash -eu

mustHave() {
  var=$1
  shift

  if [ -z "${!var:-}" ]
  then
    echo "must set $var" >&2
    exit 1
  fi
}

for v in AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AZURE_STORAGE_ACCOUNT AZURE_STORAGE_ACCESS_KEY BOSH_KEY_RELATIVE_PATH BOSH_HOST S3_BOSH_MANIFEST_RELATIVE_PATH AZURE_BOSH_MANIFEST_RELATIVE_PATH SCP_BOSH_MANIFEST_RELATIVE_PATH BOSH_CA_CERT_PATH BOSH_CLIENT BOSH_CLIENT_SECRET
do
  mustHave $v
done

export BOSH_PRIVATE_KEY_FILE=$PWD/$BOSH_KEY_RELATIVE_PATH
export S3_BOSH_MANIFEST=$PWD/$S3_BOSH_MANIFEST_RELATIVE_PATH
export AZURE_BOSH_MANIFEST=$PWD/$AZURE_BOSH_MANIFEST_RELATIVE_PATH
export SCP_BOSH_MANIFEST=$PWD/$SCP_BOSH_MANIFEST_RELATIVE_PATH

if [ ! -f $BOSH_PRIVATE_KEY_FILE ]; then
  echo "$file must exist" >&2
  exit 1
fi

export BOSH_CA_CERT_PATH=$(readlink -f $BOSH_CA_CERT_PATH)

cd service-backup-release
export GOPATH=$PWD
export PATH=$PATH:$GOPATH/bin
go install github.com/onsi/ginkgo/ginkgo

cd src/github.com/pivotal-cf-experimental/service-backup/release_tests
ginkgo
