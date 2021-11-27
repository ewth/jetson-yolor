#!/usr/bin/env bash

##
# Run detection
##

# Thanks https://stackoverflow.com/questions/59895/
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if [[ -z "${YOLOR_VERSION}" ]]; then
    YOLOR_VERSION=yolor_p6
fi

if [[ -z "${IMAGE_SIZE}" ]]; then
    IMAGE_SIZE=960
fi

echo "Starting detection with ${YOLOR_VERSION} at image size ${IMAGE_SIZE}"

# cd /yolor

# python detect.py \
#     --source inference/images/horses.jpg \
#     --cfg cfg/yolor_p6.cfg \
#     --weights yolor_p6.pt
#     --conf 0.25 --img-size 1280 --device 0

python /yolor/detect.py \
    --source /resources/sources/sdvd_v1.avi \
    --names /jetson-yolor/data/coco.names \
    --cfg /yolor/cfg/${YOLOR_VERSION}.cfg \
    --weights /resources/weights/yolor/${YOLOR_VERSION}.pt \
    --conf 0.25 \
    --class 0 \
    --img-size ${IMAGE_SIZE} \
    --device 0

