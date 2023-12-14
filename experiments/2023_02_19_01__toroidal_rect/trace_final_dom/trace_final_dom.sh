#!/bin/bash

if [ ! $# -eq 1 ]
then
  echo "Error! Expected exactly one command line argument!"
  echo "  1. The seed to trace"
  exit 1
fi

# Configuration variables
REPO_ROOT_DIR=../../..
SCRIPT_DIR=${REPO_ROOT_DIR}/MABE2_extras/scripts/conversion/
MABE_DIR=${REPO_ROOT_DIR}/MABE2/build
SHARED_FILE_DIR=../shared_files


SEED=$1
echo "Seed: ${SEED}"
GENOME=$( Rscript extract_genome.R ${SEED} )
echo "Genome: ${GENOME}"
if [ ${GENOME} = "NA" ]
then
  echo "Error! Genome not found."
  exit 2
fi

# Pad seed with zeros for directory name
MAX_LENGTH=3 # We will zero pad numbers up to this many digits
SEED_PADDED=${SEED}
ZEROS_TO_ADD=$(( ${MAX_LENGTH} - ${#SEED} ))
if [ ${ZEROS_TO_ADD} -gt 0 ]
then
  for _ in $( seq 1 ${ZEROS_TO_ADD} )
  do
    SEED_PADDED="0${SEED_PADDED}"
  done
fi

# Create a directory to store our data
SEED_DIR="./seeds/${SEED_PADDED}"
echo "All traces will be saved in \"${SEED_DIR}\""
mkdir -p ${SEED_DIR}

# Convert the genome to the correct format
python3 ${SCRIPT_DIR}/genome_conversion.py \
  -c ${GENOME} ${SEED_DIR}/genome.org inst_set_output.txt > /dev/null

# We want to look over our four maps
MAP_IDX=0
for MAP_IDX in $(seq 0 3)
do
  # Actually do the analysis
  ${MABE_DIR}/MABE \
    -f ${SHARED_FILE_DIR}/shared_config.mabe ${SHARED_FILE_DIR}/analysis.mabe \
    -s random_seed=${SEED} \
    -s avida_org.initial_genome_filename=\"${SEED_DIR}/genome.org\" \
    -s avida_org.inst_set_input_filename=\"${SHARED_FILE_DIR}/inst_set_input.txt\" \
    -s patch_harvest.map_filenames=\"${SHARED_FILE_DIR}/maps/rect_${MAP_IDX}.txt\" \
    -s patch_harvest.verbose=1 \
    -s avida_org.verbose=1 \
    -s num_trials=1 \
    > final_org_eval.txt

  # Trim the file to just the organism trace
  START_OF_TRACE=$(grep -m 1 -n -e "IP:" final_org_eval.txt | grep -oP "^\d+")
  TOTAL_LINES=$(wc -l final_org_eval.txt | grep -oP "^\d+")
  tail -n $(( ${TOTAL_LINES} - ${START_OF_TRACE} + 1 )) final_org_eval.txt > ${SEED_DIR}/trace_map_${MAP_IDX}.txt
done

# Clean up after ourselves
rm final_org_eval.txt
rm ${SEED_DIR}/genome.org

