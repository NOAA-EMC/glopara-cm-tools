#! /bin/bash

# date
source /usr/share/lmod/8.3.1/init/sh
module use /apps/ops/test/nco/modulefiles/core
module load rocoto/1.3.5

declare -a exp_roots=($(find /lfs/h2/emc/ptmp/emc.global/PR/ -type d -name EXPDIR))
# exp_roots+=($(find /another/path/ -type d -name EXPDIR))

# echo "=== Running rocoto for all experiments ==="

for exp_root in "${exp_roots[@]}"; do
	if [[ -z "${exp_root}" ]]; then continue; fi
	for exp_dir in $(find ${exp_root}/* -maxdepth 0 -type d); do
		exp=$(basename "${exp_dir}")
		echo "== Running rocoto for ${exp} at $(date) =="
		echo ${exp_dir}
		cd "${exp_dir}" || exit 9
		if [ -f workflow.xml ]; then
			rocotorun -d "workflow.db" -w "workflow.xml" >> "rocoto.log"
		elif [[ -f ${exp}.xml ]]; then
			rocotorun -d "${exp}.db" -w "${exp}.xml" >> "rocoto.log"
		fi
		echo "== Rocoto completed for ${exp} at $(date) =="
	done
done
