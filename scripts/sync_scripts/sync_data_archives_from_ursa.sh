#!/bin/bash

############################
# This script is used to sync data archives from Ursa to the local machine.
# It checks the hostname of the machine it is running on and sets the appropriate paths for the data archives.
# It accepts two optional arguments:
#   -n N: the number of days of GDA data to sync (default is 5)
#   -d YYYYMMDD: the date to start syncing GDA data from (default is today)
# It will then sync data from Ursa starting on the specified date and going
# back the specified number of days.
############################

usage() {
  echo "Usage: $0 [-n N] [-d YYYYMMDD]"
  echo "  -n N: number of days of GDA data to sync (default is 5)"
  echo "  -d YYYYMMDD: date to start syncing GDA data from (default is today)"
  echo "  -h : display this help message"
  echo "  -D : enable debug mode"
  exit 1
}

num_days=5
start_date=$(date +%Y%m%d)
debug=0
for arg in "$@"; do
  case $arg in
    -n)
        shift
        num_days=$1
        # Check that num_days is a positive integer
        if ! [[ ${num_days} =~ ^[0-9]+$ ]]; then
            echo "Error: Number of days must be a positive integer."
            usage
        fi
        shift
        ;;
    -d)
        shift
        start_date=$1
        # Check that the start date is valid
        if ! date -d "${start_date}" >/dev/null 2>&1; then
            echo "Error: Invalid date format. Please use YYYYMMDD."
            usage
        fi
        # Check the length is 8 characters
        if [[ ${#start_date} -ne 8 ]]; then
            echo "Error: Invalid date format. Please use YYYYMMDD."
            usage
        fi
        shift
        ;;
    -h)
        usage
        ;;
    -D)
        set -x
        debug=1
        shift
        ;;
    *)
  esac
done

# If in debug mode, run rsync with --dry-run
dry_run=""
if [[ ${debug} -eq 1 ]]; then
    dry_run="--dry-run"
fi

HOST=$(hostname)
ursa_glopara_root=/scratch3/NCEPDEV/global/role.glopara
ursa_dtn=role.glopara@dtn-ursa.fairmont.rdhpcs.noaa.gov
if [[ ${HOST} =~ hfe ]]; then
  echo "Running on Hera, nothing to do"
  exit 1
elif [[ ${HOST} =~ ufe ]]; then
  echo "Running on Ursa, nothing to do"
  exit 1
elif [[ ${HOST} =~ gaea6 ]]; then
  echo "Running on Gaea C6"
  glopara_root=/gpfs/f6/drsa-precip3/world-shared/role.glopara
elif [[ ${HOST} =~ hercules || ${HOST} =~ orion ]]; then
  echo "Running on MSU"
  glopara_root=/work2/noaa/global/role-global
  gda_root=/work/noaa/rstprod/dump
else
  echo "This script is not yet supported for this machine: ${HOST}"
  exit 1
fi

gda_root=${gda_root:-${glopara_root}/dump}

############################
# Sync syndat data from Ursa
############################
cd ${glopara_root}/com
rsync -av "${dry_run}" ${ursa_dtn}:${ursa_glopara_root}/com/gfs/prod/syndat .

############################
# Sync verif data from Ursa
############################
cd ${glopara_root}/data
rsync -av role.glopara@dtn-ursa.fairmont.rdhpcs.noaa.gov:/scratch3/NCEPDEV/global/role.glopara/data/metplus.data .

#############################
# Sync GDA data from Ursa
#############################
# The GDA is quite large, so we will only sync the past X days of data.
for i in $(seq 0 $((num_days - 1))); do
    day=$(date -d "${today} - ${i} days" +%Y%m%d)
    echo "Syncing GDA data for ${day}"
    # Sync gdas, gdasx, gdasy, gdasnr, gfs, gfsx, gfsy, gfsnr, and rtofs
    # gdas, gdasnr, gfs, gfsnr, and rtofs should always be present, so raise an error if rsync fails.
    for RUN in gdas gdasnr gfs gfsnr rtofs; do
        rsync -av "${dry_run}" ${ursa_dtn}:${ursa_glopara_root}/dump/${RUN}.${day} ${gda_root}/
        if [[ $? -ne 0 ]]; then
            echo "Error: rsync failed for ${RUN}.${day}"
            exit 1
        fi
    done
    # gdasx, gdasy, gfsx, and gfsy may not be
    for RUN in gdasx gdasy gfsx gfsy; do
        # Check for existence of the file on Ursa before attempting to rsync
        rsync --list-only ${ursa_dtn}:${ursa_glopara_root}/dump/${RUN}.${day} >/dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            continue
        fi
        rsync -av "${dry_run}" ${ursa_dtn}:${ursa_glopara_root}/dump/${RUN}.${day} ${gda_root}/
        if [[ $? -ne 0 ]]; then
            echo "Warning: rsync failed for ${RUN}.${day}, continuing"
        fi
    done
done

echo "Done"
exit 0
