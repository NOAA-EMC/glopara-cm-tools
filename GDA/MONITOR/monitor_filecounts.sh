#!/bin/bash -l
# Script to process the file counts of the past 7 days worth
# of data dump files in EMC GMB data dump archive 
#
# 2019-07-09 K. Friedman - Original version for Dells/Crays
# --------------------------------------------------------------

#set -x

# read in config file
# -------------------

CONFIG=/lfs/h2/emc/global/noscrub/emc.global/dump_archive/gda/config.dumparch
set -a;. $CONFIG;set +a

# Source versions file for runtime
source "$HOMEgfs/versions/run.ver"
source "$HOMEgfs/versions/wcoss2.ver"

NDATE=${NDATE:-"/apps/ops/prod/nco/core/prod_util.v${prod_util_ver}/exec/ndate"}

COMPONENT="atmos"

prodmac=`cat /lfs/h1/ops/prod/config/prodmachinefile | grep primary | cut -c9- | cut -c1`
devmac=`cat /lfs/h1/ops/prod/config/prodmachinefile | grep backup | cut -c 8- | cut -c1`
curmac=`hostname | cut -c1`

#OLD#DMPDIR="/lfs/h2/emc/global/noscrub/emc.global/dump"
DMPDIR="/lfs/h2/emc/dump/noscrub/dump"
#DMPDIR2="/lfs/h2/emc/global/noscrub/emc.global/dump2"
WDIR=/lfs/h2/emc/stmp/emc.global/RUNDIRS/gda/monitor
#WDIR=/lfs/h2/emc/global/save/emc.global/dump_archive/MONITOR

if [ ! -d $WDIR ]; then mkdir -p $WDIR; fi
cd $WDIR
if [ $? -ne 0 ]; then
  echo "Cannot CD to $DIR!"
  echo "exiting $0!"
  exit
fi

PDY=`date -u +"%Y%m%d%H"`

networks='gfs gdas'
cycles='ALL 00 06 12 18'

# Set text colors
# ---------------
color_late="#FF9900"
color_missing="#FF0000"
color_ok="#00FF00"

# Find quotas
# -----------
#quota=`/usrx/local/bin/fsquota | grep dell3-emc-global-dump | cut -c111-115`
#quota_use=`lfs quota -p 1220054 /lfs/h2/emc/global/noscrub/emc.global | tail -1 | awk '{print $1}'`
#quota_allow=`lfs quota -p 1220054 /lfs/h2/emc/global/noscrub/emc.global | tail -1 | awk '{print $2}'`
#quota_percent=$(( 100 * $quota_use / $quota_allow ))
quota_percent=`/usr/local/bin/lsquota | grep noscrub | awk '{print $2}' | head -1`
quota_dump=`/usr/local/bin/lsquota | grep dump | grep noscrub | awk '{print $2}'`

# Make stat page for machine
# --------------------------
STATDOC=$WDIR/stats.$mach.html
echo "<html>" > $STATDOC
echo "<head><meta http-equiv=\"refresh\" content=\"300\"></head>" >> $STATDOC
if [ $curmac = $prodmac ]; then
  echo "<body bgcolor="green">" >> $STATDOC
  echo "<font color="#00FF00">WCOSS2-PROD</font>" >> $STATDOC
else
  echo "<body bgcolor="#FFFDDo">" >> $STATDOC
  echo "WCOSS2-DEV" >> $STATDOC
fi
echo "<br>" >> $STATDOC
echo "Quota Global: ${quota_percent}%" >> $STATDOC
echo "<br>" >> $STATDOC
echo "Quota Dump: ${quota_dump}%" >> $STATDOC
echo "<br>" >> $STATDOC
echo "</body>" >> $STATDOC 
echo "</html>" >> $STATDOC

# Figure out which days constitute the past week (7 days total).
# --------------------------------------------------------------
current_day=$(date -u +"%Y%m%d")
current_cycle=$(date -u +"%Y%m%d%H")
current_hr=$(date -u +"%H")
current_time=$(date -u +"%H%M")
current_full=$(date -u +"%Y%m%d%H%M")
nrurcyc=`$NDATE -60 $current_cycle`
cpcdelay=`$NDATE -42 $current_cycle`
okdifgfs='0300'
okdifgdas='0600'

MAILDOC=$WDIR/filecountmail.out

i=0
m=14
while [ "$i" -le "$m" ]
do
  hrsbk=$(expr $i \* 24)
  days2chk=$(echo $days2chk $($NDATE -$hrsbk ${current_day}00 | cut -c 1-8))  
  i=$(expr $i + 1)
done

# For each cycle, network and machine:
# 1.) Get the file counts.
# 2.) Get the size of the files.
# -------------------------------------------------------------------------------------------------- 
for network in $networks
do
  HTMLDOC=$WDIR/filecounts.$network.$mach.html
  MISSDOC=$WDIR/filemiss.$network.$mach.html
  if [ -f $HTMLDOC ]; then rm -rf $HTMLDOC; fi
  if [ -f $MISSDOC ]; then rm -rf $MISSDOC; fi
  echo "Missing files for "$network"<br>" >> $MISSDOC
  echo "<br>" >> $MISSDOC

  echo "<html>" > $HTMLDOC
  echo "<html>" > $MISSDOC
  echo "<head><meta http-equiv=\"refresh\" content=\"300\"></head>" >> $HTMLDOC
  echo "<head><meta http-equiv=\"refresh\" content=\"300\"></head>" >> $MISSDOC
  if [ $curmac = $prodmac ]; then
    echo "<body bgcolor="green">" >> $HTMLDOC
    echo "<body bgcolor="green">" >> $MISSDOC
    echo $(date -u) "- <font color="#00FF00">WCOSS2 - PRODUCTION - ${HOSTM}</font>" >> $HTMLDOC
    echo "<div align=\"left\">" >> $HTMLDOC
  else
    echo "<body bgcolor="#FFFDDo">" >> $HTMLDOC
    echo "<body bgcolor="#FFFDDo">" >> $MISSDOC
    echo "<div align=\"left\">" >> $HTMLDOC
    echo $(date -u) "- WCOSS2 - DEVELOPMENT - ${HOSTM}" >> $HTMLDOC
  fi
  echo "</div>" >> $HTMLDOC

# Center table on page.
# ---------------------
  echo "<center>" >> $HTMLDOC 

# Write out the table header row.
# -------------------------------
  echo "<table border=\"1\">" >> $HTMLDOC

# each cycle gets its own separate row.
# -------------------------------------
  for cycle in $cycles
  do

# Calculate data lateness, if needed
# ----------------------------------

   if [ $cycle = "ALL" ]; then
    echo "<tr>" >> $HTMLDOC
    echo "<td><font face=\"verdana\" size=\"1\"> </font></td>" >> $HTMLDOC

    for day in $days2chk
    do
      echo "<td><font face=\"verdana\" size=\"1\">$day</font></td>" >> $HTMLDOC
    done # for day in $days2chk
    echo "</tr>" >> $HTMLDOC
   fi

   j=0

   echo "<tr>" >> $HTMLDOC

   if [ $cycle = "ALL" ]; then
    echo "<td bgcolor=\"gray\" align=\"left\"><font face=\"verdana\" size=\"1\"><center>${cycle}</center></font></td>" >> $HTMLDOC
   else
    echo "<td bgcolor=\"gray\" align=\"left\"><font face=\"verdana\" size=\"1\"><center>${cycle}Z</center></font></td>" >> $HTMLDOC
   fi
   for day in $days2chk
   do
      j=$(expr $j + 1)
      echo "<td bgcolor=\"gray\" align=\"left\"><font face=\"verdana\" size=\"1\">" >> $HTMLDOC
 
      if [ $cycle = "ALL" ]; then
        hrdif=$((${current_full} - ${day}${current_hr}00))
        nets="rtofs"
      else
        hrdif=$((${current_full} - ${day}${cycle}00))
        #p-dump stopped 2019110706#nets='$network ${network}nr ${network}ur ${network}x ${network}p ${network}y'
        #p-dump started 2020102912#nets="$network ${network}nr ${network}ur ${network}x ${network}y"
        #no-y-dump#nets="$network ${network}nr ${network}ur ${network}x ${network}p"
        #p-dump stopped 2021032212#nets="$network ${network}nr ${network}ur ${network}x ${network}y ${network}p"
        #added nrx 2022042518#nets="$network ${network}nr ${network}ur ${network}x ${network}y"
        #turn off nrx and y#nets="$network ${network}ur ${network}nr ${network}nrx ${network}x ${network}y"
        #turn off ur#nets="$network ${network}ur ${network}nr ${network}x"
        nets="$network ${network}nr ${network}x"
      fi
      for n in $nets 
      do

# Assign count variable for dump
# ------------------------------

	case $n in
	  gdas)
            if [ ${day}${cycle} -ge 2025032600 ]; then
	      wcn=74 # Add AFWA global snow.usaf.grib2 
            elif [ ${day}${cycle} -ge 2024052500 ]; then
	      wcn=73 # Add uprair 
            elif [ ${day}${cycle} -ge 2024052212 ]; then
	      wcn=72 # Retire saphir and sevcsr with obsproc/v1.2
            elif [ ${day}${cycle} -ge 20231008 ]; then
	      wcn=74 # Add ASCII IMS (gdas only)
            elif [ ${day}${cycle} -ge 2023072518 ]; then
	      wcn=73 # GFSv16.3 (gmi1cr, saldrn, subpfl) + snocvr + AMSR-2
	    elif [ ${day}${cycle} -ge 2022120112 ]; then
	      wcn=72 # GFSv16.3 (gmi1cr, saldrn, subpfl) + snocvr
            elif [ ${day}${cycle} -ge 2022062812 ]; then
              wcn=68 # Add sevasr
            elif [ ${day}${cycle} -ge 2021081806 ]; then
              wcn=67 # TAC2BUFR upgrade: add tideg 
            elif [ ${day}${cycle} -ge 2021032212 ]; then
              wcn=66 # GFSv16 implementation: add ahicsr, gsrasr, gsrcsr, hdob, ompslp, sstvcw, sstvpw
            elif [ ${day}${cycle} -ge 2020102206 ]; then
              wcn=60 # Retirement of goesfv, dbuoyb, mbuoyb
            elif [ ${day}${cycle} -ge 2020042206 ]; then
              wcn=63 # Retirement of cris (also escrsf)
            fi
            if [ $cycle = "00" -a ${day}${cycle} -lt $cpcdelay ]; then wcn=$(($wcn + 2)); fi
            files="$DFILES $DFILES_GFS"
            np=$n
	  ;;
	  gdasp)
	    wcn=0
            if [ ${day}${cycle} -ge 2020102912 -a ${day}${cycle} -le 2021032212 ]; then
              wcn=66
              if [ $cycle = "00" -a ${day}${cycle} -lt $cpcdelay ]; then wcn=$(($wcn + 2)); fi
            fi
            files=$DFILES_P
            np="p"
	  ;;
	  gdasnr)
	    wcn=6
            if [ ${day}${cycle} -ge 2024052212 ]; then
	      wcn=6 # Retire saphir and sevcsr with obsproc/v1.2
            elif [ ${day}${cycle} -ge 2021041412 ]; then
	      wcn=7
            fi
            files=$DFILES_NR
            np="nr"
	  ;;
	  gdasnrx)
	    wcn=0
            if [ ${day}${cycle} -ge 2022120100 ]; then
	      wcn=0
            elif [ ${day}${cycle} -ge 2022042518 ]; then
	      wcn=1
            fi
            files=$DFILES_NRX
            np="nrx"
	  ;;
	  gdasur)
	    wcn=0
            if [ ${day}${cycle} -gt $nrurcyc ]; then wcn=0; fi
            if [ ${day}${cycle} -le 2023052300 ]; then wcn=3; fi # Discontinued 20230525 - last cycle 2023052300 
            if [ ${day}${cycle} -lt 2022062612 ]; then wcn=8; fi # WCOSS1
            if [ ${day}${cycle} -ge 2021031718 -a ${day}${cycle} -lt 2021040100 ]; then wcn=0; fi #BROKE with v16 implementation
            if [ ${day}${cycle} -ge 2021040106 -a ${day}${cycle} -lt 2021042812 ]; then wcn=7; fi #Add gpsro
            files=$DFILES_UR
            np="ur"
	  ;;
	  gdasx)
            if [ ${day}${cycle} -ge 2024010206 ]; then
              wcn=0 # NOAA-21 ATMS & CRIS in production
            elif [ ${day}${cycle} -ge 2023030900 ]; then
              wcn=2 # add NOAA-21 ATMS & CRIS
            elif [ ${day}${cycle} -ge 2022120100 ]; then
              wcn=0 # discontinue GFSv16.3 experimental
            elif [ ${day}${cycle} -ge 2022041200 ]; then
              wcn=5 # discontinue vadwnd/prepbufr
            elif [ ${day}${cycle} -ge 2022031012 ]; then
              wcn=7 # add vadwnd/prepbufr
            elif [ ${day}${cycle} -ge 2022012506 ]; then
              wcn=5 # mtiasi discontinued
            elif [ ${day}${cycle} -ge 2022012200 ]; then
              wcn=6 # saldrn/subpfl nsstbufr added
            elif [ ${day}${cycle} -ge 2022011218 ]; then
              wcn=5 # subpfl added
            elif [ ${day}${cycle} -ge 2021102000 ]; then
              wcn=4 # Sentinel-6 gpsro 
            elif [ ${day}${cycle} -ge 2021072006 -a ${day}${cycle} -le 2021072206 ]; then
              wcn=2 # Missing saldrn WCOSS outage 
            elif [ ${day}${cycle} -ge 2021062206 -a ${day}${cycle} -le 2021062500 ]; then
              wcn=2 # Missing saldrn WCOSS outage 
            elif [ ${day}${cycle} -eq 2021062518 ]; then
              wcn=2 # Missing saldrn WCOSS outage 
            elif [ ${day}${cycle} -ge 2021010418 ]; then
              wcn=3 # Addition of mtiasi 
            elif [ ${day}${cycle} -ge 2020110218 ]; then
              wcn=2 # GDAp - ahicsr, gsr, sst viirs, hdob, ompslp
            elif [ ${day}${cycle} -ge 2020092206 ]; then
              wcn=9 # Implementation of omi in ops
            elif [ ${day}${cycle} -ge 2020090906 ]; then
              wcn=10 # Implementation of ompsn8 Aug 10th
            elif [ ${day}${cycle} -ge 2020082412 ]; then
              wcn=11 # Addition of hdob
            elif [ ${day}${cycle} -ge 2020073012 ]; then
              wcn=10 # Discontinuation of Jeff's sfcshp
            elif [ ${day}${cycle} -ge 2020070211 ]; then
              wcn=11 # Discontinuation of dbuoyb w/ saildrone 
            elif [ ${day}${cycle} -ge 2020063018 ]; then
              wcn=12 # Addition of saildrone
            elif [ ${day}${cycle} -ge 2020061000 ]; then
              wcn=11 # Addition of ompsn8
            elif [ ${day}${cycle} -ge 2020053100 ]; then
              wcn=10 # Addition of buoy sfcshp
            elif [ ${day}${cycle} -ge 2020052500 ]; then
              wcn=9 # Implementation of mtiasi MetOp-C in ops
            elif [ ${day}${cycle} -ge 2020042212 ]; then
              wcn=10 # Implementation of crisfsr
            elif [ ${day}${cycle} -ge 2020040812 ]; then
              wcn=11 # Addition of crisfsr
            elif [ ${day}${cycle} -ge 2020040718 ]; then
              wcn=10 # Addition of dbuoyb
            fi
            files=$DFILES_X
            np="x"
	  ;;
	  gdasy)
	    wcn=0
            if [ ${day}${cycle} -ge 2021052800 -a ${day}${cycle} -le 2021081806 ]; then
              wcn=4 # Add tac2bufr adpsfc/sfcshp/tideg and prepbufr 
            elif [ ${day}${cycle} -ge 2021031712 -a ${day}${cycle} -le 2021041412 ]; then
              wcn=1 # Add gpsro-y round 2
            elif [ ${day}${cycle} -ge 2021030818 -a ${day}${cycle} -le 2021031018 ]; then
              wcn=1 # Add gpsro-y round 2
            elif [ ${day}${cycle} -ge 2021010600 -a ${day}${cycle} -le 2021011518 ]; then
              wcn=1 # Add gpsro-y
            elif [ ${day}${cycle} -ge 2020110218 -a ${day}${cycle} -le 2021010518 ]; then
              wcn=0 # GDAp - satwnd_leogeo 
            elif [ ${day}${cycle} -ge 2020102212 -a ${day}${cycle} -le 2020110212 ]; then
              wcn=1 # tac2bufr adpsfc/sfcshp discontinued
            elif [ ${day}${cycle} -ge 2020070706 -a ${day}${cycle} -le 2020102206 ]; then
              wcn=3 # tac2bufr adpsfc/sfcshp
            fi
            if [ ${day}${cycle} -le 2020052612 ]; then wcn=2 ; fi # Stopped gsrcsr-y
            files=$DFILES_Y
            np="y"
	  ;;
	  gfs)
            if [ ${day}${cycle} -ge 2025042200 ]; then
	      wcn=74 # Add IMS to gfs as well
            elif [ ${day}${cycle} -ge 2025032600 ]; then
	      wcn=73 # Add AFWA global snow.usaf.grib2 
            elif [ ${day}${cycle} -ge 2024052500 ]; then
	      wcn=72 # Add uprair 
            elif [ ${day}${cycle} -ge 2024052212 ]; then
	      wcn=71 # Retire saphir and sevcsr with obsproc/v1.2
            elif [ ${day}${cycle} -ge 2023072518 ]; then
              wcn=73 # GFSv16.3 (gmi1cr, saldrn, subpfl) + snocvr + AMSR-2
            elif [ ${day}${cycle} -ge 2022120112 ]; then
	      wcn=72 # GFSv16.3 (gmi1cr, saldrn, subpfl) + snocvr
            elif [ ${day}${cycle} -eq 2022080500 ]; then
              wcn=67 # Missing engicegrb file from Cactus outage 
            elif [ ${day}${cycle} -ge 2022062812 ]; then
              wcn=68 # Add sevasr
            elif [ ${day}${cycle} -ge 2021081812 ]; then
              wcn=67 # TAC2BUFR upgrade: add tideg 
            elif [ ${day}${cycle} -ge 2021032212 ]; then
              wcn=66 # GFSv16 implementation: add ahicsr, gsrasr, gsrcsr, hdob, ompslp, sstvcw, sstvpw
            elif [ ${day}${cycle} -ge 2020102212 ]; then # GFSv15
              wcn=59 # Retirement of goesfv, dbuoyb, mbuoyb
            elif [ ${day}${cycle} -ge 2020042212 ]; then
              wcn=62 # Retirement of cris (also escrsf)
            fi
            files="$DFILES $DFILES_GFS"
            np=$n
	  ;;
	  gfsp)
	    wcn=0
            if [ ${day}${cycle} -ge 2020102912 -a ${day}${cycle} -le 2021032212 ]; then wcn=66 ; fi
            files=$DFILES_P
            np="p"
	  ;;
	  gfsnr)
	    wcn=6
            if [ ${day}${cycle} -ge 2024052212 ]; then
	      wcn=6 # Retire saphir and sevcsr with obsproc/v1.2
            elif [ ${day}${cycle} -ge 2021041412 ]; then
              wcn=7
            fi
            files=$DFILES_NR
            np="nr"
	  ;;
	  gfsnrx)
	    wcn=0
            if [ ${day}${cycle} -ge 2022120100 ]; then
	      wcn=0
            elif [ ${day}${cycle} -ge 2022042518 ]; then
	      wcn=1
            fi
            files=$DFILES_NRX
            np="nrx"
	  ;;
	  gfsur)
	    wcn=0
            if [ ${day}${cycle} -gt $nrurcyc ]; then wcn=0; fi
            if [ ${day}${cycle} -le 2023052300 ]; then wcn=3; fi # Discontinued 20230525 - last cycle 2023052300 
            if [ ${day}${cycle} -lt 2022062612 ]; then wcn=8; fi # WCOSS1
            if [ ${day}${cycle} -ge 2021031718 -a ${day}${cycle} -lt 2021040100 ]; then wcn=0; fi #BROKE with v16 implementation
            if [ ${day}${cycle} -ge 2021040106 -a ${day}${cycle} -lt 2021042812 ]; then wcn=7; fi #Add gpsro
            files=$DFILES_UR
            np="ur"
	  ;;
	  gfsx)
            if [ ${day}${cycle} -ge 2024010212 ]; then
              wcn=0 # NOAA-21 ATMS & CRIS in production
            elif [ ${day}${cycle} -ge 2023030900 ]; then
              wcn=2 # add NOAA-21 ATMS & CRIS
            elif [ ${day}${cycle} -ge 2022120100 ]; then
              wcn=0 # discontinue GFSv16.3 experimental
            elif [ ${day}${cycle} -ge 2022041206 ]; then
              wcn=5 # discontinue vadwnd/prepbufr
            elif [ ${day}${cycle} -ge 2022031018 ]; then
              wcn=7 # add vadwnd/prepbufr
            elif [ ${day}${cycle} -ge 2022012512 ]; then
              wcn=5 # mtiasi discontinued
            elif [ ${day}${cycle} -ge 2022012200 ]; then
              wcn=6 # saldrn/subpfl nsstbufr added
            elif [ ${day}${cycle} -ge 2022011300 ]; then
              wcn=5 # subpfl added
            elif [ ${day}${cycle} -ge 2021102000 ]; then
              wcn=4 # Sentinel-6 gpsro 
            elif [ ${day}${cycle} -ge 2021072012 -a ${day}${cycle} -le 2021072212 ]; then
              wcn=2 # Missing saldrn WCOSS outage 
            elif [ ${day}${cycle} -ge 2021062212 -a ${day}${cycle} -le 2021062506 ]; then
              wcn=2 # Missing saldrn WCOSS outage 
            elif [ ${day}${cycle} -eq 2021062518 ]; then
              wcn=2 # Missing saldrn WCOSS outage 
            elif [ ${day}${cycle} -ge 2021010418 ]; then
              wcn=3 # Addition of mtiasi 
            elif [ ${day}${cycle} -ge 2020110218 ]; then
              wcn=2 # GDAp - ahicsr, gsr, sst viirs, hdob, ompslp
            elif [ ${day}${cycle} -ge 2020092212 ]; then
              wcn=9 # Implementation of omi in ops
            elif [ ${day}${cycle} -ge 2020090906 ]; then
              wcn=10 # Implementation of ompsn8 Aug 10th
            elif [ ${day}${cycle} -ge 2020082412 ]; then
              wcn=11 # Addition of hdob
            elif [ ${day}${cycle} -ge 2020073012 ]; then
              wcn=10 # Discontinuation of Jeff's sfcshp
            elif [ ${day}${cycle} -ge 2020070211 ]; then
              wcn=11 # Discontinuation of dbuoyb w/ saildrone 
            elif [ ${day}${cycle} -ge 2020063018 ]; then
              wcn=12 # Addition of saildrone
            elif [ ${day}${cycle} -ge 2020061000 ]; then
              wcn=11 # Addition of ompsn8
            elif [ ${day}${cycle} -ge 2020053100 ]; then
              wcn=10 # Addition of buoy sfcshp
            elif [ ${day}${cycle} -ge 2020052500 ]; then
              wcn=9 # Implementation of mtiasi MetOp-C in ops
            elif [ ${day}${cycle} -ge 2020042212 ]; then
              wcn=10 # Implementation of crisfsr
            elif [ ${day}${cycle} -ge 2020040812 ]; then
              wcn=11 # Addition of crisfsr
            elif [ ${day}${cycle} -ge 2020040718 ]; then
              wcn=10 # Addition of dbuoyb
            fi
            files=$DFILES_X
            np="x"
	  ;;
	  gfsy)
	    wcn=0
            if [ ${day}${cycle} -ge 2021061218 -a ${day}${cycle} -le 2021081806 ]; then
              wcn=4 # Add tac2bufr adpsfc/sfcshp/tideg and prepbufr 
            elif [ ${day}${cycle} -ge 2021031712 -a ${day}${cycle} -le 2021041412 ]; then
              wcn=1 # Add gpsro-y round 2
            elif [ ${day}${cycle} -ge 2021030818 -a ${day}${cycle} -le 2021031018 ]; then
              wcn=1 # Add gpsro-y round 2 test
            elif [ ${day}${cycle} -ge 2021010600 -a ${day}${cycle} -le 2021011518 ]; then
              wcn=1 # Add gpsro-y
            elif [ ${day}${cycle} -ge 2020110218 -a ${day}${cycle} -le 2021010518 ]; then
              wcn=0 # GDAp - satwnd_leogeo 
            elif [ ${day}${cycle} -ge 2020102212 -a ${day}${cycle} -le 2020110212 ]; then
              wcn=1 # tac2bufr adpsfc/sfcshp discontinued
            elif [ ${day}${cycle} -ge 2020070706 -a ${day}${cycle} -le 2020102206 ]; then
              wcn=3 # tac2bufr adpsfc/sfcshp
            fi
            if [ ${day}${cycle} -le 2020052612 ]; then wcn=2 ; fi # Stopped gsrcsr-y
            files=$DFILES_Y
            np="y"
	  ;;
	  rtofs)
	    wcn=113
	    if [ ${day} -lt 20201209 ]; then wcn=226 ; fi # Stopped symlinks, v2 in ops with new filenames
            if [ ${day}${current_hr} -gt ${current_day}00 -a ${day}${current_hr} -lt ${current_day}12 ]; then wcn=0; fi
            np=$n
	  ;;
	esac

# Data file count
# ---------------

        if [ $n = "rtofs" ]; then
         WCDIR=$DMPDIR/${n}.${day}
        else
         WCDIR=$DMPDIR/${n}.${day}/${cycle}/${COMPONENT}
        fi
        if [ -d $WCDIR ]; then
          #wc=`ls $WCDIR | wc -l`
          wc=`ls $WCDIR | grep -v atmos | wc -l`
        else
          wc=0
        fi

	# Insert start of line code
	echo $np >> $HTMLDOC

        if [ $wc -lt $wcn ]; then
          # Today
          if [ $j -eq 1 ]; then
             if [ $hrdif -gt $okdifgdas ]; then 
               echo "<font color="$color_late">" $wc" </font>" >> $HTMLDOC
               echo "<font color="$color_late">" >> $MISSDOC
               # ----------------------------------
               # Check missing and print to MISSDOC
               if [ $n != "rtofs" -a $cycle != "ALL" ]; then
                 echo $n"<br>" >> $MISSDOC
                 echo "<br>" >> $MISSDOC
                 echo ${day}${cycle}"<br>" >> $MISSDOC
                 for file in $files
                 do
                   if [ ! -f ${WCDIR}/${network}.t${cycle}z.${file} ]; then
                     echo ${file} "<br>">> $MISSDOC
                   fi
                 done
                 echo "<br>" >> $MISSDOC
                 echo "</font>" >> $MISSDOC
               fi # MISSDOC
               # ----------------------------------
             else
               echo "<font color="$color_ok">" $wc" </font>" >> $HTMLDOC
             fi
          # Before today
          else
             echo "<font color="$color_missing">" $wc" </font>" >> $HTMLDOC
             echo "<font color="black">" >> $MISSDOC
               # ----------------------------------
               # Check missing and print to MISSDOC
               if [ $n != "rtofs" -a $cycle != "ALL" ]; then
                 echo $n"<br>" >> $MISSDOC
                 echo "<br>" >> $MISSDOC
                 echo ${day}${cycle}"<br>" >> $MISSDOC
                 for file in $files
                 do
                   if [ ! -f ${WCDIR}/${network}.t${cycle}z.${file} ]; then
                     echo ${file} "<br>">> $MISSDOC
                   fi
                 done
                 echo "<br>" >> $MISSDOC
                 echo "</font>" >> $MISSDOC
               fi # MISSDOC
               # ----------------------------------
          fi
        elif [ $wc -gt $wcn ]; then
          echo "<font color="$color_ok">" $wc" </font>" >> $HTMLDOC
        else
          echo  $wc" " >> $HTMLDOC
        fi
	if [ $n = "gdas" -o $n = "gfs" -o $n = "gdasnrx" -o $n = "gfsnrx" ]; then
          echo "<br>" >> $HTMLDOC
        fi
      done # for n in networks

      echo "</font></td>" >> $HTMLDOC
   done # for day in $days2chk
   echo "</font></tr>" >> $HTMLDOC

  done # for cycle in $cycles

# Close out html file.
# --------------------
  echo "</table>" >> $HTMLDOC 
  echo "</body>" >> $HTMLDOC 
  echo "</body>" >> $MISSDOC 
  echo "</html>" >> $HTMLDOC
  echo "</html>" >> $MISSDOC

# Copy html file to rzdm.
# ----------------------------------
  ssh -l emc.glopara emcrzdm.ncep.noaa.gov "mkdir -p $WEBDIR/filecounts"
  ssh -l emc.glopara emcrzdm.ncep.noaa.gov "mkdir -p $WEBDIR/filecounts/$network"
  rsync -azv $HTMLDOC emc.glopara@emcrzdm.ncep.noaa.gov:$WEBDIR/filecounts/$network
  rsync -azv $MISSDOC emc.glopara@emcrzdm.ncep.noaa.gov:$WEBDIR/filecounts/$network
  rsync -azv $STATDOC emc.glopara@emcrzdm.ncep.noaa.gov:$WEBDIR
  if [ $curmac = $prodmac ]; then
    ursafile=$MONDIR/filecounts.${network}.ursa.html
    rsync -azv $ursafile emc.glopara@emcrzdm.ncep.noaa.gov:$WEBDIR/filecounts/$network
  fi # if dev machine

done # for network in $networks

# Copy notes file to rzdm
# -----------------------
rsync -azv $MONDIR/notes.html emc.glopara@emcrzdm.ncep.noaa.gov:$WEBDIR/

echo "Done!"

exit 0
