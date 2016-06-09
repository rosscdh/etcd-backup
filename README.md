# Dockerized etcd backup runner

A docker container, built off Centos 7 that executes a backup of [etcd](https://github.com/coreos/etcd) and uploads it to an Amazon S3 bucket.

The upload filename will take the form: `etcd-backup-[YYYY-MM-DD]-[HOSTNAME].tgz`. If the container runs within a kubernetes pod, 
`HOSTNAME` is self-configured using the API.

Install from Docker Hub:

    docker pull squareweave/etcd-backup

Example execution command:

    docker run --rm \
        -v [/var/lib/etcd:/var/lib/etcd] \
        -e AWS_S3_BUCKET_NAME=[myawsbucket.s3.amazonaws.com] \
        -e AWS_DEFAULT_REGION=[aws-region-of-your-bucket] \
        -e AWS_ACCESS_KEY_ID=[MYACCESSKEYID] \
        -e AWS_SECRET_ACCESS_KEY=[MYSECRETACCESKEY] \
        etcd-backup

Note: Because etcd is critical to running many docker orchestation platforms, for security reasons, we strongly recommend that you 
review and are comfortable with 
executing any scripts that interact with it prior to running. [/run.sh (the container's default command)'s source can be reviewed here](https://github.com/squareweave/etcd-backup/blob/master/run.sh).

A standard CloudFormation script to create the S3 bucket, IAM user and lock-down it's permissions 
[is provided as well](https://github.com/squareweave/etcd-backup/blob/master/cloudformation.example.json).

## Environment Variables

**AWS_S3_BUCKET_NAME** (required) *no default*

Bucket name to back-up to. Must be complete name, including ".s3.amazonaws.com".

**AWS_DEFAULT_REGION** (conditionally required) *no default*

[AWS region](http://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region) that your bucket belongs to. 

Required if your S3 bucket name does not include a region-specific hostname (i.e. "s3-ap-southeast-2.amazonaws.com" for Asia 
Pacific Sydney).

**AWS_ACCESS_KEY_ID** (required) *no default*

IAM access key id used to upload to S3. 

**AWS_SECRET_ACCESS_KEY** (required) *no default*

Corresponding IAM secret access key for S3 uploads.

**KUBERNETES_URL** *default=https://detected-url-to-kubernetes-api*

If running inside a kubernetes pod, provide the URL to reach the kubernetes API. This will auto-configure on a standard kubernetes 
host based on environment variables provided to the pod.

**ETCD_DATA_DIR** *default=/var/lib/etcd*

Location of etcd's data directory, e.g. `/var/lib/etcd`. Typically, this would be mounted in from either a running etcd container 
(using `--volumes-from`), or mounted from the host (`-v /var/lib/etcd:[ETCD_DATA_DIR_VALUE]`). If you are using a default-lke 
configuration of etcd, this value is not required.