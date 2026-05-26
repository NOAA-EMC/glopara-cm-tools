#!/bin/bash -l
# Script to clean /dfs/write dump 

set -x

export HOMEgda=${HOMEgda:-"/lfs/h2/emc/global/save/emc.global/dump_archive"}
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

NDATE=${NDATE:-"/apps/ops/prod/nco/core/prod_util.v${prod_util_ver}/exec/ndate"}

# Set time period to check and rsync

DATE=`$NDATE`
#EDATE=`$NDATE -120 $DATE`
EDATE=`$NDATE -144 $DATE`
#SDATE=`$NDATE -96 $EDATE`
#SDATE=`$NDATE -120 $EDATE`
SDATE=`$NDATE -144 $EDATE`

# Run rsync script to pull from DFS into GDA

sh ${UTILDIR}/clean_dfs.sh -s $SDATE -e $EDATE

echo 
echo '****************************************************'
echo "Done @ $(date -u)"
echo '****************************************************'
