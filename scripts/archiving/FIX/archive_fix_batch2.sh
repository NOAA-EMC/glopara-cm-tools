#! /bin/bash
#SBATCH --job-name=archive_fix_batch
#SBATCH --account=fv3-cpu
#SBATCH -t 06:00:00
#SBATCH --nodes=1
#SBATCH -o /scratch3/NCEPDEV/global/role.glopara/scripts/FIX/archive_fix_batch.log
#SBATCH --export=NONE

set -eaux

#module load hpss/hpss

cd /scratch3/NCEPDEV/global/role.glopara/fix
XZ_OPT='-T0 -9' tar -cJf "/scratch3/NCEPDEV/stmp/role.glopara/fix_tars/fix.gsi.20250529.tar.xz" "gsi/20250529"
