#! /bin/sh
#PBS -N GDA_pull_hpss
#PBS -A GFS-DEV
#PBS -q dev_transfer
#PBS -l select=1:mpiprocs=1:ompthreads=1:ncpus=1:mem=10GB
#PBS -l walltime=06:00:00
#PBS -j oe -o GDA_pull_hpss.log
#PBS 

set -x

HPSSTAR=${HPSSTAR:-/u/emc.global/bin/hpsstar}
PULL_DIR=/lfs/h2/emc/ptmp/emc.global/gda/METOPBC_GLO_SATWND

cd $PULL_DIR

#$HPSSTAR get /NCEPDEV/emc-da/5year/Iliana.Genkova/OBSPROC/Venus/METOPBC_GLO/METOPBC_GLO_202203.tar
#$HPSSTAR get /NCEPDEV/emc-da/5year/Iliana.Genkova/OBSPROC/Venus/METOPBC_GLO/METOPBC_GLO_202204.tar
$HPSSTAR get /NCEPDEV/emc-da/5year/Iliana.Genkova/OBSPROC/Venus/METOPBC_GLO/METOPBC_GLO_202205.tar

exit 0
