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

for v in AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY GIT_SSH_KEY
do
  mustHave $v
done

pushd $(dirname $0)/../..

sha_to_release=$(cat ../sha-to-release/service-backup-release.sha)
echo "releasing $sha_to_release"
git checkout $sha_to_release

release_version=$(( $(ls releases/service-backup | grep service-backup | wc -l) + 1 ))
git tag "v${release_version}"

# Avoid '--' being interpreted as an argument to printf
printf "%s-\nblobstore:\n  s3:\n    access_key_id: ${AWS_ACCESS_KEY_ID}\n    secret_access_key: ${AWS_SECRET_ACCESS_KEY}" "--" > config/private.yml
bosh -n create release --name service-backup --final --with-tarball

key=/tmp/key
echo "$GIT_SSH_KEY" > $key
eval "$(ssh-agent)"
chmod 400 $key
ssh-add $key

git config --global user.email "cf-london-eng+enablement@pivotal.io"
git config --global user.name "CF Services Enablement CI server"
git add releases
git add .final_builds
git commit -m "Final release v${release_version} metadata"

git fetch
git rebase origin/develop
git push origin HEAD:develop

git push origin --tags
