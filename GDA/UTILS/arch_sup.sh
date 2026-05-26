#!/bin/sh
set -x

sdate=$1
edate=${2:-$sdate}

incr=24

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

DMPDIR=${DMPDIR:-"/lfs/h2/emc/dump/noscrub/dump"}
NDATE=${NDATE:-"/apps/ops/prod/nco/core/prod_util.v${prod_util_ver}/exec/ndate"}
HPSSTAR=${HPSSTAR:-/u/emc.global/bin/hpsstar}

date=$sdate
while [[ $date -le $edate ]] ; do
  PDY=`expr $date | cut -c1-8`
  cyc=`expr $date | cut -c9-10`
  CPCdate=`$NDATE -72 ${PDY}00`
  CPCPDY=`expr $CPCdate | cut -c1-8`
  URdate=`$NDATE -72 ${PDY}00`
  URPDY=`expr $URdate | cut -c1-8`
  cd $DMPDIR

  # Archive GDAx, GDAy, GDAnrx
  $HPSSTAR put /5year/NCEPDEV/emc-global/emc.glopara/DUMPxy/${PDY}.tar g*x.$PDY g*y.$PDY

  # Archive CPC gauge - 3-day delay
  $HPSSTAR put /5year/NCEPDEV/emc-global/emc.glopara/DUMPcpcgauge/${CPCPDY}.tar g*s.${CPCPDY}/00/atmos/PRCP_CU_GAUGE_V1.0GLB_0.125deg.lnx.${CPCPDY}.RT*

  # Archive GDAur - 3-day delay
# $HPSSTAR put /5year/NCEPDEV/emc-global/emc.glopara/DUMPur/${URPDY}.tar g*ur.$URPDY

  # Archive RTOFS
  $HPSSTAR put /5year/NCEPDEV/emc-global/emc.glopara/DUMPrtofs/${PDY}.tar rtofs.$PDY

  adate=`$NDATE ${incr} $date`
  date=$adate
done

