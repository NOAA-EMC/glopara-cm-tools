# Script to rsync dump data on WCOSS prod and Theia
#
# 2019-07-11 K. Friedman - Established for WCOSS-Dell
# ------------------------------------------------------------------------------------------------------------

set -x

# Command line options
# -------------------------------

while getopts ":s:e:d:m:" option;
do
 case $option in
  s)
   echo received -c with $OPTARG
   SDATE=$OPTARG
   ;;
  e)
   echo received -e with $OPTARG
   EDATE=$OPTARG
   ;;
  d)
   echo received -d with $OPTARG
   CDUMP=$OPTARG
   ;;
  m)
   echo received -l with $OPTARG
   machs=$OPTARG
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
if [ $mac = 'v' ]; then
  machine='venus'
  omach='mars'
elif [ $mac = 'm' ]; then
  machine='mars'
  omach='venus'
fi

EDATE=${EDATE:-$SDATE}
CDUMP=${CDUMP:-'gdas'}
machs=${machs:-all}

CONFIG=${CONFIG:-/gpfs/dell2/emc/modeling/noscrub/emc.glopara/dump_archive/gda/config.dumparch}
set -a;. $CONFIG;set +a

DMPDIR=${DMPDIR:-"/lfs/h2/emc/dump/noscrub/dump"}
DMPDIR_HERA=${DMPDIR_HERA:-"/scratch1/NCEPDEV/global/glopara/dump"}
DMPCPCMD=${DMPCPCMD:-"rsync -azv"}

ACCOUNT_HERA=${ACCOUNT_HERA:-"role.glopara"}

CDATE=$SDATE
while [ $CDATE -le $EDATE ];
do

 echo '****************************************************'
 echo "Started at: $(date -u), CDATE: $CDATE"
 echo '****************************************************'
 echo 

 yyyy=`expr $CDATE | cut -c1-4`
 PDY=`expr $CDATE | cut -c1-8`
 cyc=`expr $CDATE | cut -c9-10`
 idir=/gpfs/hps3/emc/global/dump/${CDUMP}.${PDY}/${cyc}

 # Rsync to dev WCOSS and Hera
#${DMPCPCMD} ${DMPDIR}/${CDUMP}.${PDY}/$cyc/${ofile} emc.glopara@${omach}.ncep.noaa.gov:${DMPDIR}/${CDUMP}.${PDY}/$cyc/
#${DMPCPCMD} ${DMPDIR}/${CDUMP}.${PDY}/$cyc/${oefile} emc.glopara@${omach}.ncep.noaa.gov:${DMPDIR}/${CDUMP}.${PDY}/$cyc/

 ${DMPCPCMD} ${idir}/PRCP_CU_GAUGE_V1.0GLB_0.125deg.lnx.* ${ACCOUNT_HERA}@dtn-hera.fairmont.rdhpcs.noaa.gov:${DMPDIR_HERA}/${CDUMP}.${PDY}/$cyc/

 adate=`$NDATE +24 $CDATE`
 CDATE=$adate
done

echo 
echo '****************************************************'
echo "Done @ $(date -u)"
echo '****************************************************'
