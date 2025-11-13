#!/bin/bash -l
# Script to rsync from /dfs/read into GDA 

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
. $HOMEgfs/ush/load_fv3gfs_modules.sh
status=$?
[[ $status -ne 0 ]] && exit $status

# Source versions file for runtime
source "$HOMEgfs/versions/run.ver"

NDATE=${NDATE:-"/apps/ops/prod/nco/core/prod_util.v${prod_util_ver}/exec/ndate"}

# Set time period to check and rsync

EDATE=`$NDATE`
SDATE=`$NDATE -72 $EDATE`

# Run rsync script to pull from DFS into GDA

sh ${UTILDIR}/rsync_pull_dfs.sh -s $SDATE -e $EDATE

echo 
echo '****************************************************'
echo "Done @ $(date -u)"
echo '****************************************************'
