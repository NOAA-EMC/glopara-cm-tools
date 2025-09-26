#! /usr/bin/env bash

set -eaux

module use /scratch1/NCEPDEV/nems/role.epic/spack-stack/spack-stack-1.6.0/envs/gsi-addon-dev-rocky8/install/modulefiles/Core
module load stack-intel/2021.5.0
module load prod_util

#enkfgdas.20231115_grp0.tar   
#enkfgdas.20231115_grp1.tar
#enkfgdas.20231115_grp2.tar
#enkfgdas.20231115_grp3.tar
#enkfgdas.20231115_grp4.tar
#enkfgdas.20231115_grp5.tar
#enkfgdas.20231115_grp6.tar
#enkfgdas.20231115_grp7.tar
#enkfgdas.20231115_grp8.tar
#gdas.20231115.tar

# Directory locations
#OUTDIR="/scratch1/NCEPDEV/global/glopara/data/ICSDIR/C1152mx025/20250327"
OUTDIR="/scratch1/NCEPDEV/global/glopara/data/ICSDIR/retro_ICs"
PICKUP_dir="/NCEPDEV/emc-global/5year/Ruiyu.Sun/GFSv17_RETRO_warmATmic_withlandNspread_N_oceanicewave"

date=$1

cd $OUTDIR
for grp in 0 1 2 3 4 5 6 7 8 ; do
  /home/role.glopara/bin/hpsstar get ${PICKUP_dir}/enkfgdas.${date}_grp${grp}.tar
done
/home/role.glopara/bin/hpsstar get ${PICKUP_dir}/gdas.${date}.tar

exit 0
