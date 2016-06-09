#!/bin/sh -xe

mkdir -p $ETCD_BACKUP_DIR

etcdctl backup --data-dir $ETCD_DATA_DIR --backup-dir $ETCD_BACKUP_DIR

COMPRESSED_BACKUP_FILE=etcd-backup-$(date +%Y-%m-%d)-$HOSTNAME.tgz

# Detect if running in kubernetes, adjust backup name if so
SA_DIR=/var/run/secrets/kubernetes.io/serviceaccount
if [ -d $SA_DIR ]; then
    : ${KUBERNETES_URL:=https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT}
    TOKEN=$(cat $SA_DIR/token)
    POD_NAMESPACE=$(cat $SA_DIR/namespace)
    POD_API_URL=https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT/api/v1/namespaces/$POD_NAMESPACE/pods/$HOSTNAME
    NODE_HOSTNAME=$(curl -s $POD_API_URL --header "Authorization: Bearer $TOKEN" --insecure | jq -r .spec.nodeName)

    NODE_API_URL=https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT/api/v1/nodes/$NODE_HOSTNAME
    NODE_NAME=$(curl -s $NODE_API_URL --header "Authorization: Bearer $TOKEN" --insecure | jq -r .metadata.labels.host)
    
    COMPRESSED_BACKUP_FILE=etcd-backup-$(date +%Y-%m-%d)-$NODE_NAME.tgz
fi

tar -czvf $COMPRESSED_BACKUP_FILE $ETCD_BACKUP_DIR/

aws s3 cp $COMPRESSED_BACKUP_FILE s3://$AWS_S3_BUCKET_NAME/$COMPRESSED_BACKUP_FILE