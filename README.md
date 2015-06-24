# service-backup-release
BOSH release of service backup tool

## Usage

This BOSH release is intended to be co-located with other releases that need to perform backups. This achieved by adding the following to your existing BOSH deployment manifest:

```yml
---
properties:
  service-backup:
    blobstore:
      bucket_name: replace-with-bucket-name-in-S3
      bucket_path: replace-with-bucket-path-in-S3
      access_key_id: replace-with-AWS-access-key
      secret_access_key: replace-with-AWS-secret-access-key

releases:
- name: my-existing-release
  version: latest
- name: service-backup
  version: latest

jobs:
- name: my-composite-job
  templates:
  - name: my-existing-job-template
    release: my-existing-release
  - name: service-backup
    release: service-backup
```

An exhaustive and up-to-date list of properties can be found in the [service-backup job spec](./jobs/service-backup/spec).

### Limitations

#### Co-location

The `service-backup` job in this release cannot be co-located with other jobs
that depend on packages with the same name, e.g. python. This is a restriction
in BOSH.

#### Bucket and Permissions

The provided bucket must already exist, and the required permissions are as
follows:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "service-backup-policy",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:ListMultipartUploadParts",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::MY_BUCKET_NAME/*",
        "arn:aws:s3:::MY_BUCKET_NAME"
      ]
    }
  ]
}
```

## Development

- Clone the repo:
```bash
git clone git@github.com:pivotal-cf-experimental/service-backup-release.git
```

- Ensure `direnv` is installed
 - E.g. via brew:
```bash
brew install direnv
```

- Install git hooks (e.g. a pre-commit hook to automatically configure the `spec` file for a BOSH package):
```bash
cd /path/to/bosh/release
./scripts/install-git-hooks
```

- Sync the submodules.
```bash
cd /path/to/bosh/release
./update
```

- Create your own standalone (i.e. not co-located) bosh-lite manifest:
```bash
cd /path/to/bosh/release
cp ./manifests/bosh-lite-deployment.yml.template  ./manifests/bosh-lite-deployment.yml
```
 and update the values of the properties specified in the first section.

- Deploy the standalone BOSH release to `bosh-lite`:
```bash
bosh target lite #or the alias/IP for your BOSH lite director
bosh deployment manifests/bosh-lite-deployment.yml
bosh create release --name service-backup
bosh upload release
bosh deploy
```

### Miscellaneous

Some information that might be useful to developers:

- The BOSH release directory serves as the `GOPATH`. The `$GOPATH` is automatically configured when you `cd` into the release directory via `direnv` and the `.envrc` file.

- When adding or removing submodules to the BOSH release, use the `sync-submodule-config` helper script as shown below:
```bash
cd /path/to/bosh/release
./scripts/sync-submodule-config
```
 This script will overwrite the `.gitmodules` file, replacing `git@` with
 `https://`.
 This needs to be manually corrected for any private repositories, e.g.
 `pivotal-cf-experimental/service-backup`.
 An issue is open with `gosub` at https://github.com/vito/gosub/issues/1

- _Branching strategy_: This repo uses `develop` and `master` branches: `master` is stable, `develop` is not.

## Contributing

Submit pull-requests against the `develop` branch.
