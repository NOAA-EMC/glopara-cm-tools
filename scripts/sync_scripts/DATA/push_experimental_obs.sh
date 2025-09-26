#! /usr/bin/bash

sdate=$1
edate=$2
target=$3
type=${4:-"gdas gfs"}

if ! date -d ${sdate:0:8} >& /dev/null; then 
    echo "Bad input start date: $sdate"
    exit 1
elif ! date -d ${edate:0:8} >& /dev/null; then
    echo "Bad input end date: $edate"
    exit 2
elif [[ "$type" != "gfs" || "$type" != "gdas" || "$type" != "gdas gfs" || "$type" != "gfs gdas" ]]; then
    echo "Invalid observation type(s): $type"
fi

if [[ $target == "msu" ]]; then
    sync_dir="role.global@hercules-dtn.hpc.msstate.edu:/work2/noaa/global/role.global/data/experimental_obs/"
fi

module use /contrib/spack-stack/spack-stack-1.9.2/envs/ue-oneapi-2024.2.1/install/modulefiles/Core
module load stack-oneapi/2024.2.1
module load prod_util

cdate=$sdate
while [[ $cdate -le edate ]]; do
    just_date=${cdate:0:8}
    for dtype in ${type}; do
        src_dir="/scratch3/NCEPDEV/global/role.glopara/data/experimental_obs/${dtype}.${just_date}"
        if [[ -d "${src_dir}" ]]; then
            rsync -avhr "${src_dir}" "${sync_dir}"
        fi
    done
    cdate=`$NDATE 24 $cdate`
done
