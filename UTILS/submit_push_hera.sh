#! /bin/sh
#PBS -N GDA_Hera_rsync_push
#PBS -A GFS-DEV
#PBS -q dev_transfer
#PBS -l select=1:mpiprocs=1:ompthreads=1:ncpus=1:mem=2048M
#PBS -l walltime=06:00:00
#PBS -j oe -o rsync_push_hera.log

set -x

rsync -azv --checksum --delete-before /lfs/h1/ops/prod/com/gfs/v16.3/syndat glopara@dtn-hera.fairmont.rdhpcs.noaa.gov:/scratch1/NCEPDEV/global/glopara/com/gfs/prod/
