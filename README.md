# service-backup-release
BOSH release of service backup tool

## Usage

This BOSH release is intended to be co-located with other releases that need to perform backups. The release supports uploading to supported s3 blobstores (AWS s3, Ceph s3, [Swift w/ s3 compatibility middleware](https://swiftstack.com/docs/admin/middleware/s3_middleware.html)), Azure blobstore and via SCP. At this time only one upload destination is supported.

The tool will create a folder structure in your destination bucket / folder as follows: `yyyy/mm/dd` and uses the machine it is running on to calculate the date. For example if your machine is using UTC time, then the folder structure will reflect this.

Here is an example BOSH deployment manifest for uploading to a blobstore:

```yml
---
properties:
  service-backup:
    destination:
      s3:
        bucket_name: replace-with-bucket-name-in-S3
        bucket_path: replace-with-bucket-path-in-S3
        access_key_id: replace-with-AWS-access-key
        secret_access_key: replace-with-AWS-secret-access-key
    source_folder: replace-with-source-folder-on-local-machine
    source_executable: replace-with-source-executable
    cron_schedule: replace-with-cron-schedule

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

For SCP swap the `s3` section with the following:

```yml
    scp:
      user: username
      server: backup-server.com
      destination: mybackups/service
      key: |
        -----BEGIN RSA PRIVATE KEY-----
        -----END RSA PRIVATE KEY-----
      port: 22
```

For Azure swap the `s3` section with the following:

```yml
    azure:
      storage_account: storageaccount
      storage_access_key: somekey
      container: yourcontainer
      path: backup_path
```

An exhaustive and up-to-date list of properties can be found in the [service-backup job spec](./jobs/service-backup/spec).

#### Disabling backups

Backups can be disabled by removing the `service-backup` section from your manifest and then redeploying. You can still leave the template on your job if you wish.

#### Identifying service instance that is being back up in logs

You may provide a binary that returns a string identifier for your service instance. This will appear in all log messages under the data element `identifier` e.g.

`{ "source": "ServiceBackuo", "message": "doing-stuff", "data": { "identifier": "service_identifier" }, "timestamp": 1232345, "log_level": 1 }`

Add the `service_identifier_executable` key to your manifest:

```yml
properties:
  service-backup:
    destination:
      s3:
        bucket_name: replace-with-bucket-name-in-S3
        bucket_path: replace-with-bucket-path-in-S3
        access_key_id: replace-with-AWS-access-key
        secret_access_key: replace-with-AWS-secret-access-key
    source_folder: replace-with-source-folder-on-local-machine
    source_executable: replace-with-source-executable
    cron_schedule: replace-with-cron-schedule
    service_identifier_executable: replace-with-service-identifier-executable #optional
```

### Bucket name and path

The bucket name should not start with `s3://` and it should not contain underscores. Additionally, neither the bucket name nor the bucket path should have preceding or trailing slashes. An example of syntactically-valid properties is:

```yml
properties:
  service-backup:
    blobstore:
      bucket_name: my-bucket-name
      bucket_path: my/remote/path/inside/bucket
```

The provided path is appended with the current date such that the resultant path is `/my/remote/path/inside/bucket/YYYY/MM/DD/` and hence the artifacts are accessible at `s3://my-bucket-name/my/remote/path/inside/bucket/YYYY/MM/DD/`.

#### AWS Backup User Permissions

First, create a new AWS user to perform backups under the Identity & Access Management (IAM) page.
Copy this user's Access Key ID and Secret into the service-backup manifest section listed above.

Next, create a new custom policy (IAM > Policies > Create Policy > Create Your Own Policy) and paste in the following permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ServiceBackupPolicy",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:ListMultipartUploadParts",
        "s3:CreateBucket",
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

The `s3:CreateBucket` permission is required because the tool will attempt to create the bucket if it does not already exist. If the desired bucket already exists, the `s3:CreateBucket` permission is not required.

Finally, attach this policy to your AWS user (IAM > Policies > Policy Actions > Attach).

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

## Downloading releases

The final releases can be found under https://s3-eu-west-1.amazonaws.com/cf-services-external-builds/service-backup/final/

Please ensure that the AWS IAM user you are configured to use has attached a policy of AmazonS3ReadOnlyAccess or you may encounter the following error when attempting to list the bucket contents:

```
A client error (AccessDenied) occurred when calling the ListObjects operation: Access Denied
```

## Contributing

Submit pull-requests against the `develop` branch.
