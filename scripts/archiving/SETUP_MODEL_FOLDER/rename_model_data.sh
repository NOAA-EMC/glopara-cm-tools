#!/bin/bash

#set -x

ICSDIR="/lfs/h2/emc/global/noscrub/emc.global/data/ICSDIR"

while IFS= read -r line; do
  if [[ -d ${ICSDIR}/${line::-10} ]] ; then
    cd ${ICSDIR}/${line::-10}
    pwd
    mv model_data model
    ln -s model model_data
    ls
  fi
done < "ICSDIR_model_data.out"

memmax=80
memstart=1
mem=$memstart

while [ $mem -le $memmax ]
do
  memn=$(printf %03d "${mem}")
  cd ${ICSDIR}/C48C48mx500/enkfgdas.20210323/06/mem${memn}
  unlink model_data
  ln -s ../../../gdas.20210323/06/model model
  ln -s model model_data
  mem=`expr $mem + 1`
done
