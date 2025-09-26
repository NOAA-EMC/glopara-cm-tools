#! /bin/bash
#SBATCH --job-name=archive_fix_batch
#SBATCH --account=fv3-cpu
#SBATCH --qos=batch
#SBATCH --partition=hera
#SBATCH -t 00:30:00
#SBATCH --nodes=3-3
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=288GB
#SBATCH -o /scratch1/NCEPDEV/global/glopara/scripts/FIX/archive_fix_batch_gdas.log
#SBATCH --export=NONE

set -eau

module load hpss/hpss

type="gdas/soca"
timestamp="20250519"

dir="${type}/${timestamp}"
#tarfile=fix.${dir/\//.}.tar.xz
tarfile=fix.${dir//\//.}.tar.xz

fix_dir="/scratch1/NCEPDEV/global/glopara/fix"
hpss_dir="/5year/NCEPDEV/emc-global/emc.glopara/fix"

export ptmp_dir="/scratch1/NCEPDEV/stmp2/glopara/fix_tars/gdas_${timestamp}"
mkdir -p "${ptmp_dir}"

cd /scratch1/NCEPDEV/global/glopara/fix

XZ_OPT='-T0 -9' tar -cJf "${ptmp_dir}/${tarfile}" "${dir}"
cd "${ptmp_dir}"
/apps/hpss/hsi put "${tarfile}" : "${hpss_dir}/${tarfile}"

