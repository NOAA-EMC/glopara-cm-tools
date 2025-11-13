# Script to rsync from Hera GDA into WCOSS2 GDA 

set -x

SDATE=$1
EDATE=${2:-$SDATE}
NFREQ=${NFREQ:-"24"}

NDATE=/apps/ops/prod/nco/core/prod_util.v2.0.13/exec/ndate
DMPDIR=/lfs/h2/emc/dump/noscrub/dump

ACCOUNT_HERA=${ACCOUNT_HERA:-"role.glopara"}

RSYNC="rsync -azv"
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

 for CDUMP in gdas gfs
 do
   for dump in ${CDUMP} ${CDUMP}nr ${CDUMP}nrx ${CDUMP}ur ${CDUMP}x ${CDUMP}y
   do
      ${RSYNC} ${ACCOUNT_HERA}@dtn-hera.fairmont.rdhpcs.noaa.gov:/scratch1/NCEPDEV/global/glopara/dump/${dump}.${PDY} $DMPDIR/
   done
 done
 for dump in rtofs
 do
   ${RSYNC} ${ACCOUNT_HERA}@dtn-hera.fairmont.rdhpcs.noaa.gov:/scratch1/NCEPDEV/global/glopara/dump/${dump}.${PDY} $DMPDIR/
 done
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
