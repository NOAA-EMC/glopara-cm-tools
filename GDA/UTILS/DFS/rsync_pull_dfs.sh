# Script to rsync from /dfs/read into GDA 

set -x

# Command line options
# -------------------------------

while getopts ":s:e:d:n:" option;
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
  n)
   echo received -n with $OPTARG
   NFREQ=$OPTARG
   ;;
  :)
   echo "option -$OPTARG needs an argument"
   ;;
  *)
   echo "invalid option -$OPTARG"
   ;;
 esac
done

mac=`hostname | cut -c1`
if [ $mac = 'c' ]; then
  machine='cactus'
  omach='ddxfer.wcoss2.ncep.noaa.gov'
elif [ $mac = 'd' ]; then
  machine='dogwood'
  omach='cdxfer.wcoss2.ncep.noaa.gov'
fi

EDATE=${EDATE:-$SDATE}
CDUMPS=${CDUMPS:-'gfs gdas'}
NFREQ=${NFREQ:-"24"}

export HOMEgda=${HOMEgda:-"/lfs/h2/emc/global/save/emc.global/dump_archive"}
export EXPDIR=${EXPDIR:-$HOMEgda/gda}

# Source relevant configs
configs="dumparch"
for config in $configs; do
  . $EXPDIR/config.${config}
  status=$?
  [[ $status -ne 0 ]] && exit $status
done

# Initialize modules
. $HOMEgda/UTIL/load_modules.sh
status=$?
[[ $status -ne 0 ]] && exit $status

# Source versions file for runtime
source "$HOMEgda/versions/run.ver"

export NDATE=${NDATE:-"/apps/ops/prod/nco/core/prod_util.v${prod_util_ver}/exec/ndate"}

DMPDIR="/lfs/h2/emc/global/noscrub/emc.global/dump"
#B4-2022062812#DMPDIR2="/lfs/h2/emc/global/noscrub/emc.global/dump2"
DMPCPCMD=${DMPCPCMD:-"rsync -avp"}
#DMPCPCMD="rsync -avp --delete-before"
DMPCPCMD="rsync -avp"
#-----------------------------------------------------
echo '****************************************************'
echo "Started at: $(date -u), SDATE: $SDATE, EDATE: $EDATE"
echo '****************************************************'
#-----------------------------------------------------
CDATE=$SDATE
while [ $CDATE -le $EDATE ];
do

 echo '****************************************************'
 echo "Rsyncing CDATE: $CDATE"
 echo '****************************************************'
 echo 

 PDY=`expr $CDATE | cut -c1-8`

 # gdas/gfs
 for CDUMP in $CDUMPS
 do
   for dump in ${CDUMP} ${CDUMP}nr ${CDUMP}nrx ${CDUMP}ur ${CDUMP}x ${CDUMP}y ${CDUMP}v
   do
     if [ -d ${DFSREADDIR}/${dump}.${PDY} ]; then
       ${DMPCPCMD} ${DFSREADDIR}/${dump}.${PDY} $DMPDIR/
     fi
     #B4-2022062812#if [ -d ${DFSREADDIR2}/${dump}.${PDY} ]; then
     #  ${DMPCPCMD} ${DFSREADDIR2}/${dump}.${PDY} $DMPDIR2/
     #fi
   done # dump
 done # CDUMPS 

 # rtofs
 for dump in rtofs
 do
   if [ -d ${DFSREADDIR}/${dump}.${PDY} ]; then
     ${DMPCPCMD} ${DFSREADDIR}/${dump}.${PDY} $DMPDIR/
   fi
   #B4-2022062812#if [ -d ${DFSREADDIR2}/${dump}.${PDY} ]; then
   #  ${DMPCPCMD} ${DFSREADDIR2}/${dump}.${PDY} $DMPDIR2/
   #fi
 done # dump
 #-------------------------------
 # Increase $CDATE
 #-------------------------------
 adate=`$NDATE +${NFREQ} $CDATE`
 CDATE=$adate

done # CDATE
#-----------------------------------------------------

echo 
echo '****************************************************'
echo "Done @ $(date -u)"
echo '****************************************************'
