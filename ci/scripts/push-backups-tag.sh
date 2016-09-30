#!/bin/bash -eu
set -o pipefail

RELEASE_DIR=$(pwd)/backups-final-tag
BACKUPS_DIR=$RELEASE_DIR/src/github.com/pivotal-cf-experimental/service-backup
TAG_DIR=$(pwd)/backups-with-tag

RELEASE_TAG="$(git -C "$RELEASE_DIR" tag --list 'v*' --contains HEAD)"
git -C "$BACKUPS_DIR" tag "$RELEASE_TAG"
git clone "$BACKUPS_DIR" "$TAG_DIR"
