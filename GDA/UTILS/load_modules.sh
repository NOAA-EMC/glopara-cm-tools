#!/bin/sh
#set -x

###############################################################
# Setup runtime environment by loading modules
ulimit_s=$( ulimit -S -s )
#ulimit -S -s 10000

set +x

# Find module command and purge:
source "$HOMEgda/gda/modulefiles/module-setup.sh.inc" 

# Source versions file for runtime
source "$HOMEgda/versions/run.ver"

# Load our modules:
module use $HOMEgda/gda/modulefiles

if [[ -d /lfs/h2 ]]; then
    # We are on WCOSS2 (Cactus or Dogwood)
    source "$HOMEgda/versions/wcoss2.ver"
    module load module_base.wcoss2
else
    echo WARNING: UNKNOWN PLATFORM 
fi

set -x

# Restore stack soft limit:
ulimit -S -s "$ulimit_s"
unset ulimit_s
