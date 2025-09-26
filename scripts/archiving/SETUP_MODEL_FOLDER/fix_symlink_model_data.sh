#!/bin/bash

#set -x

ICSDIR="/scratch1/NCEPDEV/global/glopara/data/ICSDIR"

memmax=80
memstart=1
mem=$memstart

#/scratch1/NCEPDEV/global/glopara/data/ICSDIR/C96C48/20240610/enkfgdas.20211220/12/mem001/model/atmos/input -> ../../../../../../enkfgdas.20211220/12/mem001/model_data/atmos/input

while [ $mem -le $memmax ]
do
  memn=$(printf %03d "${mem}")
  cd ${ICSDIR}/C96C48/20240610/enkfgdas.20211220/12/mem${memn}/model/atmos/
  unlink input 
  ln -s ../../../../../../enkfgdas.20211220/12/mem001/model/atmos/input input

  mem=`expr $mem + 1`
done
