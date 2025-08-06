#! /bin/sh
#PBS -N sync_verif_ursa
#PBS -A GFS-DEV
#PBS -q dev_transfer
#PBS -l select=1:mpiprocs=1:ompthreads=1:ncpus=1
#PBS -l walltime=06:00:00
#PBS -j oe -o /lfs/h2/emc/stmp/emc.global/sync_verif_ursa.log
set -x

prodmac=`cat /lfs/h1/ops/prod/config/prodmachinefile | grep primary | cut -c9- | cut -c1`
curmac=`hostname | cut -c1`

# Check if on production machine
if [[ ${prodmac} == ${curmac} ]]; then

  data_wcoss2=/lfs/h2/emc/vpppg/noscrub/emc.vpppg/verification/global/archive
  data_ursa=/scratch3/NCEPDEV/global/role.glopara/data/metplus.data

  #RSYNC="rsync -azvL --checksum --delete-before"
  #RSYNC="rsync -azvL --delete-before"
  RSYNC="rsync -azvL"

  # Sync global verif to Ursa
  echo "------------------------------------------"
  echo "Rsyncing verif to Ursa"

  ${RSYNC} ${data_wcoss2}/model_data/ecm role.glopara@dtn-ursa.fairmont.rdhpcs.noaa.gov:${data_ursa}/archive/
  ${RSYNC} ${data_wcoss2}/model_data/gfs role.glopara@dtn-ursa.fairmont.rdhpcs.noaa.gov:${data_ursa}/archive/
  ${RSYNC} ${data_wcoss2}/fit2obs_data role.glopara@dtn-ursa.fairmont.rdhpcs.noaa.gov:${data_ursa}/archive/
  ${RSYNC} ${data_wcoss2}/metplus_data/by_VSDB role.glopara@dtn-ursa.fairmont.rdhpcs.noaa.gov:${data_ursa}/archive/metplus_data/
  for obs_type in prepbufr ccpa_accum24hr ceres ghcn_cams gpcp vsdb_climo_data ; do
    if [[ ${obs_type} = prepbufr ]] ; then
      ${RSYNC} ${data_wcoss2}/obs_data/prepbufr/gdas role.glopara@dtn-ursa.fairmont.rdhpcs.noaa.gov:${data_ursa}/obs_data/prepbufr/
      ${RSYNC} ${data_wcoss2}/obs_data/prepbufr/nam role.glopara@dtn-ursa.fairmont.rdhpcs.noaa.gov:${data_ursa}/obs_data/prepbufr/
    else
      ${RSYNC} ${data_wcoss2}/obs_data/${obs_type} role.glopara@dtn-ursa.fairmont.rdhpcs.noaa.gov:${data_ursa}/obs_data/
    fi
  done
  echo "Done"

fi
