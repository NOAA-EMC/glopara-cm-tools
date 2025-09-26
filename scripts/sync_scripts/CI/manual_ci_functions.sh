#! /usr/bin/bash

function monitor_expdir {
        # Loop through all experiments and report all active tasks.
        # If there are no active tasks, report the status of the last two tasks
        # (should be SUCCEEDED).
        #
        # After looping through all directories, sleep for 5 min, then run again.
        #
        # This will run until interrupted with CTRL+C.
        #
        while true; do
                echo; echo
                date
                for d in *; do
                        echo "******** ${d} ********"
                        cd "${d}"
                        rocotostat -d "${d}.db" -w "${d}.xml" | grep -E --color 'SUBMITTING|QUEUED|RUNNING|DEAD' || rocotostat -d "${d}.db" -w "${d}.xml" -s
                        echo
                        cd ..
                done
                echo
                sleep 300
        done
}

function setup_pr {
        # Checkout and build a PR, then setup CI tests to run
        #
        # The envvar $CI_PTMP must be defined. Clone and tests
        # will be placed in ${CI_PTMP}/PR/PR_####.
        #
        # "Building" and "Running" labels will be set on the PR
        # at the appropriate points.
        #
        # After CI cases are created, will move to the EXPDIR and
        # start monitoring the jobs. (rocotorun must be set up
        # separately.)
        #
        # usage: setup_pr <pr>
        #
        #   pr: NOAA-EMC/global-workflow PR number to test
        #
        local pr=${1:?}

        local pr_dir="${CI_PTMP:?}/PR/PR_${pr}"
        rm -Rf "${pr_dir}"
        mkdir -p "${pr_dir}"
        cd "${pr_dir}" || return 10

        git clone https://github.com/NOAA-EMC/global-workflow.git
        cd global-workflow
        git submodule update --init --recursive --jobs 8
        cd sorc
        ./build_compute.sh all
        ./link_workflow.sh
        cd ../workflow
        ./generate_workflows.sh -GEt "${pr}" "${pr_dir}/RUNTESTS"
        cd "${pr_dir}/RUNTESTS/EXPDIR" || return 10
        perl -i -p -e "s%(?<=taskthrottle=\")\d*(?=\")%100%" "C96_atm3DVar_extended_${pr}/C96_atm3DVar_extended_${pr}.xml"
        perl -i -p -e "s%(?<=taskthrottle=\")\d*(?=\")%100%" "C48_S2SWA_gefs_${pr}/C48_S2SWA_gefs_${pr}.xml"
        perl -i -p -e "s%(?<=taskthrottle=\")\d*(?=\")%100%" "C96_S2SWA_gefs_replay_ics_${pr}/C96_S2SWA_gefs_replay_ics_${pr}.xml"
        for exp in *; do
            cd "${exp}"
            rocotorun -d "${exp}.db" -w "${exp}.xml"
            cd ..
        done
        monitor_expdir
}


function del_pr {
        # Removed the archive and run (DATAROOT) directories for a
        # given PR. These are read from the config.base files.
        #
        # Then deletes the PR directory.
        #
        # Assumes PR was set up by setup_pr() and created under
        # ${CI_PTMP}/PR/PR_${pr}. ($CI_PTMP must be defined.)
        #
        # usage: del_pr <pr>
        #
        #   pr: PR number to delete
        #
        for pr in "$@"; do
                echo "Removing PR ${pr}"
                pr_dir="${CI_PTMP:?}/PR/PR_${pr}"
                for exp_dir in "${pr_dir}/RUNTESTS/EXPDIR/"*; do
                        pslot=$(basename "${exp_dir}")
                        archive_dir=$(grep 'export ARCDIR=' "${exp_dir}/config.base" | cut -d'=' -f2 | tr -d '[:space:]"' | PSLOT="${pslot}" envsubst) || false
                        data_root=$(grep -Po -m 1 '(?<=<envar><name>DATAROOT</name><value>)(.*)(?=/gfs.<cyclestr>@Y@m@d@H</cyclestr></value></envar>)' "${exp_dir}/${pslot}.xml")
                        echo "Removing archive directory ${archive_dir}"
                        rm -Rf "${archive_dir}"
                        echo "Removing DATAROOT ${data_root}"
                        rm -Rf "${data_root}"
                done
                echo "Removing PR directory ${pr_dir}"
                rm -Rf "${pr_dir}"
        done
}

