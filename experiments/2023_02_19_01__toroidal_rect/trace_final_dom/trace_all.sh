#!/bin/bash

for SEED in $(seq 1 200)
do
  ./trace_final_dom.sh ${SEED}
done
