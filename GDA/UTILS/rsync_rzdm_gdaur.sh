#!/bin/bash
set -x

# Command line options
# -------------------------------

while getopts ":s:e:d:" option;
do
 case $option in
  s)
   echo received -s with $OPTARG
   SDATE=$OPTARG
   ;;
  e)
   echo received -e with $OPTARG
   EDATE=$OPTARG
   ;;
  d)
   echo received -d with $OPTARG
   CDUMPS=$OPTARG
   ;;
  :)
   echo "option -$OPTARG needs an argument"
   ;;
  *)
   echo "invalid option -$OPTARG"
   ;;
 esac
done

GDA_DIR=/lfs/h2/emc/global/noscrub/emc.global/dump
SOURCE_DIR=/home/ftp/emc/users/smelchior/wcoss2/GDAS_NON_RESTRICTED_48HRS

NDATE=/apps/ops/prod/nco/core/prod_util.v2.0.13/exec/ndate

EDATE=${EDATE:-$SDATE}
CDUMPS=${CDUMPS:-'gdas gfs'}

#rsync -azv emc.glopara@emcrzdm.ncep.noaa.gov:/home/ftp/emc/users/smelchior/wcoss2/GDAS_NON_RESTRICTED_48HRS/20221108_gdas.t06z.aircar.tm00.bufr_d.nr /lfs/h2/emc/global/noscrub/emc.global/dump/gdasur.20221108/06/atmos/gdas.t06z.aircar.tm00.bufr_d

date=$SDATE
while [ $date -le $EDATE ];
do

  YYYY=`expr $date | cut -c1-4`
  PDY=`expr $date | cut -c1-8`
  CC=`expr $date | cut -c9-10`

  for CDUMP in $CDUMPS
  do
    for type in aircar.tm00.bufr_d aircft.tm00.bufr_d prepbufr
    do
      FILE_IN=${PDY}_${CDUMP}.t${CC}z.${type}.nr
      FILE_OUT=${CDUMP}.t${CC}z.${type}
      rsync -azv emc.glopara@emcrzdm.ncep.noaa.gov:${SOURCE_DIR}/${FILE_IN} ${GDA_DIR}/${CDUMP}ur.${PDY}/${CC}/atmos/${FILE_OUT}
    done
  done

  adate=`$NDATE +06 $date`
  date=$adate
done # SDATE to EDATE

exit 0
