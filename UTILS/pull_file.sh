#!/bin/ksh

#set -x

WGRIB="/nwprod/util/exec/wgrib"
NDATE="/nwprod/util/exec/ndate"

CDATE=$1
edate=$2
suffix=$3
suffix=${suffix:-""}

CDUMPS='gfs gdas'

while [[ $CDATE -le $edate ]]; do
YYYY=`expr $CDATE | cut -c1-4`
MM=`expr $CDATE | cut -c5-6`
DD=`expr $CDATE | cut -c7-8`
CC=`expr $CDATE | cut -c9-10`
for CDUMP in $CDUMPS
do
  DMPDIR=/global/noscrub/Kate.Howard/dump/$CDATE
  scp -p Kate.Howard@dtn-zeus.rdhpcs.noaa.gov:/scratch1/portfolios/NCEPDEV/jcsda/noscrub/Li.Bi/oscat/oscatw.$CDUMP.$CDATE $DMPDIR/${CDUMP}${suffix}/
done
adate=`$NDATE +06 $CDATE`
CDATE=$adate
done
