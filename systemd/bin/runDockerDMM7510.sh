#!/usr/bin/env bash

set -u

if [ -z "$DMM7510_INSTANCE" ]; then
    echo "Device type is not set. Please use -d option" >&2
    exit 1
fi

DMM7510_TYPE=$(echo ${DMM7510_INSTANCE} | grep -Eo "[^0-9]+");
DMM7510_NUMBER=$(echo ${DMM7510_INSTANCE} | grep -Eo "[0-9]+");

if [ -z "$DMM7510_TYPE" ]; then
    echo "DMM7510 device type is not set. Please check the DMM7510_INSTANCE environment variable" >&2
    exit 2
fi

if [ -z "$DMM7510_NUMBER" ]; then
    echo "DMM7510 number is not set. Please check the DMM7510_INSTANCE environment variable" >&2
    exit 3
fi

export DMM7510_CURRENT_PV_AREA_PREFIX=DMM7510_${DMM7510_INSTANCE}_PV_AREA_PREFIX
export DMM7510_CURRENT_PV_DEVICE_PREFIX=DMM7510_${DMM7510_INSTANCE}_PV_DEVICE_PREFIX
export DMM7510_CURRENT_DEVICE_IP=DMM7510_${DMM7510_INSTANCE}_DEVICE_IP
export DMM7510_CURRENT_DEVICE_PORT=DMM7510_${DMM7510_INSTANCE}_DEVICE_PORT
# Only works with bash
export EPICS_PV_AREA_PREFIX=${!DMM7510_CURRENT_PV_AREA_PREFIX}
export EPICS_PV_DEVICE_PREFIX=${!DMM7510_CURRENT_PV_DEVICE_PREFIX}
export EPICS_DEVICE_IP=${!DMM7510_CURRENT_DEVICE_IP}
export EPICS_DEVICE_PORT=${!DMM7510_CURRENT_DEVICE_PORT}

#set +eo pipefail
/usr/bin/docker run \
    --net host \
    -t \
    --name dmm7510-epics-ioc-${DMM7510_INSTANCE} \
    lnlsdig/dmm7510-epics-ioc:${IMAGE_VERSION} \
    -i ${EPICS_DEVICE_IP} \
    -p ${EPICS_DEVICE_PORT} \
    -d ${DMM7510_INSTANCE} \
    -P ${EPICS_PV_AREA_PREFIX} \
    -R ${EPICS_PV_DEVICE_PREFIX}
# If there is a container with the same name
# use it
if [ "$?" -ne "0" ]; then
    /usr/bin/docker start \
        dmm7510-epics-ioc-${DMM7510_INSTANCE}
fi