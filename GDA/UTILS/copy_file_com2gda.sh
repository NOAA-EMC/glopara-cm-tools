#!/bin/bash
##set -x

CDATE=$1
EDATE=${2:-$CDATE}

GDADIR="/lfs/h2/emc/dump/noscrub/dump"
OPSDIR="/lfs/h1/ops/prod/com/obsproc/v1.2"
GFSDIR="/lfs/h1/ops/prod/com/gfs/v16.3"

module load prod_util

#/lfs/h1/ops/prod/com/obsproc/v1.2/gdas.20250401/12/atmos/gdas.t12z.snow.usaf.grib2#
type="snow.usaf.grib2"

while [[ ${CDATE} -le ${EDATE} ]]; do
  PDY=$(echo $CDATE | cut -c1-8)
  cyc=$(echo $CDATE | cut -c9-10)
  for dump in gdas gfs; do
    cpath=${dump}.${PDY}/${cyc}/atmos
    rsync -azv ${OPSDIR}/${dump}.${PDY}/${cyc}/atmos/${dump}.t${cyc}z.${type} ${GDADIR}/${dump}.${PDY}/${cyc}/atmos/
  done
  CDATE=`${NDATE} +06 ${CDATE}`
done
