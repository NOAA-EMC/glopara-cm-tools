#!/bin/bash

CDUMP=rtofs
CDATE=$1

GDADIR=/lfs/h2/emc/global/noscrub/emc.global/dump
OPSDIR=/lfs/h1/ops/prod/com/rtofs/v2.3

compare_ncfile=/u/russ.treadon/bin/compare_ncfile.py 

echo "Check $CDUMP $CDATE"

PDY=$(echo $CDATE | cut -c1-8)
cyc=$(echo $CDATE | cut -c9-10)

cpath=$CDUMP.$PDY
cd $GDADIR/$cpath

echo "Compare $GDADIR/$cpath and $OPSDIR/$cpath for $CDATE"

for file in `ls `; do
    GDA=$GDADIR/$cpath/$file
    OPS=$OPSDIR/$cpath/$file
    if [ -s $OPS ]; then
	count=$($compare_ncfile $GDA $OPS |grep -v "diff=0.0000000000" |wc -l)
	if [ $count -gt 0 ]; then
	    echo "DIFF $file"
	else
	    echo "same $file"
	fi	       
    else
	echo "$file NOT FOUND in $OPS"
    fi
done
