#!/bin/bash

##
# This script is meant to invoke training with some paramaters attached to allow easy logging (via wandb).
# Mainly just metadata to help with comparing tests etc later.
# Should only be run inside Docker!
##

# Thanks https://stackoverflow.com/questions/59895/
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

DATASET="COCO-2017"
# The test.py script reverts to these defaults too
TEST_NAMES="/yolor-edge/data/coco-2017/coco.names"
TEST_DATA="/yolor-edge/data/coco-2017/coco.yaml"

EXTRA_ARGS=""

if [[ ! -z "${DEEPRESCUE}" ]]; then
    if [[ "${DEEPRESCUE}" == "1" ]]; then
        TEST_NAMES="/resources/datasets/deeprescue/v1/deeprescue.names"
        TEST_DATA="/resources/datasets/deeprescue/v1/deeprescue.yaml"
    fi
    if [[ "${DEEPRESCUE}" == "2" ]]; then
        TEST_NAMES="/resources/datasets/deeprescue/v2/deeprescue.names"
        TEST_DATA="/resources/datasets/deeprescue/v2/data.yaml"
    fi
    EXTRA_ARGS="${EXTRA_ARGS} --single-cls"
    DATASET="deeprescue"
fi

if [[ ! -z "${BATCH_SIZE}" ]]; then
    EXTRA_ARGS="${EXTRA_ARGS} --batch-size ${BATCH_SIZE}"
fi
if [[ ! -z "${IMAGE_SIZE}" ]]; then
    EXTRA_ARGS="${EXTRA_ARGS} --img-size ${IMAGE_SIZE}"
fi
if [[ ! -z "${TEST_DATA}" ]]; then
    EXTRA_ARGS="${EXTRA_ARGS} --data ${TEST_DATA}"
fi
if [[ ! -z "${TEST_NAMES}" ]]; then
    EXTRA_ARGS="${EXTRA_ARGS} --names ${TEST_NAMES}"
fi
if [[ -z "${YOLOR_CFG}" ]]; then
    YOLOR_CFG=yolor_p6
fi
if [[ -z "${YOLOR_MODEL}" ]]; then
    YOLOR_MODEL=${YOLOR_CFG}
fi
if [[ -z "${PROJECT_NAME}" ]]; then
    PROJECT_NAME="${YOLOR_MODEL}_val"
fi


echo "Starting validation run of ${YOLOR_MODEL} on ${DATASET} data"
if [[ ! -z "${EXTRA_ARGS}" ]]; then
    echo " with extra args ${EXTRA_ARGS}"
fi

# This is just read to pass to wandb
# @todo: add this to a py param or something nicer; it's for logging
SHM_SIZE=$(cat /proc/mounts | grep "/dev/shm" | grep -Po 'size=([0-9]+[a-zA-Z])' | grep -Po '([0-9]+[a-zA-Z])')
if [[ ! $SHM_SIZE =~ [0-9]+[a-zA-Z] ]]; then
    SHM_SIZE="-1"
else
    SHM_FACT=${SHM_SIZE: -1}
    SHM_DIV=1
    SHM_ADD=""
    if [ "${SHM_FACT,,}" == "k" ]; then
        # kbytes
        SHM_DIV=1024
    fi
    SHM_SIZE=$((${SHM_SIZE::-1} / ${SHM_DIV}))
fi

# Normal run
SHM_SIZE=${SHM_SIZE} WANDB_TAGS=${WANDB_TAGS} python3 /yolor-edge/yolor/test.py \
    ${EXTRA_ARGS} --verbose \
    --save-txt --save-conf --save-json \
    --cfg /yolor-edge/yolor/cfg/${YOLOR_CFG}.cfg \
    --weights /resources/weights/yolor/${YOLOR_MODEL}.pt \
    --name ${PROJECT_NAME}
