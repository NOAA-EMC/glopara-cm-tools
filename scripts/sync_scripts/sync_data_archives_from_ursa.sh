#!/bin/bash

############################
# This script is used to sync data archives from Ursa to the local machine.
# It checks the hostname of the machine it is running on and sets the appropriate paths for the data archives.
# It accepts the following optional arguments:
#   -n N: the number of days of GDA data to sync (default is 5)
#   -d YYYYMMDD: the date to start syncing GDA data from (default is today)
#   -a (default) sync all data (syndat, verif, and GDA)
#   -s: sync only syndat data
#   -v: sync only verif data
#   -g: sync only GDA data
#   -f: sync only fix (static) data
#   -h: display the help message
#   -D: enable debug mode (will run rsync with --dry-run)
# It will then sync data from Ursa starting on the specified date and going
# back the specified number of days.
############################

usage() {
    echo "Usage: $0 [-n N] [-d YYYYMMDD]"
    echo "  -n N: number of days of GDA data to sync (default is 5)"
    echo "  -a : sync all data (syndat, verif, and GDA) (default)"
    echo "  -s : sync only syndat data"
    echo "  -v : sync only verif data"
    echo "  -g : sync only GDA data"
    echo "  -f : sync only fix (static) data"
    echo "  -d YYYYMMDD: date to start syncing GDA data from (default is today)"
    echo "               Only valid for the GDA; otherwise ignored."
    echo "  -h : display this help message"
    echo "  -D : enable debug mode"
    exit 1
}

num_days=5
start_date=$(date +%Y%m%d)
debug=0
dash_a=0
sync_syndat=0
sync_verif=0
sync_gda=0
sync_fix=0
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
    -s)
        sync_syndat=1
        shift
        ;;
    -v)
        sync_verif=1
        shift
        ;;
    -g)
        sync_gda=1
        shift
        ;;
    -f)
        sync_fix=1
        shift
        ;;
    -a)
        dash_a=1
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

if [[ ${sync_syndat} -eq 0 && ${sync_verif} -eq 0 && ${sync_gda} -eq 0 && ${dash_a} -eq 0 && ${sync_fix} -eq 0 ]]; then
    echo "INFO: No sync options specified, defaulting to syncing all data."
    dash_a=1
fi

if [[ ${dash_a} -eq 1 ]]; then
    sync_syndat=1
    sync_verif=1
    sync_gda=1
    sync_fix=1
fi

# If in debug mode, run rsync with --dry-run
dry_run=""
if [[ ${debug} -eq 1 ]]; then
    dry_run="--dry-run"
fi

HOST=$(hostname)
ursa_glopara_root=/scratch3/NCEPDEV/global/role.glopara
ursa_dtn=role.glopara@dtn-ursa.fairmont.rdhpcs.noaa.gov
host=rdhpcs
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
elif [[ ${HOST} =~ clogin || ${HOST} =~ dlogin ]]; then
    echo "Running on WCOSS2"
    glopara_root=/lfs/h2/emc/global/noscrub/emc.global
    gda_root=/lfs/h2/emc/global/noscrub/emc.global/dump
    host=wcoss2
    # Do NOT sync GDA, syndat, or metplus data on WCOSS2. This data originates from WCOSS2 production.
    if [[ ${sync_gda} -eq 1 || ${sync_syndat} -eq 1 || ${sync_verif} -eq 1 ]]; then
        echo "INFO: Skipping GDA, syndat, and metplus data sync on WCOSS2."
        sync_gda=0
        sync_verif=0
        sync_syndat=0
    fi
else
    echo "This script is not yet supported for this machine: ${HOST}"
    exit 1
fi

gda_root=${gda_root:-${glopara_root}/dump}

############################
# Sync syndat data from Ursa
############################
if [[ ${sync_syndat} -eq 1 ]]; then
    echo "Syncing syndat data from Ursa"
    cd ${glopara_root}/com
    rsync -av "${dry_run}" ${ursa_dtn}:${ursa_glopara_root}/com/gfs/prod/syndat .
fi

############################
# Sync verif data from Ursa
############################
if [[ ${sync_verif} -eq 1 ]]; then
    echo "Syncing verif data from Ursa"
    job_pids=()
    job_names=()
    cd ${glopara_root}/data
    # Run these in parallel to speed up the sync process.
    for dir in archive cartopy obdata obs_data prepbufr; do
        rsync -av "${dry_run}" ${ursa_dtn}:${ursa_glopara_root}/data/metplus.data/${dir} ${dir} >& ~/rsync_${dir}.log &
        job_pids+=($!)
        job_names+=(${dir})
        sleep 1s
    done
    sleep 2s

    i=0
    for pid in "${job_pids[@]}"; do
        wait $pid
        echo "Finished syncing ${job_names[$i]}. Log:"
        cat ~/rsync_${job_names[$i]}.log
        if [[ $? -ne 0 ]]; then
            echo "Error: rsync failed for the ${job_names[$i]} directory"
            exit 1
        fi
        i=$((i + 1)) || true
    done
fi

############################
# Sync fix data from Ursa
############################
if [[ ${sync_fix} -eq 1 ]]; then
    echo "Syncing fix data from Ursa"
    job_pids=()
    job_names=()
    cd ${glopara_root}/fix
    # Run these in parallel to speed up the sync process.
    for dir in aer am archive_fix_batch.log  chem cice cpl crtm datm gdas gldas glwu gsi lut mom6 orog raw reg2grb2 sfc_climo ugwd verif wave; do
        rsync -av "${dry_run}" ${ursa_dtn}:${ursa_glopara_root}/fix/${dir} ${dir} >& ~/rsync_${dir}.log &
        job_pids+=($!)
        job_names+=(${dir})
        sleep 1s
    done
    sleep 2s

    i=0
    for pid in "${job_pids[@]}"; do
        wait $pid
        echo "Finished syncing ${job_names[$i]}. Log:"
        cat ~/rsync_${job_names[$i]}.log
        if [[ $? -ne 0 ]]; then
            echo "Error: rsync failed for the ${job_names[$i]} directory"
            exit 1
        fi
        i=$((i + 1)) || true
    done
fi

#############################
# Sync GDA data from Ursa
#############################
if [[ ${sync_gda} -eq 1 ]]; then
    echo "Syncing GDA data from Ursa"
    # The GDA is quite large, so we will only sync the past X days of data.
    for i in $(seq 0 $((num_days - 1))); do
        day=$(date -d "${today} - ${i} days" +%Y%m%d)
        echo "Syncing GDA data for ${day}"
        # Sync gdas, gdasx, gdasy, gdasnr, gfs, gfsx, gfsy, gfsnr, and rtofs
        # gdas, gdasnr, gfs, gfsnr, and rtofs should always be present, so raise an error if rsync fails.
        warn_run="gdasx gdasy gfsx gfsy"
        for RUN in gdas gdasnr gfs gfsnr rtofs gdasx gdasy gfsx gfsy; do
            # Check for existence of the file on Ursa before attempting to rsync
            rsync --list-only ${ursa_dtn}:${ursa_glopara_root}/dump/${RUN}.${day} >/dev/null 2>&1
            if [[ $? -ne 0 ]]; then
                continue
            fi
            rsync -av "${dry_run}" ${ursa_dtn}:${ursa_glopara_root}/dump/${RUN}.${day} ${gda_root}/
            if [[ $? -ne 0 ]]; then
                for warn in ${warn_run}; do
                    if [[ ${RUN} == ${warn} ]]; then
                        echo "Warning: rsync failed for ${RUN}.${day}, but this is not a critical file."
                        continue 2
                    fi
                done
                echo "Error: rsync failed for ${RUN}.${day}"
                exit 1
            fi
        done
    done
fi

echo "Done"
exit 0
