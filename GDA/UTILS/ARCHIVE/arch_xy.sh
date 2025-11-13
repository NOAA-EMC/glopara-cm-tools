#!/bin/sh
set -x

sdate=$1
edate=${2:-$sdate}

incr=24

DMPDIR=/gpfs/dell3/emc/global/dump
ndate=/gpfs/dell1/nco/ops/nwprod/prod_util.v1.1.0/exec/ips/ndate
HPSSTAR=/u/emc.glopara/bin/hpsstar

date=$sdate
while [[ $date -le $edate ]] ; do
  PDY=`expr $date | cut -c1-8`
  cyc=`expr $date | cut -c9-10`
  cd $DMPDIR
  $HPSSTAR put /5year/NCEPDEV/emc-global/emc.glopara/DUMPxy/${PDY}.tar g*x.$PDY g*y.$PDY
  echo
adate=`$ndate ${incr} $date`
date=$adate

done
