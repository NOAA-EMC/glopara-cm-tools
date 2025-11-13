#! /bin/sh
#PBS -N GDA_arch_sup
#PBS -A GFS-DEV
#PBS -q dev_transfer
#PBS -l select=1:mpiprocs=1:ompthreads=1:ncpus=1:mem=2048M
#PBS -l walltime=06:00:00
#PBS -j oe -o arch_sup.log
#PBS 

set -x

#SDATE=2022062800
SDATE=2022080900
EDATE=2022080900

sh /lfs/h2/emc/global/noscrub/emc.global/dump_archive/UTILS/arch_sup.sh $SDATE $EDATE
