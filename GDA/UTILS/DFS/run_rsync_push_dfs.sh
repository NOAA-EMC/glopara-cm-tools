#!/bin/bash -l
# Script to rsync from GDA into /dfs/write 

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
. $HOMEgda/UTIL/load_modules.sh
status=$?
[[ $status -ne 0 ]] && exit $status

# Source versions file for runtime
source "$HOMEgda/versions/run.ver"

NDATE=${NDATE:-"/apps/ops/prod/nco/core/prod_util.v${prod_util_ver}/exec/ndate"}

# Set time period to check and rsync

EDATE=`$NDATE`
#SDATE=`$NDATE -72 $EDATE`
#SDATE=`$NDATE -96 $EDATE`
SDATE=`$NDATE -120 $EDATE`

# Run rsync script to push from GDA into DFS

sh ${UTILDIR}/rsync.sh -s $SDATE -e $EDATE -m wcoss2 -n 24

echo 
echo '****************************************************'
echo "Done @ $(date -u)"
echo '****************************************************'
