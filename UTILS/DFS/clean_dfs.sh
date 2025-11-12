# Script to rsync dump data on WCOSS2 and Hera 
# ------------------------------------------------------------------------------------------------------------

set -x

# Command line options
# -------------------------------

while getopts ":s:e:n:" option;
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
. $HOMEgfs/ush/load_fv3gfs_modules.sh
status=$?
[[ $status -ne 0 ]] && exit $status

# Source versions file for runtime
source "$HOMEgfs/versions/run.ver"

NDATE=${NDATE:-"/apps/ops/prod/nco/core/prod_util.v${prod_util_ver}/exec/ndate"}

#-----------------------------------------------------
echo '****************************************************'
echo "Cleaning DFS: $(date -u), SDATE: $SDATE, EDATE: $EDATE"
echo '****************************************************'
#-----------------------------------------------------
CDATE=$SDATE
while [ $CDATE -le $EDATE ];
do

 PDY=`expr $CDATE | cut -c1-8`

 echo '****************************************************'
 echo "Cleaning out PDY: $PDY"
 echo '****************************************************'
 echo 

  # gdas/gfs
  for CDUMP in $CDUMPS
  do
    for dump in ${CDUMP} ${CDUMP}nr ${CDUMP}nrx ${CDUMP}ur ${CDUMP}x ${CDUMP}y ${CDUMP}v ${CDUMP}p
    do
      cd $DFSWRTDIR
      if [ -d ${dump}.${PDY} ]; then
        rm -rf ${dump}.${PDY}
      fi

      cd $DFSWRTDIR2
      if [ -d ${dump}.${PDY} ]; then
        rm -rf ${dump}.${PDY}
      fi
    done # dump
  done # CDUMPS

  # rtofs
  for dump in rtofs
  do
    cd $DFSWRTDIR
    if [ -d ${dump}.${PDY} ]; then
      rm -rf ${dump}.${PDY}
    fi

    cd $DFSWRTDIR2
    if [ -d ${dump}.${PDY} ]; then
      rm -rf ${dump}.${PDY}
    fi
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
