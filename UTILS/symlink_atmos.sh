#!/bin/sh
#set -x

sdate=$1
edate=${2:-sdate}

incr=06
NDATE=/apps/ops/prod/nco/core/prod_util.v2.0.13/exec/ndate

DMPDIR=/lfs/h2/emc/dump/noscrub/dump

COMPONENT="atmos"

date=$sdate
while [[ $date -le $edate ]] ; do

 PDY=`expr $date | cut -c1-8`
 cyc=`expr $date | cut -c9-10`

 for CDUMP in gdas gfs
 do
   for dump in ${CDUMP} ${CDUMP}nr ${CDUMP}nrx ${CDUMP}ur ${CDUMP}x ${CDUMP}y
   do
     if [ -d ${DMPDIR}/${dump}.${PDY}/${cyc} ]; then
       cd ${DMPDIR}/${dump}.${PDY}/${cyc}
       #echo ${DMPDIR}/${dump}.${PDY}/${cyc}
       if [ ! -d ${DMPDIR}/${dump}.${PDY}/${cyc}/${COMPONENT} ]; then
         echo "Making atmos subfolder symlink: ${DMPDIR}/${dump}.${PDY}/${cyc}/${COMPONENT}"
         ln -s ./ atmos
       else
         echo "Exists: ${dump}.${PDY}/${cyc} atmos subfolder"
       fi
     fi
   done
 done

 adate=`$NDATE ${incr} $date`
 date=$adate

done

