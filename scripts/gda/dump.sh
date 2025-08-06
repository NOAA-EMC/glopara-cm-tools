#!/bin/bash
set -x

###############################################################
# Source FV3GFS workflow modules
. $HOMEgfs/ush/load_fv3gfs_modules.sh
status=$?
[[ $status -ne 0 ]] && exit $status

###############################################################
# Source relevant configs
configs="base dumparch"
for config in $configs; do
    . $EXPDIR/config.${config}
    status=$?
    [[ $status -ne 0 ]] && exit $status
done

##############################################
# Obtain unique process id (pid) and make temp directory
##############################################
export pid=${pid:-$$}
export DATA=${DATA:-${DATAROOT}.${pid}}
mkdir -p $DATA
cd $DATA

##############################################
# Initialize variables
##############################################
#setpdy.sh
#. ./PDY
# Set date variables
export day=${day:-$(echo $CDATE|cut -c1-8)}
export cyc=${cyc:-$(echo $CDATE|cut -c9-10)}
export cyctz=${cyctz:-t$(echo $CDATE|cut -c9-10)z}
# Calculate whether to sleep after alert file detected
export zdiff=${zdiff:-6}
if [ $cyc = 18 ]; then
  export zdiff=82
fi
export now=`date -u +%Y%m%d%H`
export tdiff=$( expr $now - $CDATE )

export COMPONENT=${COMPONENT:-"atmos"}
export COMGFSTMP=${COMGFSTMP:-/gpfs/dell1/nco/ops/com/gfs/prod/$CDUMP.$day/$cyc/$CDUMP.$cyctz}
export COMGFSPRE=${COMGFSPRE:-$CDUMP.$cyctz}
export COMDAY=${COMDAY:-$DMPDIR/${CDUMP}${DUMP_SUFFIX}.$day}
export COMCYC=${COMCYC:-$DMPDIR/${CDUMP}${DUMP_SUFFIX}.$day/$cyc}
export COMDMP=${COMDMP:-$DMPDIR/${CDUMP}${DUMP_SUFFIX}.$day/$cyc/$COMPONENT}
export group_name=${group_name:-global}
export permission=${permission:-755}
# Alert file to kick off dump pickup
export alertf=${alertf:-dump_alert_flag.tm00}

export DALERT=${DALERT:-NO}
export DMPSUP=${DMPSUP:-NO}
export DMPHERA=${DMPHERA:-NO}
export DMPURSA=${DMPURSA:-NO}
export DMPCPCMD=${DMPCPCMD:-$NCP}

export SUP_BACK=${SUP_BACK:-"24"}

##############################################
# Determine Job Output Name on System
##############################################
export pgmout="OUTPUT.${pid}"
export pgmerr=errfile

###############################################################
# Wait until alert file exists

if [[ $DALERT = YES ]]; then
  #$HOMEgfs/ush/global_getdump.sh $CDATE $CDUMP $alertf
  $EXPDIR/global_getdump.sh $CDATE $CDUMP $alertf
  echo status=$?
  [[ $status -ne 0 ]] && exit $status
  until [[ -s $DATA/$CDUMP.$cyctz.$alertf ]];do
     if [[ $((nsleep+=1)) -gt $msleep ]];then exit 1;fi
     sleep $tsleep
     #$HOMEgfs/ush/global_getdump.sh $CDATE $CDUMP dump_alert_flag.tm00
     $EXPDIR/global_getdump.sh $CDATE $CDUMP dump_alert_flag.tm00
     status=$?
     [[ $status -ne 0 ]] && exit $status
  done
fi
[[ $tdiff -le $zdiff ]] && sleep $zsleep

################################################################################
# Get dump files

#$HOMEgfs/ush/global_getdump.sh $CDATE $CDUMP $COMOBSTMP $DFILES
$EXPDIR/global_getdump.sh $CDATE $CDUMP $COMOBSTMP $DFILES
#$HOMEgfs/ush/global_getdump.sh $CDATE $CDUMP $COMGFSTMP $DFILES_GFS
$EXPDIR/global_getdump.sh $CDATE $CDUMP $COMGFSTMP $DFILES_GFS
status=$?
[[ $status -ne 0 ]] && exit $status

################################################################################
# Copy out output and restart files

# Make dump archive directory
if [ ! -d "$COMDMP" ]; then
  mkdir -p $COMDMP
fi

# Change directory group and permissions to agree w/ NCEP restricted data policies.
#chgrp $group_name $DMPDIR/$CDATE
#chmod $permission $DMPDIR/${CDUMP}${DUMP_SUFFIX}.$day
chmod $permission $COMDAY
chmod $permission $COMCYC
#chgrp $group_name $COMDMP
chmod $permission $COMDMP

# Move files to dump archive
echo "Moving dump files to global dump archive: $COMDMP"
$DMPCPCMD $DATA/ $COMDMP/
status=$?
[[ $status -ne 0 ]] && exit $status

################################################################################
# Archive supplemental data and transfer dump files to other machines

if [[ $DMPSUP = 'YES' ]]; then
  $SUPSH -c $CDATE -d $CDUMP -b $SUP_BACK
fi

################################################################################
# Optional special processing
#$OBSPROCSH

##########################################
# Remove the Temporary working directory
##########################################
[[ $KEEPDATA = "NO" ]] && rm -rf $DATA

################################################################################
# Exit out cleanly
exit $status
