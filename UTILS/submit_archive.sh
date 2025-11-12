#! /bin/sh
#PBS -N GDA_archive
#PBS -A GFS-DEV
#PBS -q dev_transfer
#PBS -l select=1:mpiprocs=1:ompthreads=1:ncpus=1:mem=2048M
#PBS -l walltime=00:30:00
#PBS -j oe -o GDA_archive.log

set -x

SDATE=2022081206
EDATE=2022081506

sh /lfs/h2/emc/global/noscrub/emc.global/dump_archive/gda/archive.sh -c $SDATE -e $EDATE -l 'gdasur gmi saldrn gpsrox subpfl'
