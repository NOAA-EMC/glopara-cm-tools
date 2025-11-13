#!/bin/ksh

#set -x

CDATE=$1
CDUMPS=${2:-'gdas gfs'}
edate=${3:-$CDATE}

WGRIB="/nwprod/util/exec/wgrib"
NDATE="/nwprod/util/exec/ndate"

DMPDIR=/globaldump

while [ $CDATE -le $edate ];
do

for CDUMP in $CDUMPS
do

mkdir /stmpp1/$LOGNAME/dump
cd /stmpp1/$LOGNAME/dump
mkdir $CDATE
cd $CDATE
mkdir $CDUMP
cd $CDUMP

YYYY=`expr $CDATE | cut -c1-4`
MM=`expr $CDATE | cut -c5-6`
DD=`expr $CDATE | cut -c7-8`
CC=`expr $CDATE | cut -c9-10`

if [ $CDUMP = 'gdas' ]; then
  dump='gdas1'
  file=com_gfs_prod_gdas.${CDATE}.tar
else
  dump='gfs'
  file=com_gfs_prod_gfs.${CDATE}.anl.tar
fi

 /nwprod/util/ush/hpsstar get /NCEPPROD/hpssprod/runhistory/rh${YYYY}/${YYYY}${MM}/${YYYY}${MM}${DD}/${file} ./${dump}.t${CC}z.1bamua.tm00.bufr_d ./${dump}.t${CC}z.1bamub.tm00.bufr_d ./${dump}.t${CC}z.1bhrs3.tm00.bufr_d ./${dump}.t${CC}z.1bhrs4.tm00.bufr_d ./${dump}.t${CC}z.1bmhs.tm00.bufr_d ./${dump}.t${CC}z.adpsfc.tm00.bufr_d ./${dump}.t${CC}z.adpupa.tm00.bufr_d ./${dump}.t${CC}z.aircar.tm00.bufr_d ./${dump}.t${CC}z.aircft.tm00.bufr_d ./${dump}.t${CC}z.airsev.tm00.bufr_d ./${dump}.t${CC}z.atms.tm00.bufr_d ./${dump}.t${CC}z.ascatt.tm00.bufr_d ./${dump}.t${CC}z.ascatw.tm00.bufr_d ./${dump}.t${CC}z.avcsam.tm00.bufr_d ./${dump}.t${CC}z.avcspm.tm00.bufr_d ./${dump}.t${CC}z.bathy.tm00.bufr_d ./${dump}.t${CC}z.cris.tm00.bufr_d ./${dump}.t${CC}z.esamua.tm00.bufr_d ./${dump}.t${CC}z.esamub.tm00.bufr_d ./${dump}.t${CC}z.eshrs3.tm00.bufr_d ./${dump}.t${CC}z.esmhs.tm00.bufr_d ./${dump}.t${CC}z.geoimr.tm00.bufr_d ./${dump}.t${CC}z.goesfv.tm00.bufr_d ./${dump}.t${CC}z.gome.tm00.bufr_d ./${dump}.t${CC}z.gpsipw.tm00.bufr_d ./${dump}.t${CC}z.gpsro.tm00.bufr_d ./${dump}.t${CC}z.engicegrb ./${dump}.t${CC}z.mls.tm00.bufr_d ./${dump}.t${CC}z.mtiasi.tm00.bufr_d ./${dump}.t${CC}z.omi.tm00.bufr_d ./${dump}.t${CC}z.osbuv8.tm00.bufr_d ./${dump}.t${CC}z.proflr.tm00.bufr_d ./${dump}.t${CC}z.rassda.tm00.bufr_d ./${dump}.t${CC}z.satwnd.tm00.bufr_d ./${dump}.t${CC}z.sevcsr.tm00.bufr_d ./${dump}.t${CC}z.sfcshp.tm00.bufr_d ./${dump}.t${CC}z.snogrb ./${dump}.t${CC}z.snogrb_t382 ./${dump}.t${CC}z.snogrb_t574 ./${dump}.t${CC}z.sptrmm.tm00.bufr_d ./${dump}.t${CC}z.ssmisu.tm00.bufr_d ./${dump}.t${CC}z.sstgrb ./${dump}.t${CC}z.status.tm00.bufr_d ./${dump}.t${CC}z.updated.status.tm00.bufr_d ./${dump}.t${CC}z.syndata.tcvitals.tm00 ./${dump}.t${CC}z.tesac.tm00.bufr_d ./${dump}.t${CC}z.trkob.tm00.bufr_d ./${dump}.t${CC}z.vadwnd.tm00.bufr_d

 mv ${dump}.t${CC}z.1bamua.tm00.bufr_d 1bamua.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.1bamub.tm00.bufr_d 1bamub.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.1bhrs3.tm00.bufr_d 1bhrs3.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.1bhrs4.tm00.bufr_d 1bhrs4.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.1bmhs.tm00.bufr_d 1bmhs.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.adpsfc.tm00.bufr_d adpsfc.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.adpupa.tm00.bufr_d adpupa.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.aircar.tm00.bufr_d aircar.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.aircft.tm00.bufr_d aircft.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.airsev.tm00.bufr_d airsev.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.ascatt.tm00.bufr_d ascatt.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.ascatw.tm00.bufr_d ascatw.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.atms.tm00.bufr_d atms.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.avcsam.tm00.bufr_d avcsam.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.avcspm.tm00.bufr_d avcspm.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.bathy.tm00.bufr_d bathy.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.cris.tm00.bufr_d cris.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.esamua.tm00.bufr_d esamua.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.esamub.tm00.bufr_d esamub.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.eshrs3.tm00.bufr_d eshrs3.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.esmhs.tm00.bufr_d esmhs.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.geoimr.tm00.bufr_d geoimr.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.goesfv.tm00.bufr_d goesfv.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.gome.tm00.bufr_d gome.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.gpsipw.tm00.bufr_d gpsipw.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.gpsro.tm00.bufr_d gpsro.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.engicegrb icegrb.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.mls.tm00.bufr_d mls.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.mtiasi.tm00.bufr_d mtiasi.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.omi.tm00.bufr_d omi.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.osbuv8.tm00.bufr_d osbuv8.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.proflr.tm00.bufr_d proflr.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.rassda.tm00.bufr_d rassda.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.satwnd.tm00.bufr_d satwnd.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.sevcsr.tm00.bufr_d sevcsr.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.sfcshp.tm00.bufr_d sfcshp.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.snogrb snogrb.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.snogrb_t382 snogrb_t382.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.snogrb_t574 snogrb_t574.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.sptrmm.tm00.bufr_d sptrmm.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.ssmisu.tm00.bufr_d ssmisu.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.sstgrb sstgrb.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.status.tm00.bufr_d stat01.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.updated.status.tm00.bufr_d statup.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.syndata.tcvitals.tm00 tcvitl.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.tesac.tm00.bufr_d tesac.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.trkob.tm00.bufr_d trkob.${CDUMP}.${CDATE}
 mv ${dump}.t${CC}z.vadwnd.tm00.bufr_d vadwnd.${CDUMP}.${CDATE}

done

# Move files to dump archive and run permission script
cd /stmpp1/$LOGNAME/dump/
mv $CDATE/* $DMPDIR/$CDATE
cd $DMPDIR
sh /global/save/emc.glopara/dump_archive/UTILS/permission.sh $CDATE

#Increment CDATE
CDATE=`$NDATE +06 $CDATE`
done
