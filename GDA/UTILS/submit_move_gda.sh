#! /bin/sh
#PBS -N GDA_move
#PBS -A GFS-DEV
#PBS -q dev_transfer
#PBS -l select=1:mpiprocs=1:ompthreads=1:ncpus=1:mem=10GB
#PBS -l walltime=06:00:00
#PBS -j oe -o move_gda.log_20230526
#PBS 

set -x

SDATE=2023052600
EDATE=2023052600

sh /lfs/h2/emc/global/noscrub/emc.global/dump_archive/UTILS/move_gda.sh -s $SDATE -e $EDATE
