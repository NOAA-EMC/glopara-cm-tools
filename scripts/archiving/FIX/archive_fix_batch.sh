#! /bin/bash
#SBATCH --job-name=archive_fix_batch
#SBATCH --account=fv3-cpu
#SBATCH --qos=batch
#SBATCH --partition=u1-compute
#SBATCH -t 00:30:00
#SBATCH --nodes=3-3
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=288GB
#SBATCH -o /scratch3/NCEPDEV/global/role.glopara/scripts/FIX/archive_fix_batch.log
#SBATCH --export=NONE

set -eau
set -x

#module load hpss/hpss

type="wave"
timestamp="20250508"

export ptmp_dir="/scratch3/NCEPDEV/stmp/role.glopara/fix_tars/${type}_${timestamp}"

sh /scratch3/NCEPDEV/global/role.glopara/scripts/FIX/archive_fix.sh ${type}/${timestamp}
status=$?
[[ ${status} -ne 0 ]] && exit "${status}"

rm -rf "${ptmp_dir}"
