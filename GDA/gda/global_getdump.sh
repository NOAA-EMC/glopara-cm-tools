#!/bin/sh
################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         global_getdump.sh
# Script description:  Copies a global dump
#
# Author:        Mark Iredell       Org: NP23         Date: 1999-07-15
#
# Abstract: This script copies a global dump.
#
# Script history log:
# 1999-05-01  Mark Iredell
# 2002-03-08  Mark Iredell  generalize suffixes
# 2005-01-24  Mark Iredell  transition to blue
# 2014-04-14  Kate Howard   reworked to handle files with period in name
# 2014-10-17  Kate Howard   reworked to pickup special para dataset 
# 2016-05-11  Kate Howard   reworked to handle regular dump stream scp from prod
# 2017-02-21  Kate Howard   Added new datasets: dbnet, rars, saphir
# 2017-03-20  Kate Howard   Added archival of prepbufr and aircraft profile file per user request
# 2018-10-30  Kate Friedman Removed parallel naming convention and updated for running on Dells
# 2022-04-29  Kate Friedman Ported to WCOSS2
#
# Usage:  global_getdump.sh CDATE CDUMP FILES
#
#   Input script positional parameters:
#     1             Current date in YYYYMMDDHH form
#                   defaults to $CDATE; required
#     2             Current dump (gfs or fnl)
#                   defaults to $CDUMP, then to fnl
#     3             Dump file list
#                   defaults to $FILES, then to all possible
#
#   Imported Shell Variables:
#     COMOUT        output directory
#                   (if nonexistent will be made)
#                   defaults to current working directory
#     NCP           Copy command
#                   defaults to cp
#     VERBOSE       Verbose flag (YES or NO)
#                   defaults to NO
#
# Attributes:
#   Language: POSIX shell
#   Machine: IBM SP
#
####

################################################################################
#  Set environment.

export CDATE=${1:-${CDATE:?}}
export CDUMP=${2:-${CDUMP:-gdas}}
export COMIN=${3:-${COMOBSTMP}}
nshift=$#
[[ $nshift -le 3 ]]||nshift=3
shift $nshift
export FILES="${*:-${DFILES}}"

# Capture all of the arguments to this script as a variable
arguments="$0 $*"

export VERBOSE=${VERBOSE:-"NO"}
if [[ "$VERBOSE" = "YES" ]]
then
   echo $(date) EXECUTING ${arguments} >&2
   set -x
fi
day=${day:-$(echo $CDATE|cut -c1-8)}
cyc=${cyc:-$(echo $CDATE|cut -c9-10)}
cyctz=${cyctz:-t$(echo $CDATE|cut -c9-10)z}

send_email () {
 # Check if mailfile exists and is non-zero size, then mail it
 if [[ -z "${mailfile+x}" ]]; then
   echo "FATAL ERROR: No mailfile provided to send_email, exiting..."
   exit 1
 fi

 if [[ -s "${mailfile}" ]]; then
   subject="global_getdump.sh recorded warning/errors"
   # mail to $maillist, a comma-separated list of email addresses
   cat ${mailfile} | mail -s "$subject" $maillist
 fi
}

export COMPONENT="atmos"
com_gfs_ver=${com_gfs_ver:-${gfs_version:-v16.3}}
export COMGFSTMP=${COMGFSTMP:-${COMROOT}/gfs/${com_gfs_ver}/$CDUMP.\$day/$CDUMP.\$cyctz/${COMPONENT}/${CDUMP}.\$cyctz}
export COMOBSTMP=${COMOBSTMP:-${COMROOT}/obsproc/v1.1/$CDUMP.\$day/$CDUMP.\$cyctz/${COMPONENT}/${CDUMP}.\$cyctz}
export COMGFSPRE=${COMGFSPRE:-$CDUMP.\$cyctz}
export COMOUT=${COMOUT:-$(pwd)}
export NCP=${DMPCPCMD:-${NCP:-cp}}
export DMPCPLOC=${DMPCPLOC:-prod}

################################################################################
#  Copy to $DATA directory

cpy=""
cpn=""

# Copy files from obsproc com
for ft in $FILES
do
   eval fto=$COMIN.$ft
   eval ftn=$COMOUT/$COMGFSPRE.$ft
   if [ $DMPCPLOC = dev ]; then
     $NCP $USER@${omac}:$fto $ftn
   else
     $NCP $fto $ftn
   fi
   if [[ $? -eq 0 ]]
   then
      chmod 644 $ftn
      cpy="$cpy $ft"
   else
      cpn="$cpn $ft"
   fi
done

#if [ $DALERT = "NO" ]; then
# Copy files from gfs com
#for ft in $FILES_GFS
#do
#  eval fto=$COMGFSTMP.$ft
#  eval ftn=$COMOUT/$COMGFSPRE.$ft
#  if [ $DMPCPLOC = dev ]; then
#    $NCP $USER@${omac}:$fto $ftn
#  else
#    $NCP $fto $ftn
#  fi
#  if [[ $? -eq 0 ]]
#  then
#    chmod 644 $ftn
#    cpy="$cpy $ft"
#  else
#    cpn="$cpn $ft"
#  fi
#done
#fi

# List files not copied
echo File types     copied: $cpy
echo File types NOT copied: $cpn

export err=0

echo "Files copied into $COMOUT"
$NLL $COMOUT

if [[ ! -z "${cpn}" ]]; then
  if [[ "${do_mail:-NO}" = "YES" ]]; then
    mailfile=/tmp/getdump.$$.msg
    echo "WARNING: Some files were not copied" >> $mailfile
    echo "global_getdump.sh called as follows:" >> $mailfile
    echo "  $arguments" >> $mailfile
    for file_not_copied in $cpn; do
      echo "  $file_not_copied" >> $mailfile
    done
    send_email
  fi
fi

################################################################################
#  Postprocessing
set +x
if [[ "$VERBOSE" = "YES" ]]
then
   echo $(date) EXITING $0 with return code $err >&2
fi
exit $err
