#set -ax

CDATE=$1
CDUMP=$2
DMPDIR=${3:-/lfs/h2/emc/dump/noscrub/dump}
OPSGFSDIR=${4:-/lfs/h1/ops/prod/com/gfs/v16.3}
OPSOBSDIR=${5:-/lfs/h1/ops/prod/com/obsproc/v1.1}

PDY=`expr $CDATE | cut -c1-8`
cyc=`expr $CDATE | cut -c9-10`

. /lfs/h2/emc/global/noscrub/emc.global/dump_archive/gda/config.dumparch

#files=`ls ${DMPDIR}/${CDUMP}.${PDY}/${cyc}/atmos | grep t${cyc}z`

echo $CDATE $CDUMP

#for file in $files
for dfile in $DFILES $DFILES_GFS
do
  file=${CDUMP}.t${cyc}z.${dfile}
  #echo $file
  if [ -f ${OPSGFSDIR}/${CDUMP}.${PDY}/${cyc}/atmos/$file ]; then
    cmp ${DMPDIR}/${CDUMP}.${PDY}/${cyc}/atmos/$file ${OPSGFSDIR}/${CDUMP}.${PDY}/${cyc}/atmos/$file
  elif [ -f ${OPSOBSDIR}/${CDUMP}.${PDY}/${cyc}/atmos/$file ]; then
    cmp ${DMPDIR}/${CDUMP}.${PDY}/${cyc}/atmos/$file ${OPSOBSDIR}/${CDUMP}.${PDY}/${cyc}/atmos/$file
  else
    echo "$file missing!"
  fi
  if [ $? -ne 0 ]; then
   echo "$file differs"
  else
   echo "$file SAME"
  fi
done

