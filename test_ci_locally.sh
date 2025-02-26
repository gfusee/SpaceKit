#!/bin/bash
set -e

TEMP_JOB_DIR=$(mktemp -d)

cleanup() {
    rm -rf "$TEMP_JOB_DIR"
}
trap cleanup EXIT

rsync -av --exclude='.build' --exclude='.space' --exclude='docs' ./ "$TEMP_JOB_DIR"

cd $TEMP_JOB_DIR

act release -e act_release_event_file.json \
    --container-architecture linux/arm64 \
    --bind
