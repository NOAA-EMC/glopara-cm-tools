#!/bin/bash

#examples:

#known eval
#./version_test.sh gfs_mos /lfs/h1/ops/prod/output/20230518/gfs_mos_stn_prdgen_18.o70784421

#known production
#./version_test.sh gfs_mos /lfs/h1/ops/prod/output/20230518/gfs_mos_stn_prdgen_18.o70784415

#for gfs
#./version_test.sh gfs /lfs/h1/ops/prod/output/20230518/gfs_forecast_18.o70775240

#./version_test.sh gfs  /lfs/h1/ops/prod/output/20230519/gdas_atmos_gldas_06.o70935231

model=$1
logfile=$2

if [[ $(grep -A 100 "export ${model}_ver=v" $logfile | grep 'eval=YES') ]]; then

   echo "log file from eval run, try new log file!"

elif [[ $(grep -A 100 "export ${model}_ver=v" $logfile | grep 'eval=NO') ]]; then

   echo "log file from production run!"
   echo ""

#old (bugs)
#   version=$(grep "^${model}_ver" $logfile)
#   version=$(grep "+++ . + ${model}_ver" $logfile | awk '{print $4}')

   version=$(grep -o -m 1 "${model}_ver=v[0-9\.]*" $logfile)
   echo "version= $version"

fi 
