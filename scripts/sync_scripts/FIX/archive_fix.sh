#!/usr/bin/env bash
# This is a wrapper around an sbatch script to allow passing arguments
set -eu
export fix_dir="/scratch3/NCEPDEV/global/role.glopara/fix"
export hpss_dir="/5year/NCEPDEV/emc-global/emc.glopara/fix"
export ptmp_dir=${ptmp_dir:-"/scratch3/NCEPDEV/stmp/role.glopara/fix_tars"}
export input_dir=$1
export tarfile=fix.${input_dir//\//.}.tar
export fix_type=${1%%/*}
sbatch <<EOF
#!/usr/bin/env bash
#SBATCH -n 4
#SBATCH -t 06:00:00
#SBATCH --partition=u1-service
#SBATCH --account=fv3-cpu
#SBATCH --job-name=push_fix_hpss
#SBATCH --output=archive_fix.log
#SBATCH --open-mode=truncate
#SBATCH --export=all

set -eux

# Directory locations
mkdir -p "${ptmp_dir}"

num_errs=0

if [[ ! ${input_dir} =~ [0-9]{8}$ ]] && [[ "${fix_type}" != crtm ]]; then
    echo "ERROR: Final directory does not appear to be a timestamp"
    echo "       ${input_dir} does not end in 8 digits"
    exit 1
fi

cd "${fix_dir}"
echo "Compressing ${input_dir}"
tar -cvf "${ptmp_dir}/${tarfile}" "${input_dir}"

pigz -9 -p 4 "${ptmp_dir}/${tarfile}"

cd "${ptmp_dir}"
echo "Transfering ${tarfile} to HPSS"
/apps/hpss/hsi put "${tarfile}.gz" : "${hpss_dir}/${tarfile}.gz"

echo "Removing local tarball"
rm -f "${ptmp_dir}/${tarfile}"
rm -f "${ptmp_dir}/${tarfile}.gz"
echo "Finished pushing data!"
exit 0
EOF
