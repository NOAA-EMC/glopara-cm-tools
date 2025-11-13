#!/bin/ksh

set -x

CDATE=$1
edate=${2:-$CDATE}
CDUMPS=${3:-'gdas gfs'}

module load prod_util/1.1.6

DMPDIR=/gpfs/dell3/emc/global/dump
NDATE=${NDATE:-/gpfs/dell1/nco/ops/nwprod/prod_util.v1.1.0/exec/ips/ndate}
HPSSTAR=/u/emc.glopara/bin/hpsstar
PERMISSION=/gpfs/dell2/emc/modeling/noscrub/emc.glopara/dump_archive/UTILS/permission.sh

while [ $CDATE -le $edate ];
do

 for dump in $CDUMPS
 do

  PDY=`expr $CDATE | cut -c1-8`
  YYYY=`expr $CDATE | cut -c1-4`
  MM=`expr $CDATE | cut -c5-6`
  DD=`expr $CDATE | cut -c7-8`
  CC=`expr $CDATE | cut -c9-10`

  cd $DMPDIR 
  if [ ! -d $dump.$PDY/$CC/atmos ]; then mkdir -p $dump.$PDY/$CC/atmos ; fi

  file=com_gfs_prod_${dump}.${YYYY}${MM}${DD}_${CC}.${dump}.tar

  $HPSSTAR get /NCEPPROD/hpssprod/runhistory/rh${YYYY}/${YYYY}${MM}/${YYYY}${MM}${DD}/${file} ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.1bamua.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.1bhrs4.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.1bmhs.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.adpsfc.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.adpupa.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.ahicsr.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.aircar.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.aircft.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.airsev.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.atmsdb.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.atms.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.ascatt.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.ascatw.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.avcsam.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.avcspm.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.bathy.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.crisf4.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.crsfdb.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.esamua.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.esatms.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.eshrs3.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.esiasi.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.esmhs.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.geoimr.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.gome.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.gpsipw.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.gpsro.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.gsrasr.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.gsrcsr.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.hdob.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.iasidb.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.engicegrb ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.imssnow96.grib2 ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.mtiasi.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.NPR.SNWN.SP.S1200.MESH16.grb ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.NPR.SNWS.SP.S1200.MESH16.grb ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.nsstbufr ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.omi.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.ompslp.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.ompsn8.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.ompst8.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.osbuv8.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.prepbufr ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.prepbufr.acft_profiles ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.proflr.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.rassda.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.rtgssthr.grb ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.rtgssthr.grib2 ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.saphir.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.satwnd.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.seaice.5min.blend.grb ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.seaice.5min.grb ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.seaice.5min.grib2 ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.sevcsr.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.sfcshp.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.snogrb_t1534.3072.1536 ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.ssmisu.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.sstgrb ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.sstvcw.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.sstvpw.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.status.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.updated.status.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.syndata.tcvitals.tm00 ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.tesac.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.tideg.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.trkob.tm00.bufr_d ./${dump}.${YYYY}${MM}${DD}/${CC}/atmos/${dump}.t${CC}z.vadwnd.tm00.bufr_d

  cd $dump.$PDY/$CC
  mv atmos/* .
  rm -rf atmos

 done # dump 

 # Run permission script
 #cd $DMPDIR
 #$HPSSTAR get /5year/NCEPDEV/emc-global/emc.glopara/DUMPxy/$CDATE.tar
 cd $DMPDIR
 sh $PERMISSION $CDATE

 #Increment CDATE
 CDATE=`$NDATE +06 $CDATE`
done # CDATES

