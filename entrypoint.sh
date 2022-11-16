#!/bin/sh

set -e

if [ -z "$AWS_S3_BUCKET" ]; then
  echo "AWS_S3_BUCKET is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "AWS_ACCESS_KEY_ID is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "AWS_SECRET_ACCESS_KEY is not set. Quitting."
  exit 1
fi

# Default to us-east-1 if AWS_REGION not set.
if [ -z "$AWS_REGION" ]; then
  AWS_REGION="us-east-1"
fi

# Override default AWS endpoint if user sets AWS_S3_ENDPOINT.
if [ -n "$AWS_S3_ENDPOINT" ]; then
  ENDPOINT_APPEND="--endpoint-url $AWS_S3_ENDPOINT"
fi

# Create a dedicated profile for this action to avoid conflicts
# with past/future actions.
# https://github.com/jakejarvis/s3-sync-action/issues/1
aws configure --profile s3-sync-action <<-EOF > /dev/null 2>&1
${AWS_ACCESS_KEY_ID}
${AWS_SECRET_ACCESS_KEY}
${AWS_REGION}
text
EOF


# Sync using our dedicated profile and suppress verbose messages.
# All other flags are optional via the `args:` directive.
# Exclude any compressed br or gzip files
sh -c "aws s3 sync ${SOURCE_DIR:-.} s3://${AWS_S3_BUCKET}/${DEST_DIR} \
              --exclude '*.br' \
              --exclude '*.gz' \
              --profile s3-sync-action \
              --no-progress \
              ${ENDPOINT_APPEND} $*"

i=0
ORIGINAL_ARGS=($*)
while [ $i -lt ${#ORIGINAL_ARGS[*]} ]; do
  arg=${ORIGINAL_ARGS[$i]}
  if [ $arg != "--delete" ]; then
    REDUCED_ARGS+=($arg)
  fi
  i=$((i + 1))
done

# Only include html gzip files and set correct content type and encoding
sh -c "aws s3 sync ${SOURCE_DIR:-.} s3://${AWS_S3_BUCKET}/${DEST_DIR} \
              --exclude '*' \
              --include '*.html.gz' \
              --content-type text/html \
              --content-encoding gzip \
              --profile s3-sync-action \
              --no-progress \
              ${ENDPOINT_APPEND} ${REDUCED_ARGS[*]}"

# Only include html br files and set correct content type and encoding
sh -c "aws s3 sync ${SOURCE_DIR:-.} s3://${AWS_S3_BUCKET}/${DEST_DIR} \
              --exclude '*' \
              --include '*.html.br' \
              --content-type text/html \
              --content-encoding br \
              --profile s3-sync-action \
              --no-progress \
              ${ENDPOINT_APPEND} ${REDUCED_ARGS[*]}"

# Only include js gzip files and set correct content type and encoding
sh -c "aws s3 sync ${SOURCE_DIR:-.} s3://${AWS_S3_BUCKET}/${DEST_DIR} \
              --exclude '*' \
              --include '*.js.gz' \
              --content-type application/javascript \
              --content-encoding gzip \
              --profile s3-sync-action \
              --no-progress \
              ${ENDPOINT_APPEND} ${REDUCED_ARGS[*]}"

# Only include js br files and set correct content type and encoding
sh -c "aws s3 sync ${SOURCE_DIR:-.} s3://${AWS_S3_BUCKET}/${DEST_DIR} \
              --exclude '*' \
              --include '*.js.br' \
              --content-type application/javascript \
              --content-encoding br \
              --profile s3-sync-action \
              --no-progress \
              ${ENDPOINT_APPEND} ${REDUCED_ARGS[*]}"

# Only include css gzip files and set correct content type and encoding
sh -c "aws s3 sync ${SOURCE_DIR:-.} s3://${AWS_S3_BUCKET}/${DEST_DIR} \
              --exclude '*' \
              --include '*.css.gz' \
              --content-type text/css \
              --content-encoding gzip \
              --profile s3-sync-action \
              --no-progress \
              ${ENDPOINT_APPEND} ${REDUCED_ARGS[*]}"

# Only include css br files and set correct content type and encoding
sh -c "aws s3 sync ${SOURCE_DIR:-.} s3://${AWS_S3_BUCKET}/${DEST_DIR} \
              --exclude '*' \
              --include '*.css.br' \
              --content-type text/css \
              --content-encoding br \
              --profile s3-sync-action \
              --no-progress \
              ${ENDPOINT_APPEND} ${REDUCED_ARGS[*]}"

# Clear out credentials after we're done.
# We need to re-run `aws configure` with bogus input instead of
# deleting ~/.aws in case there are other credentials living there.
# https://forums.aws.amazon.com/thread.jspa?threadID=148833
aws configure --profile s3-sync-action <<-EOF > /dev/null 2>&1
null
null
null
text
EOF
