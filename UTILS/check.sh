#!/bin/bash
##set -x

CDUMP=$1
CDATE=$2

GDADIR=/lfs/h2/emc/global/noscrub/emc.global/dump
OPSDIR=/lfs/h1/ops/prod/com/obsproc/v1.0
GFSDIR=/lfs/h1/ops/prod/com/gfs/v16.2

echo "Check $CDUMP $CDATE"

PDY=$(echo $CDATE | cut -c1-8)
cyc=$(echo $CDATE | cut -c9-10)

cpath=$CDUMP.$PDY/$cyc/atmos
cd $GDADIR/$cpath
for file in `ls `; do
    GDA=$GDADIR/$cpath/$file
    OPS=$OPSDIR/$cpath/$file
    if [ -e $file ]; then
	if [ -s $file ]; then
	    if [ -s $OPS ]; then
		count=$(cmp $GDA $OPS | wc -l)
		if [ $count -gt 0 ]; then
		    echo "DIFF $file"
		else
		    echo "same $file"
		fi	       
	    else
		OPS=$GFSDIR/$cpath/$file
		if [ -s $OPS ]; then
		    count=$(cmp $GDA $OPS | wc -l)
		    if [ $count -gt 0 ]; then
			echo "DIFF $file"
		    else
			echo "same $file in $GFSDIR"
		    fi
		else
		    echo "$file NOT FOUND in $OPS"
		fi
	    fi
	else
	    if [ -e $OPS ]; then
		echo " "
		echo "$file is size 0"
		ls -l $GDADIR/$cpath/$file
		ls -l $OPSDIR/$cpath/$file
		echo " "
	    else
		OPS=$GFSDIR/$cpath/$file
		if [ -e $OPS ]; then
                    echo " "
		    echo "$file is size 0"
		    ls -l $GDADIR/$cpath/$file
		    ls -l $GFSDIR/$cpath/$file
		    echo " "
		fi
	    fi
	fi
    fi
done
