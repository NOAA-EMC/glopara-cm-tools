#!/bin/bash
set -x

GDA_DIR=/lfs/h2/emc/global/noscrub/emc.global/dump
SOURCE_DIR=/lfs/h2/emc/ptmp/emc.global/gda/METOPBC_GLO_SATWND

NDATE=/apps/ops/prod/nco/core/prod_util.v2.0.13/exec/ndate

SDATE=2022031700
EDATE=2022053118

date=$SDATE
while [ $date -le $EDATE ];
do

  YYYY=`expr $date | cut -c1-4`
  PDY=`expr $date | cut -c1-8`
  CC=`expr $date | cut -c9-10`

  for CDUMP in gdas gfs
  do
    FILE=${CDUMP}.t${CC}z.satwnd.tm00.bufr_d
    if [ -f ${SOURCE_DIR}/${CDUMP}.${PDY}/${CC}/atmos/${FILE} ]; then
      rsync -azv ${SOURCE_DIR}/${CDUMP}.${PDY}/${CC}/atmos/${FILE} ${GDA_DIR}/${CDUMP}x.${PDY}/${CC}/atmos/
    else
      echo "${SOURCE_DIR}/${CDUMP}.${PDY}/${CC}/atmos/${FILE} DOES NOT EXIST!"
    fi
  done

  adate=`$NDATE +06 $date`
  date=$adate
done # SDATE to EDATE

