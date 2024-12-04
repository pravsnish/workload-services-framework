#!/bin/bash -e
#
# Apache v2 license
# Copyright (C) 2023 Intel Corporation
# SPDX-License-Identifier: Apache-2.0
#

# Nighthawk client setting
NIGHTHAWK_CLIENT_LIMITS_CPU=${NIGHTHAWK_CLIENT_LIMITS_CPU:-8}
NIGHTHAWK_CLIENT_REQUEST_CPU=${NIGHTHAWK_CLIENT_REQUEST_CPU:-2}
NIGHTHAWK_CLIENT_DURATION=${NIGHTHAWK_CLIENT_DURATION:-30}
NIGHTHAWK_CLIENT_CONNECTIONS=${NIGHTHAWK_CLIENT_CONNECTIONS:-8}
NIGHTHAWK_CLIENT_CONCURRENCY=${NIGHTHAWK_CLIENT_CONCURRENCY:-2}
NIGHTHAWK_CLIENT_RPS=${NIGHTHAWK_CLIENT_RPS:-30}

# Nighthawk server setting
NIGHTHAWK_SERVER_LIMITS_CPU=${NIGHTHAWK_SERVER_LIMITS_CPU:-8}
NIGHTHAWK_SERVER_REQUEST_CPU=${NIGHTHAWK_SERVER_REQUEST_CPU:-2}

while getopts 'x-:' optchar; do
	case "$optchar" in
		-)
			case "$OPTARG" in
				duration=*) NIGHTHAWK_CLIENT_DURATION="${OPTARG#*=}" ;;
				connections=*) NIGHTHAWK_CLIENT_CONNECTIONS="${OPTARG#*=}" ;;
				concurrency=*) NIGHTHAWK_CLIENT_CONCURRENCY="${OPTARG#*=}" ;;
				rps=*) NIGHTHAWK_CLIENT_RPS="${OPTARG#*=}" ;;
				*) echo "Invalid argument" ;;
			esac
			;;
		*) echo "Invalid argument" ;;
	esac
done

if [[ -n "$REGISTRY" ]]; then
	HELM_OPT_REGISTRY="--set REGISTRY=$REGISTRY"
fi

if [[ -n "$RELEASE" ]]; then
	HELM_OPT_RELEASE="--set RELEASE=$RELEASE"
fi

DIR="$( cd "$( dirname "$0" )" &> /dev/null && pwd )"

. "$DIR"/../../script/overwrite.sh

HELM_OPTIONS="--set NIGHTHAWK_CLIENT_DURATION=$NIGHTHAWK_CLIENT_DURATION \
--set NIGHTHAWK_CLIENT_CONNECTIONS=$NIGHTHAWK_CLIENT_CONNECTIONS \
--set NIGHTHAWK_CLIENT_CONCURRENCY=$NIGHTHAWK_CLIENT_CONCURRENCY \
--set NIGHTHAWK_CLIENT_RPS=$NIGHTHAWK_CLIENT_RPS"
HELM_OPTIONS+=" $HELM_OPT_REGISTRY"
HELM_OPTIONS+=" $HELM_OPT_RELEASE"

HELM_CONFIG="$DIR/charts"

# Workload Setting
WORKLOAD_PARAMS=(NIGHTHAWK_CLIENT_DURATION NIGHTHAWK_CLIENT_CONNECTIONS NIGHTHAWK_CLIENT_CONCURRENCY NIGHTHAWK_CLIENT_RPS)

# Docker Setting
DOCKER_IMAGE=""
DOCKER_OPTIONS=""

# Kubernetes Setting
RECONFIG_OPTIONS="-DFILTER=$FILTER"
RECONFIG_OPTIONS="-DDURATION=$NIGHTHAWK_CLIENT_DURATION -DCONNECTIONS=$NIGHTHAWK_CLIENT_CONNECTIONS -DCONCURRENCY=$NIGHTHAWK_CLIENT_CONCURRENCY -DRPS=$NIGHTHAWK_CLIENT_RPS"
JOB_FILTER="job-name=benchmark"

. "$DIR/../../script/validate.sh"