#!/bin/bash

this="${BASH_SOURCE-$0}"
bin=$(cd -P -- "$(dirname -- "$this")" && pwd -P)
if [ -f "${bin}/../conf/env.sh" ]; then
  set -a
  . "${bin}/../conf/env.sh"
  set +a
fi

# paths
APP=PCA
INPUT_HDFS=${DATA_HDFS}/${APP}/Input
OUTPUT_HDFS=${DATA_HDFS}/${APP}/Output
if [ ${COMPRESS_GLOBAL} -eq 1 ]; then
    INPUT_HDFS=${INPUT_HDFS}-comp
    OUTPUT_HDFS=${OUTPUT_HDFS}-comp
fi

# Either stand alone or yarn cluster
APP_MASTER=${SPARK_MASTER}

set_gendata_opt
set_run_opt

function print_config(){
	local output=$1

	CONFIG=
	if [ ! -z "$SPARK_STORAGE_MEMORYFRACTION" ]; then
	  CONFIG="${CONFIG} memoryFraction ${SPARK_STORAGE_MEMORYFRACTION}"
	fi
	if [ ! -z "$SPARK_SERIALIZER" ]; then
	  CONFIG="${CONFIG} ${SPARK_SERIALIZER}"
	fi
	if [ ! -z "$SPARK_RDD_COMPRESS" ]; then
	  CONFIG="${CONFIG} RDDcomp ${SPARK_RDD_COMPRESS}"
	fi
	if [ ! -z "$SPARK_IO_COMPRESSION_CODEC" ]; then
	  CONFIG="${CONFIG} ${SPARK_IO_COMPRESSION_CODEC}"
	fi
	if [ ! -z "$SPARK_DEFAULT_PARALLELISM" ]; then
	  CONFIG="${CONFIG} ${SPARK_DEFAULT_PARALLELISM}"
	fi

	echo "${APP}_config \
        NUM_OF_SAMPLES ${NUM_OF_SAMPLES} MIN_SUPPORT ${MIN_SUPPORT} \
	NUM_OF_PARTITIONS ${NUM_OF_PARTITIONS}  \
	${CONFIG} " >> ${output}
}
