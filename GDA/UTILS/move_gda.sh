# Script to move dump data on WCOSS2
# ------------------------------------------------------------------------------------------------------------

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

EDATE=${EDATE:-$SDATE}
CDUMPS=${CDUMPS:-'gfs gdas'}
machs=${machs:-all}
NFREQ=${NFREQ:-"24"}

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

DMPDIR=${DMPDIR:-"/lfs/h2/emc/global/noscrub/emc.global/dump"}
DMPDIR_NEW="/lfs/h2/emc/dump/noscrub/dump"
DMPCPCMD="rsync -avp"
DMPCPCMDCHK="rsync -avp --checksum"
#DMPCPCMD="rsync -avp --delete-before"
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

 # gdas/gfs
 for CDUMP in $CDUMPS
 do
   for dump in ${CDUMP} ${CDUMP}nr ${CDUMP}nrx ${CDUMP}ur ${CDUMP}x ${CDUMP}y
   do
     if [ -d ${DMPDIR}/${dump}.${PDY} ]; then
       cd ${DMPDIR_NEW}
       ${DMPCPCMD} ${DMPDIR}/${dump}.${PDY} .
       ${DMPCPCMDCHK} ${DMPDIR}/${dump}.${PDY} .
       exit_err=$?
       echo "exit_err=$exit_err"
       if [ $exit_err = 0 ]; then
         cd ${DMPDIR}
         rm -rf ${dump}.${PDY}
         ln -s ${DMPDIR_NEW}/${dump}.${PDY} ${dump}.${PDY}
       fi
     fi
   done # dump
 done # CDUMPS

 # rtofs
 for dump in rtofs
 do
   if [ -d ${DMPDIR}/${dump}.${PDY} ]; then
     cd ${DMPDIR_NEW}
     ${DMPCPCMD} ${DMPDIR}/${dump}.${PDY} .
     ${DMPCPCMDCHK} ${DMPDIR}/${dump}.${PDY} .
     exit_err=$?
     echo "exit_err=$exit_err"
     if [ $exit_err = 0 ]; then
       cd ${DMPDIR}
       rm -rf ${dump}.${PDY}
       ln -s ${DMPDIR_NEW}/${dump}.${PDY} ${dump}.${PDY}
     fi
   fi
 done # rtofs

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
