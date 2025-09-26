#! /usr/bin/env bash

set -eaux

module use /contrib/spack-stack/spack-stack-1.9.2/envs/ue-oneapi-2024.2.1/install/modulefiles/Core
module load stack-oneapi/2024.2.1
module load prod_util

#[role.glopara@hfe09 experimental_obs]$ rsync -azv /scratch1/NCEPDEV/da/common/gdas.20210301/00/ocean/icec gdas.20210301/00/ocean/

# Directory locations
EO_dir="/scratch3/NCEPDEV/global/role.glopara/data/experimental_obs"
PICKUP_dir="/scratch1/NCEPDEV/da/common"

sdate=$1
edate=${2:-sdate}
data_types=${3:-"gdas gfs"}

date=$sdate
while [[ $date -le $edate ]] ; do

 PDY=`expr $date | cut -c1-8`
 cyc=`expr $date | cut -c9-10`

 # Copy files
 #rsync -azv ${PICKUP_dir}/gdas.${PDY}/${cyc}/ocean/icec ${EO_dir}/gdas.${PDY}/${cyc}/ocean/
 for dump in ${data_types} ; do
   rsync -azvL role.glopara@dtn-hera.fairmont.rdhpcs.noaa.gov:${PICKUP_dir}/${dump}.${PDY} ${EO_dir}/
   chgrp -R global ${EO_dir}/${dump}.${PDY}
 done

 #adate=`$NDATE 06 ${date}`
 adate=`$NDATE 24 ${date}`
 date=$adate

done

