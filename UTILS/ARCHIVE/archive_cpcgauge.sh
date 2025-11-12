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

DMPDIR=${DMPDIR:-"/gpfs/dell3/emc/global/dump"}
DMPDIR_HERA=${DMPDIR_HERA:-"/scratch1/NCEPDEV/global/glopara/dump"}
DMPCPCMD=${DMPCPCMD:-"rsync -azv"}

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
 ifile=glbDEG0.125P
 ofile=PRCP_CU_GAUGE_V1.0GLB_0.125deg.lnx.${PDY}.RT
 oefile=PRCP_CU_GAUGE_V1.0GLB_0.125deg.lnx.${PDY}.RT_early
 #idir=/gpfs/dell2/emc/modeling/noscrub/emc.glopara/stat/cpcUniGauge/${yyyy}
 #idir=/gpfs/dell1/nco/ops/dcom/prod/$PDY/wgrbbul/cpc_rcdas
 idir=/gpfs/dell2/cpc/noscrub/Mingyue.Chen/data/OBS/PrecDlyCPCunigauge/$yyyy

 cd ${DMPDIR}/${CDUMP}.${PDY}/$cyc
 mv ${ofile} ${oefile}
 if [ ! -f $idir/$ifile ]; then
   ${DMPCPCMD} emc.glopara@${omach}.ncep.noaa.gov:$idir/$ifile ${ofile}
 else
   ${DMPCPCMD} $idir/$ifile ${ofile}
 fi

 # Rsync to dev WCOSS and Hera
 ${DMPCPCMD} ${DMPDIR}/${CDUMP}.${PDY}/$cyc/${ofile} emc.glopara@${omach}.ncep.noaa.gov:${DMPDIR}/${CDUMP}.${PDY}/$cyc/
 ${DMPCPCMD} ${DMPDIR}/${CDUMP}.${PDY}/$cyc/${oefile} emc.glopara@${omach}.ncep.noaa.gov:${DMPDIR}/${CDUMP}.${PDY}/$cyc/
 ${DMPCPCMD} ${DMPDIR}/${CDUMP}.${PDY}/$cyc/${ofile} glopara@dtn-hera.fairmont.rdhpcs.noaa.gov:${DMPDIR_HERA}/${CDUMP}.${PDY}/$cyc/
 ${DMPCPCMD} ${DMPDIR}/${CDUMP}.${PDY}/$cyc/${oefile} glopara@dtn-hera.fairmont.rdhpcs.noaa.gov:${DMPDIR_HERA}/${CDUMP}.${PDY}/$cyc/
 if [ -d ${DMPDIR}/${CDUMP}p.${PDY}/$cyc ]; then
   ${DMPCPCMD} ${DMPDIR}/${CDUMP}.${PDY}/$cyc/${ofile} emc.glopara@${omach}.ncep.noaa.gov:${DMPDIR}/${CDUMP}p.${PDY}/$cyc/
   ${DMPCPCMD} ${DMPDIR}/${CDUMP}.${PDY}/$cyc/${oefile} emc.glopara@${omach}.ncep.noaa.gov:${DMPDIR}/${CDUMP}p.${PDY}/$cyc/
 fi

 adate=`$NDATE +24 $CDATE`
 CDATE=$adate
done

echo 
echo '****************************************************'
echo "Done @ $(date -u)"
echo '****************************************************'
