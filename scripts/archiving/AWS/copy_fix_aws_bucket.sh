#! /usr/bin/env bash

set -eau

sets=$1

module use /contrib/spack-stack/spack-stack-1.9.2/envs/ue-oneapi-2024.2.1/install/modulefiles/Core
module load stack-oneapi/2024.2.1
module load awscli-v2/2.15.53

FIX_DIR=/scratch3/NCEPDEV/global/role.glopara/fix

cd ${FIX_DIR}

for set in ${sets}
do

  set -x

  #aws s3api put-object --bucket noaa-nws-global-pds --key fix/${set}/
  #aws s3 cp ${set}/ s3://noaa-nws-global-pds/fix/${set}/ --recursive
  ##aws s3 sync ${set}/ s3://noaa-nws-global-pds/fix/${set}/ --dryrun 
  aws s3 sync ${set}/ s3://noaa-nws-global-pds/fix/${set}/

done
