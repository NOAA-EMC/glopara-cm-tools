#! /usr/bin/env bash

set -eau

module use /scratch1/NCEPDEV/nems/role.epic/spack-stack/spack-stack-1.6.0/envs/unified-env-rocky8/install/modulefiles/Core
module load stack-intel/2021.5.0
module load awscli-v2/2.13.22

DUMP_DIR=/scratch1/NCEPDEV/global/glopara/dump_ur

cd ${DUMP_DIR}

SETS=`ls`

set -x

for set in ${SETS} ; do
  #aws s3api put-object --bucket noaa-nws-global-pds --key data/ICSDIR/${set}/
  #aws s3 cp ${set}/ s3://noaa-nws-global-pds/data/ICSDIR/${set}/ --recursive
  ##aws s3 sync ${set}/ s3://noaa-nws-global-pds/dump_ur/${set}/ --dryrun 
  aws s3 sync ${set}/ s3://noaa-nws-global-pds/dump_ur/${set}/
done
