#! /bin/sh
#PBS -N sync_syndat_rd
#PBS -A GFS-DEV
#PBS -q dev_transfer
#PBS -l select=1:mpiprocs=1:ompthreads=1:ncpus=1
#PBS -l walltime=00:05:00
#PBS -j oe -o /lfs/h2/emc/stmp/emc.global/sync_syndat_rd.log
set -x

prodmac=`cat /lfs/h1/ops/prod/config/prodmachinefile | grep primary | cut -c9- | cut -c1`
curmac=`hostname | cut -c1`

# Check if on production machine
if [[ ${prodmac} == ${curmac} ]]; then

  data_wcoss2=/lfs/h1/ops/prod/com/gfs/v16.3/syndat
  data_ursa=/scratch3/NCEPDEV/global/role.glopara/com/gfs/prod/

  RSYNC="rsync -azv --checksum --delete-before"

  # Sync GFS ops syndat to Ursa 
  echo "------------------------------------------"
  echo "Rsyncing syndat to Ursa"

  ${RSYNC} ${data_wcoss2} role.glopara@dtn-ursa.fairmont.rdhpcs.noaa.gov:${data_ursa}

  echo "Done"

fi
