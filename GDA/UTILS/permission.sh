#Change permissions of incoming dump data

set -x

export HOMEgda=${HOMEgda:-"/lfs/h2/emc/global/save/emc.global/dump_archive"}
export EXPDIR=${EXPDIR:-$HOMEgda/gda}

CONFIG=${CONFIG:-$EXPDIR/config.dumparch}
set -a;. $CONFIG;set +a

CHGRP_CMD="chgrp rstprod"
DMPDIR=${DMPDIR:-"/lfs/h2/emc/dump/noscrub/dump"}

source "$HOMEgda/versions/run.ver"
source "$HOMEgda/versions/wcoss2.ver"

export NDATE=${NDATE:-"/apps/ops/prod/nco/core/prod_util.v${prod_util_ver}/exec/ndate"}

date=${1:-$date}
edate=${2:-$date}
NFREQ=${3:-"06"}

COMPONENT=${COMPONENT:-"atmos"}

while [ $date -le $edate ];
do

 PDY=`expr $date | cut -c1-8`
 cyc=`expr $date | cut -c9-10`

 for CDUMP in gdas gfs rtofs ; do

  if [ $CDUMP = "gdas" -o $CDUMP = "gfs" ]; then

   for dump in ${CDUMP} ${CDUMP}x ${CDUMP}y ${CDUMP}v ${CDUMP}p ; do

    dirpdy=$DMPDIR/${dump}.${PDY}

    if [ -d $dirpdy ]; then

     dircyc=$DMPDIR/${dump}.${PDY}/${cyc}
     dircom=$DMPDIR/${dump}.${PDY}/${cyc}/${COMPONENT}

     chmod 755 $dirpdy
     chgrp global $dirpdy

     if [ -d $dircyc -a $CDUMP != "rtofs" ]; then

      chmod 755 $dircyc
      chgrp global $dircyc
      chmod 755 $dircom
      chgrp global $dircom
      chmod 644 $dircom/*
      chgrp global $dircom/*

      # Set rstprod permissions
      dlist=$DFILES_RSTPROD
      for dfile in $dlist; do
        $CHGRP_CMD ${dircom}/*${dfile}*
        chmod 640 ${dircom}/*${dfile}*
      done # dlist

     fi # dircyc exists and not rtofs
    fi # dump folder exists

   done # dump loop

  elif [ $CDUMP = "rtofs" ]; then

    dirpdy=$DMPDIR/$CDUMP.${PDY}
   
    if [ -d $dirpdy ]; then
    
      chmod 755 $dirpdy
      chgrp global $dirpdy
      chmod 644 $dirpdy/*
      chgrp global $dirpdy/*

    fi

  fi

 done # CDUMPS loop

 #adate=`$NDATE +06 $date`
 adate=`$NDATE +${NFREQ} $date`
 date=$adate
done # date to edate backfill
