#! /bin/sh

prodmac=`cat /lfs/h1/ops/prod/config/prodmachinefile | grep primary | cut -c9- | cut -c1`
curmac=`hostname | cut -c1`

# Check if on production machine
if [[ ${prodmac} == ${curmac} ]]; then

  # Submit syndat sync
  /opt/pbs/bin/qsub /lfs/h2/emc/global/noscrub/emc.global/scripts/DATA/sync_syndat.sh

  # Submit verif sync
  /opt/pbs/bin/qsub /lfs/h2/emc/global/noscrub/emc.global/scripts/DATA/sync_verif.sh

fi
