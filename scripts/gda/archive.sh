# Script to submit all dump archive sub-scripts 
#
# 2012-05-18 K. Howard - Original version
# 2013-06-27 K. Howard - WCOSS version
# 2013-10-28 K. Howard - Added pulls for RTG, seaice, & GLDAS files
# 2015-05-22 K. Howard - Added IC pickup on Mondays
# 2015-12-30 K. Howard - Added pickup of new aircar and aircft bufr files
# 2016-11-17 K. Howard - Cleanup and enhancements, added backfill capability
# 2017-02-21 K. Howard - Turned off pickup of rars, dbnet, saphir data - now in production
# 2017-06-01 K. Howard - Added ahicsr pickup
# 2018-01-25 R. Treadon - Added BUFR buoy dump pickup
# 2019-02-01 K. Friedman - Script rewrite for move of GDA to Dells
# 2022-05-03 K. Friedman - Port to WCOSS2
# ------------------------------------------------------------------------------------------

set -x

# Command line options
# -------------------------------

while getopts ":c:e:d:f:l:n:b:" option;
do
 case $option in
  c)
   echo received -c with $OPTARG
   SDATE=$OPTARG
   ;;
  e)
   echo received -e with $OPTARG
   LDATE=$OPTARG
   ;;
  d)
   echo received -d with $OPTARG
   CDUMPS=$OPTARG
   ;;
  f)
   echo received -f with $OPTARG
   CONFIG=$OPTARG
   ;;
  l)
   echo received -l with $OPTARG
   clist=$OPTARG
   ;;
  n)
   echo received -n with $OPTARG
   NFREQ=$OPTARG
   ;;
  b)
   echo received -b with $OPTARG
   SYNC_BACK=$OPTARG
   ;;
  :)
   echo "option -$OPTARG needs an argument"
   ;;
  *)
   echo "invalid option -$OPTARG, exiting..." 
   exit 1
   ;;
  esac
done

if [[ -z "$SDATE" ]] ; then
  echo "Must supply -c SDATE (YYYYMMDDHH)!"
  exit 1
fi

# Set prod/dev machine
#prodmac=${prodmac:-`cat /lfs/h1/ops/prod/config/prodmachinefile | grep primary | cut -c9- | cut -c1`}
#devmac=${devmac:-`cat /lfs/h1/ops/prod/config/prodmachinefile | grep backup | cut -c 8- | cut -c1`}
#omac=${omac:-${devmac}dxfer.ncep.noaa.gov}
#USER=${USER:-emc.global}

export HOMEgda=${HOMEgda:-"/lfs/h2/emc/global/noscrub/emc.global/dump_archive"}
export EXPDIR=${EXPDIR:-$HOMEgda/gda}
# Source relevant configs
configs="base dumparch"
for config in $configs; do
 . $EXPDIR/config.${config}
 status=$?
 [[ $status -ne 0 ]] && exit $status
done

# Set defaults and read config
export LDATE=${LDATE:-$SDATE}
export CDUMPS=${CDUMPS:-'gfs gdas'}
export COMPONENT=${COMPONENT:-"atmos"}

send_email () {
 # Check if mailfile exists and is non-zero size, then mail it
 if [[ -z "${mailfile+x}" ]]; then
   echo "FATAL ERROR: No mailfile provided to send_email, exiting..."
   exit 1
 fi

 if [[ -s "${mailfile}" ]]; then
   export subject="GDA Dump Archive job recorded warning/errors"
   # mail to $maillist, a comma-separated list of email addresses
   cat ${mailfile} | mail -s "$subject" $maillist
 fi
}

if [[ ${do_mail:-NO} == "YES" ]]; then
  # Only mail errors and warnings
  export maillist=${maillist:-"david.huber@noaa.gov"}
  # Create a log file
  export mailfile=/tmp/gda_dump_archive_mailfile.$$
  echo "GDA Dump Archive job started at `date`" > $mailfile
fi

#export HOMEgda=${HOMEgda:-"/lfs/h2/emc/global/noscrub/emc.global/dump_archive"}
#export EXPDIR=${EXPDIR:-$HOMEgda/gda}

export NDATE=${NDATE:-"/apps/ops/prod/nco/core/prod_util.v${prod_util_ver}/exec/ndate"}
export DMPCPCMD=${DMPCPCMD:-"rsync -azv"}
export tmfix=${tmfix:-".tm00.bufr_d"}
export NFREQ=${NFREQ:-"06"}
export SYNC_BACK=${SYNC_BACK:-"0"}
export backchk="NO"
export machs=${machs:-"all"}

# Initialize modules
. $HOMEgfs/ush/load_fv3gfs_modules.sh
status=$?

if [[ $status -ne 0 ]]; then
  if [[ ${do_mail:-NO} == "YES" ]]; then
    echo "FATAL ERROR: Could not load modules, exiting..." >> $mailfile
    send_email
  fi
  exit $status
fi

#------------------------------------------------------
# Declare pickup function

pickup () {
 # Set variables
 date_in=$1; suffix=$2; prefix=$3; tmfix_yn=$4;
 CDUMP=$5; cycdir=$6; atmosdir=$7 idir=$8; odir=$9;

 date=`expr $date_in | cut -c1-8`
 cyc_in=`expr $date_in | cut -c9-10`

 # Check output directories exist and make if not
 if [ ! -d "$odir" ]; then
   mkdir -p $odir
 fi
 if [ ! -d "${odir}/${CDUMP}${suffix}.${date}/${cyc_in}/${COMPONENT}" ]; then
   mkdir -p ${odir}/${CDUMP}${suffix}.${date}/${cyc_in}/${COMPONENT}
 fi

 # Check tmfix_yn for whether it's needed for ifile and ofile
 if [ $tmfix_yn = "y" ]; then
   tmfix_in=$tmfix
   tmfix_out=$tmfix
 else
   tmfix_in=''
   tmfix_out=''
 fi

 # Check if processing nr/ur files (will come in with ".nr")
 if [ $suffix = "nr" -o $suffix = "ur" -o $suffix = "nrx" ]; then
   tmfix_in=${tmfix_in}.nr
 fi

 ifile_format=${CDUMP}.t${cyc_in}z.${prefix}${tmfix_in}
 ofile_format=${CDUMP}.t${cyc_in}z.${prefix}${tmfix_out}

 # Build ifile[b] & ofile
 if [ $cycdir = "y" -a $atmosdir = "n" ]; then
   ifile=${idir}/${CDUMP}.${date}/${cyc_in}/$ifile_format
 elif [ $cycdir = "y" -a $atmosdir = "y" ]; then
   ifile=${idir}/${CDUMP}.${date}/${cyc_in}/${COMPONENT}/$ifile_format
 else
   ifile=${idir}/${CDUMP}.${date}/$ifile_format
 fi
 ofile=${odir}/${CDUMP}${suffix}.${date}/${cyc_in}/${COMPONENT}/$ofile_format

 # Copy/rsync file to archive
 if [ -f $ifile ]; then
  echo "Rsyncing $ifile to $ofile"
  $DMPCPCMD $ifile $ofile
 else
  # Check file exists on other side and if not check backup if backchk=YES
  ssh ${omac} "test -e ${ifile}"
  rc=$?
  if [ $rc -eq 0 ]; then # Primary file exists
    echo "Rsyncing $ifile from ${omac} to $ofile"
    $DMPCPCMD $USER@${omac}:$ifile $ofile
  elif [ $rc -ne 0 ]; then # Primary file missing
    msg="WARNING: Target file $ifile is missing!"
    echo "$msg"
    if [ ${do_mail:-NO} == "YES" ]; then
      echo "$msg" >> $mailfile
    fi
  fi # rc check
 fi

}

#------------------------------------------------------
# Loop over $SDATE to $LDATE
DATE=$SDATE
while [ $DATE -le $LDATE ];
do

 PDY=`expr $DATE | cut -c1-8`
 YYYY=`expr $DATE | cut -c1-4`
 cyc=`expr $DATE | cut -c9-10`
 GDATE=`$NDATE -06 $DATE`
 BDATE=`$NDATE -24 $DATE`
 PDYm1=`expr $BDATE | cut -c1-8`
 cycm1=`expr $BDATE | cut -c9-10`
 #URDATE=`$NDATE -48 $DATE`
 URDATE=`$NDATE -54 $DATE`
 PDYUR=`expr $URDATE | cut -c1-8`
 cycUR=`expr $URDATE | cut -c9-10`
 JDAY=`date -d $PDY +%j`

 #------------------------------------------------------
 # Loop through cases

  #pickup inputs
  #date/PDY=YYYYMMDD; cyc=CC; suffix=x/y/nr; prefix=file; tmfix=y/n(tm00.bufr_d?);
  #CDUMP=gdas/gfs; cycdir=y/n; idir=input_folder; odir=output_folder;

  #Set initial values
  export odir=$DMPDIR

  #HISTORICAL#clist=${clist:-"gdasnr gdasur gmi ahicsr buoyb satwnd goes16v2 metopc ompslp satwnd_leogeo viirs omi ompsn cpcgauge rtofs crisfsr tac2bufr buoyb saldrn hdob gpsrox gpsroy mtiasi subpfl vadwnd"}
  #KF#clist=${clist:-"gdasnr gdasur gmi saldrn gpsrox subpfl cpcgauge"}
  #B4-v16.3#clist=${clist:-"gdasnr gdasur gmi saldrn gpsrox subpfl cpcgauge"}
  #TURN-OFF_GDASUR-20230525#clist=${clist:-"gdasnr gdasur noaa21 cpcgauge"}
  #clist=${clist:-"gdasnr noaa21 cpcgauge"}
  #B4-v16.3.12#clist=${clist:-"gdasnr noaa21 imsasc cpcgauge"}
  clist=${clist:-"gdasnr imsasc cpcgauge"}
  #clist=${clist:-"gdasnr gdasur"}
  #clist=${clist:-""}

  for c in $clist
  do
   case $c in
    #------------------------------------------------------
    gdasnr)
    # pickup gdas[gfs]nr files
     #Pickup production non-restricted files
     for CDUMP in $CDUMPS; do
      if [ $CDUMP = gdas -o $CDUMP = gfs ]; then
       backchk="NO"
       #idir=${COM}/gfs/prod
       idir=$COMOBS
       pickup $DATE nr adpsfc y $CDUMP y y $idir $odir
       pickup $DATE nr aircar y $CDUMP y y $idir $odir
       pickup $DATE nr aircft y $CDUMP y y $idir $odir
       pickup $DATE nr gpsipw y $CDUMP y y $idir $odir
       pickup $DATE nr gpsro y $CDUMP y y $idir $odir
       pickup $DATE nr sfcshp y $CDUMP y y $idir $odir
      fi
     done
    ;;
    #------------------------------------------------------
    #gdasur)
    # # ur-dumps 
    # # pickup unrestricted restricted files from Shelley (after 48hrs)
    # # WCOSS2 2022062812 - only aircar, aircft, prepbufr
    # # Discontinued pickup 20230525 - last cycle in archive 2023052300
    # for CDUMP in $CDUMPS; do
    #  if [ $CDUMP = gdas -o $CDUMP = gfs ]; then
    #   backchk="NO"
    #   idir=/lfs/h2/emc/stmp/shelley.melchior/CRON/nr33/com/obsproc/v1.1
    #   #pickup $URDATE ur adpsfc y $CDUMP y y $idir $odir
    #   pickup $URDATE ur aircar y $CDUMP y y $idir $odir
    #   pickup $URDATE ur aircft y $CDUMP y y $idir $odir
    #   #pickup $URDATE ur gpsipw y $CDUMP y y $idir $odir
    #   #pickup $URDATE ur gpsro y $CDUMP y y $idir $odir
    #   #pickup $URDATE ur sfcshp y $CDUMP y y $idir $odir
    #   #pickup $URDATE ur saphir y $CDUMP y y $idir $odir
    #   pickup $URDATE ur prepbufr n $CDUMP y y $idir $odir
    #  fi
    # done
    #;;
    #------------------------------------------------------
    #gmi)
    # pickup new gmi files
    # backfilled to 8/2 12z gdas, real-time 2016092012
    # for CDUMP in $CDUMPS; do
    #  if [ $CDUMP = gdas -o $CDUMP = gfs ]; then
    #   backchk="YES"
    #   idir=/lfs/h2/emc/stmp/iliana.genkova/CRON/GMI/com/obsproc/v1.0
    #   pickup $DATE x gmi1cr y $CDUMP y y $idir $odir
    #  fi
    # done
    #;;
    #------------------------------------------------------
    #saldrn)
    # pickup saildrone dump files from Steve (x-sub)
    # backfilled to 2020063018
    # started real-time 2020070212
    # for CDUMP in $CDUMPS; do
    #  if [ $CDUMP = gdas -o $CDUMP = gfs ]; then
    #   backchk="NO"
    #   idir=/lfs/h2/emc/ptmp/steve.stegall/CRON/NSST_subpfl_issue51959/com/obsproc/v1.0
    #   pickup $DATE x saldrn y $CDUMP y y $idir $odir
    #  fi
    # done
    #;;
    #------------------------------------------------------
    #gpsrox)
    # pickup gpsro dump files from Steve (x-sub)
    # Sentinel-6 GNSSRO
    # started 2021102000
    # GDAnrx copy started 2022042518
    # for CDUMP in $CDUMPS; do
    #  if [ $CDUMP = gdas -o $CDUMP = gfs ]; then
    #   backchk="NO"
    #   idir=/lfs/h2/emc/ptmp/steve.stegall/CRON/Sentinel_6_issue97485/com/obsproc/v1.0
    #   pickup $DATE x gpsro y $CDUMP y y $idir $odir
    #   pickup $DATE nrx gpsro y $CDUMP y y $idir $odir
    #  fi
    # done
    #;;
    #------------------------------------------------------
    #subpfl)
    # pickup subpfl dump files from Shelley (x-sub)
    # switch to Steve pickup (20220125)
    # started 2022011218 gdas
    # added nsstbufr pickup 2022012512
    # for CDUMP in $CDUMPS; do
    #  if [ $CDUMP = gdas -o $CDUMP = gfs ]; then
    #   backchk="NO"
    #   idir=/lfs/h2/emc/ptmp/steve.stegall/CRON/NSST_subpfl_issue51959/com/obsproc/v1.0
    #   pickup $DATE x subpfl y $CDUMP y y $idir $odir
    #   pickup $DATE x nsstbufr n $CDUMP y y $idir $odir
    #  fi
    # done
    #;;
    #------------------------------------------------------
    #noaa21)
    # pickup NOAA-21 ATMS and CRIS from Sudhir (x-sub)
    # started 2023030900
    # for CDUMP in $CDUMPS; do
    #  if [ $CDUMP = gdas -o $CDUMP = gfs ]; then
    #   backchk="NO"
    #   idir=/lfs/h2/emc/obsproc/noscrub/sudhir.nadiga/DUMPDIR/JGLOBALDUMP/CRON/CONUS/com/obsproc/v1.0
    #   pickup $DATE x atms y $CDUMP y y $idir $odir
    #   pickup $DATE x crisf4 y $CDUMP y y $idir $odir
    #   pickup $GDATE x atms y $CDUMP y y $idir $odir
    #   pickup $GDATE x crisf4 y $CDUMP y y $idir $odir
    #  fi
    # done
    #;;
    #-----------------------------------------------------------
    imsasc)
    # pickup ASCII version of IMS snow file from dcom (prod dump)
    # started 20231012
    # also gfs in real-time as of 20250422
    # sample: /lfs/h1/ops/prod/dcom/20231011/wgrbbul/NIC.IMS_v3_202328500_4km.asc
     for CDUMP in $CDUMPS; do
      #if [ $CDUMP = gdas -a $cyc = "00" ]; then
      if [ $cyc = "00" ]; then
       backchk="NO"
       idir=/lfs/h1/ops/prod/dcom/${PDYm1}/wgrbbul
       ifile=NIC.IMS_v3_${YYYY}${JDAY}00_4km.asc
       for cc in 00 06 12 18; do
         ofile=${CDUMP}.t${cc}z.imssnow96.asc
         if [ ! -d ${odir}/${CDUMP}.${PDY}/${cc}/${COMPONENT} ]; then
           mkdir -p ${odir}/${CDUMP}.${PDY}/${cc}/${COMPONENT}
         fi
         $DMPCPCMD ${idir}/${ifile} ${odir}/${CDUMP}.${PDY}/${cc}/${COMPONENT}/${ofile}
       done
      fi
     done
    ;;
    #-----------------------------------------------------------
    cpcgauge)
    #/gpfs/dell2/emc/modeling/noscrub/emc.glopara/stat/cpcUniGauge/2018/PRCP_CU_GAUGE_V1.0GLB_0.125deg.lnx.20180101.RT
    #/gpfs/dell1/nco/ops/dcom/prod/20200115/wgrbbul/cpc_rcdas/PRCP_CU_GAUGE_V1.0GLB_0.125deg.lnx.20200115.RT
    #/gpfs/dell2/emc/modeling/noscrub/emc.glopara/stat/cpcUniGauge/${yyyy}
    #/lfs/h1/ops/prod/dcom/20220502/wgrbbul/cpc_rcdas/PRCP_CU_GAUGE_V1.0GLB_0.125deg.lnx.20220502.RT
    # backfilled to 20180101
    # realtime 20200124
     for CDUMP in $CDUMPS; do
      if [ $CDUMP = gdas -a $cyc -ge "12" ]; then
        #pickup CPC GAUGE from dcom - once daily during 12z gdas, 36hr backdate for 00z gdas, early copy
        if [ $cyc = "12" ]; then
         CPCDATE=`$NDATE -36 $DATE`
        #pickup CPC GAUGE from dcom - once daily during 18z gdas, 66hr backdate for 00z gdas, final copy
        elif [ $cyc = "18" ]; then
         CPCDATE=`$NDATE -66 $DATE`
        fi
        CPCSUF='_early'
        CPCPDY=`expr $CPCDATE | cut -c1-8`
        CPCcyc=`expr $CPCDATE | cut -c9-10`
        ifile=PRCP_CU_GAUGE_V1.0GLB_0.125deg.lnx.${CPCPDY}.RT
        efile=PRCP_CU_GAUGE_V1.0GLB_0.125deg.lnx.${CPCPDY}.RT${CPCSUF}
        idir=$DCOMROOT/${CPCPDY}/wgrbbul/cpc_rcdas
        #GDA copy
        if [[ ! -d "${odir}/${CDUMP}.${CPCPDY}/${CPCcyc}/${COMPONENT}" ]]; then
            mkdir -p "${odir}/${CDUMP}.${CPCPDY}/${CPCcyc}/${COMPONENT}"
        fi
        $DMPCPCMD $idir/$ifile $odir/${CDUMP}.${CPCPDY}/${CPCcyc}/${COMPONENT}/$ifile
        #GDAp copy
        #$DMPCPCMD $idir/$ifile $odir/${CDUMP}p.${CPCPDY}/${CPCcyc}/$ifile
        #$DMPCPCMD $idir/$ifile $USER@${omac}:$odir/${CDUMP}p.${CPCPDY}/${CPCcyc}/$ifile
        #Early copy at 12z
        if [ $cyc = "12" ]; then
          #GDA early copy
          if [[ ! -d $odir/${CDUMP}.${CPCPDY}/${CPCcyc}/${COMPONENT} ]]; then
            mkdir -p $odir/${CDUMP}.${CPCPDY}/${CPCcyc}/${COMPONENT}
          fi
          $DMPCPCMD $idir/$ifile $odir/${CDUMP}.${CPCPDY}/${CPCcyc}/${COMPONENT}/$efile
          #GDAp copy
          #$DMPCPCMD $idir/$ifile $odir/${CDUMP}p.${CPCPDY}/${CPCcyc}/$efile
          #$DMPCPCMD $idir/$ifile $USER@${omac}:$odir/${CDUMP}p.${CPCPDY}/${CPCcyc}/$efile
        fi
      fi
     done
    ;;
    #------------------------------------------------------
    rtofs)
    # pickup from /com and thin for archive
    # Wait till files available in /com (10z-16z)
      module load nco/$nco_ver
      COMIN=$(compath.py rtofs/${rtofs_ver})
      if [ ! -d $odir/rtofs.$PDY ]; then mkdir -p $odir/rtofs.$PDY ; fi
      cd $odir/rtofs.$PDY
      $DMPCPCMD $COMIN/rtofs.$PDY/rtofs_glo_2ds_f00{0..9}_prog.nc ./
      $DMPCPCMD $COMIN/rtofs.$PDY/rtofs_glo_2ds_f0{1..7}?_prog.nc ./
      $DMPCPCMD $COMIN/rtofs.$PDY/rtofs_glo_2ds_f0{75..99..3}_prog.nc ./
      $DMPCPCMD $COMIN/rtofs.$PDY/rtofs_glo_2ds_f{102..192..3}_prog.nc ./

      files=`ls rtofs_glo_2ds_f*_prog.nc`

      for file in $files
      do
        ncks -v u_velocity,v_velocity $file temp.nc
        mv -f temp.nc $file
      done

    ;;
    #------------------------------------------------------
   esac
  done # CASE loop 
 #------------------------------------------------------

 #-------------------------
 # Double check permissions
 #-------------------------

 sh $UTILDIR/permission.sh $DATE

 adate=`$NDATE +${NFREQ} $DATE`
 DATE=$adate
done # DATE to LDATE backfill

# -------------------------
# Rsync to other machines 
# -------------------------

if [ $DMPTRAN = "YES" ]; then
 if [ $SYNC_BACK -gt 0 ]; then
   RDATE=`$NDATE -${SYNC_BACK} $SDATE`
 else
   RDATE=$SDATE
 fi
 sh $UTILDIR/rsync.sh -s $RDATE -e $LDATE -m $machs -n 24
fi

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo "archive.sh complete"
echo "Done @ $(date -u)"
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
exit
