# Script to rsync dump data on WCOSS2 and Hera 
# ------------------------------------------------------------------------------------------------------------

set -x

# Command line options
# -------------------------------

while getopts ":s:e:d:m:n:" option;
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
  m)
   echo received -m with $OPTARG
   machs=$OPTARG
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

#mac=`hostname | cut -c1`
#if [ $mac = 'c' ]; then
#  machine='cactus'
#  omac='ddxfer.wcoss2.ncep.noaa.gov'
  #omac='dlogin'
#elif [ $mac = 'd' ]; then
#  machine='dogwood'
#  omac='cdxfer.wcoss2.ncep.noaa.gov'
  #omac='clogin'
#fi

EDATE=${EDATE:-$SDATE}
CDUMPS=${CDUMPS:-'gfs gdas'}
machs=${machs:-all}
NFREQ=${NFREQ:-"06"}

export HOMEgda=${HOMEgda:-"/lfs/h2/emc/global/noscrub/emc.global/dump_archive"}
export EXPDIR=${EXPDIR:-$HOMEgda/gda}

# Source relevant configs
configs="dumparch"
for config in $configs; do
  . $EXPDIR/config.${config}
  status=$?
  [[ $status -ne 0 ]] && exit $status
done

# Initialize modules
. $HOMEgda/UTILS/load_modules.sh
status=$?
[[ $status -ne 0 ]] && exit $status

# Source versions file for runtime
source "$HOMEgda/versions/run.ver"

export NDATE=${NDATE:-"/apps/ops/prod/nco/core/prod_util.v${prod_util_ver}/exec/ndate"}

ACCOUNT_URSA=${ACCOUNT_URSA:-"role.glopara"}

DMPDIR=${DMPDIR:-"/lfs/h2/emc/dump/noscrub/dump"}
DMPCPCMD=${DMPCPCMD:-"rsync -avp --checksum"}
#DMPCPCMD="rsync -avp --delete-before"
#DMPCPCMD="rsync -avp"

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
 cyc=`expr $CDATE | cut -c9-10`

 #-----------------------------------------------------
 # WCOSS2 or all
 #-----------------------------------------------------
 if [ $machs = wcoss2 -o $machs = all ]; then

  # gdas/gfs
  for CDUMP in $CDUMPS
  do
    #GDAp-handled-separately#for dump in ${CDUMP} ${CDUMP}nr ${CDUMP}ur ${CDUMP}p ${CDUMP}x ${CDUMP}y ${CDUMP}v
    #for dump in ${CDUMP} ${CDUMP}nr ${CDUMP}ur ${CDUMP}x ${CDUMP}y ${CDUMP}v
    for dump in ${CDUMP} ${CDUMP}nr ${CDUMP}nrx ${CDUMP}ur ${CDUMP}x ${CDUMP}y ${CDUMP}v
    do
      if [ -d ${DMPDIR}/${dump}.${PDY} ]; then
        ${DMPCPCMD} ${DMPDIR}/${dump}.${PDY} emc.global@${omac}:${DMPDIR}/
      fi
    done # dump
  done # CDUMPS

  # rtofs
  for dump in rtofs
  do
    if [ -d ${DMPDIR}/${dump}.${PDY} ]; then
      ${DMPCPCMD} ${DMPDIR}/${dump}.${PDY} emc.global@${omac}:${DMPDIR}/
    fi
  done # dump

 fi # WCOSS2 or all

 #-----------------------------------------------------
 # Ursa or all
 #-----------------------------------------------------
 if [ $DMPURSA = "YES" -o $machs = ursa ]; then

  # gdas/gfs
  for CDUMP in $CDUMPS
  do
    # Only rsync non-p-dump files (exclude gdasp/gfsp)
    #for dump in ${CDUMP} ${CDUMP}nr ${CDUMP}ur ${CDUMP}x ${CDUMP}y ${CDUMP}v
    for dump in ${CDUMP} ${CDUMP}nr ${CDUMP}nrx ${CDUMP}ur ${CDUMP}x ${CDUMP}y ${CDUMP}v
    do
      if [ -d ${DMPDIR}/${dump}.${PDY} ]; then
        ${DMPCPCMD} ${DMPDIR}/${dump}.${PDY} ${ACCOUNT_URSA}@dtn-ursa.fairmont.rdhpcs.noaa.gov:${DMPDIR_URSA}/
      fi
    done # dump
  done # CDUMPS

  # rtofs
  for dump in rtofs
  do
    if [ -d ${DMPDIR}/${dump}.${PDY} ]; then
      ${DMPCPCMD} ${DMPDIR}/${dump}.${PDY} ${ACCOUNT_URSA}@dtn-ursa.fairmont.rdhpcs.noaa.gov:${DMPDIR_URSA}/
    fi
  done # dump

  for network in gdas gfs
  do
    ursafile=$MONDIR/filecounts.${network}.ursa.html
    rsync -av ${ACCOUNT_URSA}@dtn-ursa.fairmont.rdhpcs.noaa.gov:/scratch3/NCEPDEV/global/role.glopara/dump_archive/counts.${network}.ursa.html $ursafile
  done

 fi # Ursa or all

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
