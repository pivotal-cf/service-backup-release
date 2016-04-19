#!/bin/bash -eu

for v in AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY GIT_SSH_KEY
do
  [[ -n "${!v:-}" ]] || { echo "must set $v" >&2; exit 1; }
done

OUTPUT_DIR="$(pwd)/final-tarball"

pushd $(dirname $0)/../..

sha_to_release=$(cat ../sha-to-release/service-backup-release.sha)
echo "releasing $sha_to_release"
git checkout "$sha_to_release"

release_version=$(( $(ls releases/service-backup | grep service-backup | wc -l) + 1 ))
git tag --force "v${release_version}"

# Avoid '--' being interpreted as an argument to printf
printf "%s-\nblobstore:\n  s3:\n    access_key_id: ${AWS_ACCESS_KEY_ID}\n    secret_access_key: ${AWS_SECRET_ACCESS_KEY}" "--" > config/private.yml
bosh -n create release --name service-backup --final --with-tarball
mv releases/service-backup/*.tgz "$OUTPUT_DIR/"

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

mkdir -p ~/.ssh
ssh-keyscan github.com >> ~/.ssh/known_hosts

git fetch
git rebase origin/master
git push origin HEAD:master

git push origin --tags
popd
