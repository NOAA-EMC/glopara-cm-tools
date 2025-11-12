#! /bin/sh
#PBS -N GDA_rsync
#PBS -A GFS-DEV
#PBS -q dev_transfer
#PBS -l select=1:mpiprocs=1:ompthreads=1:ncpus=1
#PBS -l walltime=06:00:00
#PBS -j oe -o transfer.log
#PBS 

set -x

SDATE=2025040100
EDATE=2025042118
NFREQ=24
MACH=all

sh /lfs/h2/emc/global/noscrub/emc.global/dump_archive/UTILS/rsync.sh -s $SDATE -e $EDATE -m $MACH -n $NFREQ
