#! /usr/bin/env bash

set -eau

module use /contrib/spack-stack/spack-stack-1.9.2/envs/ue-oneapi-2024.2.1/install/modulefiles/Core
module load stack-oneapi/2024.2.1
module load awscli-v2/2.15.53

DATA_DIR=/scratch3/NCEPDEV/global/role.glopara/com/gfs/prod

cd ${DATA_DIR}

set -x

aws s3 sync syndat s3://noaa-nws-global-pds/syndat
