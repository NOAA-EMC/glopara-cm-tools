#!/bin/ksh

#set -x

module load grib_util
module load prod_util

CDATE=$1
edate=${2:-$CDATE}
CDUMPS=${3:-'gdas gfs'}

prefix=nsstbufr

DMPDIR=/globaldump
TMPDIR=/stmpp1/$LOGNAME/dump/hpsspull
if [ ! -d $TMPDIR ]; then mkdir $TMPDIR; fi

while [ $CDATE -le $edate ];
do

 YYYY=`expr $CDATE | cut -c1-4`
 MM=`expr $CDATE | cut -c5-6`
 DD=`expr $CDATE | cut -c7-8`
 CC=`expr $CDATE | cut -c9-10`

 for CDUMP in $CDUMPS
 do

  cd $TMPDIR

  if [ $CDUMP = 'gdas' ]; then
   tarball=gpfs_hps_nco_ops_com_gfs_prod_gdas.${CDATE}.tar
  else
   tarball=gpfs_hps_nco_ops_com_gfs_prod_gfs.${CDATE}.anl.tar
  fi

  infile=${CDUMP}.t${CC}z.${prefix}
  outdir=${DMPDIR}/${CDATE}/${CDUMP}
  outfile=${prefix}.${CDUMP}.${CDATE}

  /nwprod/util/ush/hpsstar get /NCEPPROD/hpssprod/runhistory/rh${YYYY}/${YYYY}${MM}/${YYYY}${MM}${DD}/${tarball} ./${infile}

  mv $infile ${outdir}/$outfile
  cd $outdir
  chgrp rstprod $outfile
  chmod 640 $outfile 
  ln -sf ${outfile} ${infile}

  done #CDUMP

 #Increment CDATE
 CDATE=`$NDATE +06 $CDATE`
done #CDATE
