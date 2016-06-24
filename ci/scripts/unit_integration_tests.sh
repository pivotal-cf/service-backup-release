#!/bin/bash

set -e

service ssh start

mkdir -p ~/.ssh

MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# This script expects to live two directories below the base directory.
BASE_DIR="$( cd "${MY_DIR}/../.." && pwd )"

AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:?}"
AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:?}"
AWS_ACCESS_KEY_ID_RESTRICTED="${AWS_ACCESS_KEY_ID_RESTRICTED:?}"
AWS_SECRET_ACCESS_KEY_RESTRICTED="${AWS_SECRET_ACCESS_KEY_RESTRICTED:?}"
AZURE_STORAGE_ACCOUNT="${AZURE_STORAGE_ACCOUNT:?}"
AZURE_STORAGE_ACCESS_KEY="${AZURE_STORAGE_ACCESS_KEY:?}"


export GOPATH=${BASE_DIR}
export PATH=${GOPATH}/bin:${PATH}

pushd "${BASE_DIR}"
  bundle install
  bundle exec rspec

  go install github.com/onsi/ginkgo/ginkgo
  ./src/github.com/pivotal-cf-experimental/service-backup/scripts/test_integration
popd
