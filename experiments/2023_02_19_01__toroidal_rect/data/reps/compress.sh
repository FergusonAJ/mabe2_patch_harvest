#!/bin/bash


MIN=1
MAX=200
REPS=$( seq --separator=" " ${MIN} ${MAX} )

tar -czf reps_${MIN}_${MAX}.tar.gz ${REPS}
