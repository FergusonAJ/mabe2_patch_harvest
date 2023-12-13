#!/bin/bash

THIS_DIR=`pwd`
DIR_LIST=` ls . | grep -P "2023_02_(19|20)"`
ANALYSIS_SOURCE="./2023_02_19_01__toroidal_rect/analysis/*"

for DIR in ${DIR_LIST}
do
  cp ${ANALYSIS_SOURCE} ${DIR}/analysis/
  cd ${DIR}/analysis 
  Rscript analyze_final_dominant_orgs.R
  cd ${THIS_DIR}
done
