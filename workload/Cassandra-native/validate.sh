#!/bin/bash -e
#
# Apache v2 license
# Copyright (C) 2023 Intel Corporation
# SPDX-License-Identifier: Apache-2.0
#

OPTION=${1:-cassandra_user_gated}
PLATFROM=${PLATFORM:-SPR}
WORKLOAD=${WORKLOAD:-cassandra}
HOST_NUM=${HOST_NUM:-1} #This is for cluster-config.yaml.m4, no need to config by user
NETWORK_RPS_TUNE_ENABLE=${NETWORK_RPS_TUNE_ENABLE:-false}
KERNEL_TUNE_ENABLE=${KERNEL_TUNE_ENABLE:-false}
JDK_VERSION=${JDK_VERSION:-JDK14} # JDK11,JDK14
CLIENT_DURATION=${CLIENT_DURATION:-10m}
CASSANDRA_FILL_DATA=${CASSANDRA_FILL_DATA:-true}
CASSANDRA_FILL_DATA_ONLY=${CASSANDRA_FILL_DATA_ONLY:-false}
INSTANCE_NUM=${INSTANCE_NUM:-1}
CLIENT_POP_MIN=${CLIENT_POP_MIN:-1}
CLIENT_POP_MAX_PERFORMANCE_DIV=${CLIENT_POP_MAX_PERFORMANCE_DIV:-1} # POP_MAX in performance = CLIENT_POP_MAX / CLIENT_POP_MAX_PERFORMANCE_DIV
CLIENT_POP_MAX=${CLIENT_POP_MAX:-100}
CASSANDRA_CONCURENT_READS=${CASSANDRA_CONCURENT_READS:-32}
CASSANDRA_CONCURENT_WRITES=${CASSANDRA_CONCURENT_WRITES:-16}

#cassandra client parameters
CLIENT_CL=${CLIENT_CL:-ONE}
CLIENT_THREADS=${CLIENT_THREADS:-128}
CLIENT_INSERT=${CLIENT_INSERT:-20}
CLIENT_SIMPLE=${CLIENT_SIMPLE:-80}
STRESS_NUM_PER_INSTANCE=${STRESS_NUM_PER_INSTANCE:-1}
DATA_COMPACTION=${DATA_COMPACTION:-SizeTieredCompactionStrategy}
DATA_COMPRESSION=${DATA_COMPRESSION:-LZ4Compressor}
DATA_CHUNK_SIZE=${DATA_CHUNK_SIZE:-16}
REPLICATE_NUM=${REPLICATE_NUM:-1} #for cluster mode
CLIENT_NODE_NUM=${CLIENT_NODE_NUM:-1}

#cassandra server parameters
DEPLOY_MODE=${DEPLOY_MODE:-standalone} #standalone | cluster
CLUSTER_ON_SINGLE_NODE=${CLUSTER_ON_SINGLE_NODE:-false}
NODE_NUM=${NODE_NUM:-1} #only for cluster
CASSANDRA_DISK_MOUNT=${CASSANDRA_DISK_MOUNT:-false}
CASSANDRA_NUMACTL_ENABLE=${CASSANDRA_NUMACTL_ENABLE:-false}
CASSANDRA_NUMACTL_VCORES_ENABLE=${CASSANDRA_NUMACTL_VCORES_ENABLE:-true}
CASSANDRA_ENDPOINT_SNITCH=${CASSANDRA_ENDPOINT_SNITCH:-SimpleSnitch} #default value in cassandra.yaml
CASSANDRA_NUM_TOKENS=${CASSANDRA_NUM_TOKENS:-16} #default value in cassandra.yaml
NUMA_OPTIONS=${NUMA_OPTIONS:-} #same as the paramerers in command numactl
RAM_DISK_EANBLE=${RAM_DISK_EANBLE:-false}
#disks_path: "/mnt/disk1 /mnt/disk2 /mnt/disk3 /mnt/disk4 ..." for standalone cassandra DB data path
DISKS_PATH=${DISKS_PATH:-}

# It is recommended to set min (-Xms) and max (-Xmx) heap sizes to
# the same value to avoid stop-the-world GC pauses during resize, and
# so that we can lock the heap in memory on startup to prevent any
# of it from being swapped out.
#If exceeds free size, it will adjust before configure into cassandra
JVM_HEAP_SIZE=${JVM_HEAP_SIZE:-31} #GB
JVM_GC_TYPE=${JVM_GC_TYPE:-+UseG1GC}

# Logs Setting
DIR="$( cd "$( dirname "$0" )" &> /dev/null && pwd )"
. "$DIR/../../script/overwrite.sh"

if [[ "${TESTCASE}" =~ ^test.*_gated$ ]]; then
    CLIENT_DURATION=1m
    CLIENT_THREADS=10
    INSTANCE_NUM=1
    DEPLOY_MODE="standalone"
    NODE_NUM=1
    HOST_NUM=1
    CLIENT_NODE_NUM=1
    CLIENT_POP_MAX=100
    CLIENT_POP_MAX_DIV=1000
    STRESS_NUM_PER_INSTANCE=1
fi

#For cluster
if [[ "${TESTCASE}" =~ ^test.*cluster.*_pkm$ ]]; then
    DEPLOY_MODE="cluster"
    INSTANCE_NUM=1
    CLIENT_CL=QUORUM
    if ${CLUSTER_ON_SINGLE_NODE}; then
        HOST_NUM=1
    else
        HOST_NUM=$NODE_NUM
        CASSANDRA_NUMACTL_ENABLE=false
    fi

fi
#For standalone
if [[ "${TESTCASE}" =~ ^test.*standalone.*_pkm$ ]]; then
    DEPLOY_MODE="standalone"
    NODE_NUM=1
    CLIENT_NODE_NUM=1
    REPLICATE_NUM=1
    HOST_NUM=1 #there is already one for client in cluster-config.yaml.m4
fi

if [[ "${TESTCASE}" =~ ^test.*_1n$ ]]; then
    DEPLOY_MODE="standalone"
    NODE_NUM=1
    HOST_NUM=1
    CLIENT_NODE_NUM=1
    REPLICATE_NUM=1
fi
if [[ "${TESTCASE}" =~ ^test.*_ramdisk_pkm$ ]]; then
    RAM_DISK_EANBLE="true"
fi


#Event tracing parameters
if [[ "${TESTCASE}" =~ ^test.*_pkm$ ]]; then
    EVENT_TRACE_PARAMS="roi,Begin performance testing,End performance testing"
fi

#if need to tune kernel
if ${KERNEL_TUNE_ENABLE} ; then
    DOCKER_OPTIONS="--privileged $DOCKER_OPTIONS"
fi

case $PLATFORM in
    ARMv8 | ARMv9 )
        IMAGE_ARCH="-arm64"
        JDK_VERSION="JDK11" #Only support JDK11 on ARM
        ;;
    MILAN | ROME )
        IMAGE_ARCH=""
        ;;
    * )
        IMAGE_ARCH=""
        ;;
esac


# Workload Setting
WORKLOAD_PARAMS=(
    INSTANCE_NUM CASSANDRA_CONCURENT_READS CASSANDRA_CONCURENT_WRITES
    CASSANDRA_NUMACTL_ENABLE CLIENT_DURATION CLIENT_CL CLIENT_THREADS
    CLIENT_INSERT CLIENT_SIMPLE STRESS_NUM_PER_INSTANCE JVM_HEAP_SIZE
    DATA_COMPACTION DATA_COMPRESSION DATA_CHUNK_SIZE CLIENT_POP_MIN
    NETWORK_RPS_TUNE_ENABLE JDK_VERSION CASSANDRA_FILL_DATA CLIENT_POP_MAX
    CASSANDRA_DISK_MOUNT  DEPLOY_MODE NODE_NUM CLIENT_NODE_NUM REPLICATE_NUM
    CASSANDRA_ENDPOINT_SNITCH CASSANDRA_NUM_TOKENS CLUSTER_ON_SINGLE_NODE
    NUMA_OPTIONS CLIENT_POP_MAX_PERFORMANCE_DIV HOST_NUM RAM_DISK_EANBLE
    KERNEL_TUNE_ENABLE CASSANDRA_NUMACTL_VCORES_ENABLE JVM_GC_TYPE DISKS_PATH
    CASSANDRA_FILL_DATA_ONLY
)

# Kubernetes Setting
RECONFIG_OPTIONS="-DCLIENT_DURATION=${CLIENT_DURATION} -DCLIENT_CL=${CLIENT_CL} -DCLIENT_THREADS=${CLIENT_THREADS} -DCLIENT_INSERT=${CLIENT_INSERT} \
    -DCLIENT_SIMPLE=${CLIENT_SIMPLE} -DCASSANDRA_CONCURENT_READS=${CASSANDRA_CONCURENT_READS} -DJVM_HEAP_SIZE=${JVM_HEAP_SIZE} \
    -DCASSANDRA_NUMACTL_ENABLE=${CASSANDRA_NUMACTL_ENABLE} -DCASSANDRA_CONCURENT_WRITES=${CASSANDRA_CONCURENT_WRITES} -DINSTANCE_NUM=${INSTANCE_NUM} \
    -DSTRESS_NUM_PER_INSTANCE=${STRESS_NUM_PER_INSTANCE} -DDATA_COMPACTION=${DATA_COMPACTION} -DDATA_COMPRESSION=${DATA_COMPRESSION} \
    -DDATA_CHUNK_SIZE=${DATA_CHUNK_SIZE} -DIMAGE_ARCH=${IMAGE_ARCH} -DCASSANDRA_NUMACTL_VCORES_ENABLE=${CASSANDRA_NUMACTL_VCORES_ENABLE}\
    -DCLIENT_POP_MIN=${CLIENT_POP_MIN} -DCLIENT_POP_MAX=${CLIENT_POP_MAX} -DJVM_GC_TYPE=${JVM_GC_TYPE} -DRAM_DISK_EANBLE=${RAM_DISK_EANBLE} \
    -DNETWORK_RPS_TUNE_ENABLE=${NETWORK_RPS_TUNE_ENABLE} -DJDK_VERSION=${JDK_VERSION} -DCASSANDRA_FILL_DATA=${CASSANDRA_FILL_DATA} -DHOST_NUM=${HOST_NUM} \
    -DCASSANDRA_DISK_MOUNT=${CASSANDRA_DISK_MOUNT} -DDEPLOY_MODE=${DEPLOY_MODE} -DNODE_NUM=${NODE_NUM} -DCLIENT_NODE_NUM=${CLIENT_NODE_NUM} \
    -DREPLICATE_NUM=${REPLICATE_NUM} -DCASSANDRA_ENDPOINT_SNITCH=${CASSANDRA_ENDPOINT_SNITCH} -DCASSANDRA_NUM_TOKENS=${CASSANDRA_NUM_TOKENS} \
    -DNUMA_OPTIONS=${NUMA_OPTIONS} -DCLIENT_POP_MAX_PERFORMANCE_DIV=${CLIENT_POP_MAX_PERFORMANCE_DIV} -DCLUSTER_ON_SINGLE_NODE=${CLUSTER_ON_SINGLE_NODE} \
    -DKERNEL_TUNE_ENABLE=${KERNEL_TUNE_ENABLE} -DDISKS_PATH=${DISKS_PATH} -DCASSANDRA_FILL_DATA_ONLY=${CASSANDRA_FILL_DATA_ONLY}"

JOB_FILTER="job-name=benchmark"

. "$DIR/../../script/validate.sh"
