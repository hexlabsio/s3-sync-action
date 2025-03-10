FROM python:3.8-alpine

LABEL "com.github.actions.name"="S3 Sync"
LABEL "com.github.actions.description"="Sync a directory to an AWS S3 repository with contents types set for br and gzip files"
LABEL "com.github.actions.icon"="refresh-cw"
LABEL "com.github.actions.color"="green"

LABEL version="0.5.1"
LABEL repository="https://github.com/hexlabsio/s3-sync-action"
LABEL homepage="https://hexlabs.io/"
LABEL maintainer="HexLabs <admin@hexlabs.io>"

# https://github.com/aws/aws-cli/blob/master/CHANGELOG.rst
ENV AWSCLI_VERSION='1.18.14'

RUN pip install --quiet --no-cache-dir awscli==${AWSCLI_VERSION}
RUN apk add --no-cache bash

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
