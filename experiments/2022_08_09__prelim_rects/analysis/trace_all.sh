#!/bin/bash

for SEED in {1..100}
do
  python3 animate.py ../shared_files/maps/rect_ ../data/${SEED}/final_dominant_org_fitness.csv ../plots/${SEED}
done
