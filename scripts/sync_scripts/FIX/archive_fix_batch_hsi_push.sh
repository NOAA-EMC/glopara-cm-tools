#! /bin/bash
#SBATCH --job-name=archive_fix_batch
#SBATCH --account=fv3-cpu
#SBATCH -t 06:00:00
#SBATCH -n 1
#SBATCH --partition=u1-service
#SBATCH -o /scratch3/NCEPDEV/global/role.glopara/scripts/FIX/archive_fix_batch.log
#SBATCH --export=NONE

set -eaux

#module load hpss/hpss

cd /scratch3/NCEPDEV/stmp/role.glopara/fix_tars
hsi put "fix.gsi.20250529.tar.xz" : "/5year/NCEPDEV/emc-global/emc.glopara/fix/fix.gsi.20250529.tar.xz"
