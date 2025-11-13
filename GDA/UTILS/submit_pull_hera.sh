#! /bin/sh
#PBS -N GDA_Hera_rsync
#PBS -A GFS-DEV
#PBS -q dev_transfer
#PBS -l select=1:mpiprocs=1:ompthreads=1:ncpus=1:mem=2048M
#PBS -l walltime=06:00:00
#PBS -j oe -o /lfs/h2/emc/stmp/emc.global/rsync_pull_hera.log
#PBS 

set -x

SDATE=2023010100
EDATE=2023053118

sh /lfs/h2/emc/global/noscrub/emc.global/dump_archive/UTILS/rsync_pull_hera.sh $SDATE $EDATE
