#!/bin/bash

set -e

service ssh start

mkdir -p ~/.ssh
ssh-keyscan localhost >> ~/.ssh/known_hosts

MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# This script expects to live two directories below the base directory.
BASE_DIR="$( cd "${MY_DIR}/../.." && pwd )"

AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:?}"
AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:?}"

export GOPATH=${BASE_DIR}
export PATH=${GOPATH}/bin:${PATH}

pushd "${BASE_DIR}"
  go install github.com/onsi/ginkgo/ginkgo
  ./src/github.com/pivotal-cf-experimental/service-backup/scripts/test_integration
popd
