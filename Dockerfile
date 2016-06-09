FROM centos:7

ENV ETCD_BACKUP_DIR=/backups \
    ETCD_DATA_DIR=/var/lib/etcd

COPY run.sh /

RUN set -xe && \
    yum install -y epel-release && \
    yum install -y awscli etcd && \
    yum clean headers && \
    yum clean packages && \
    curl -Lo /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 && \
    chmod +x /usr/local/bin/jq /run.sh && \
    true

CMD /run.sh