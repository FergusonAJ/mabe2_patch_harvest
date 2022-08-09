#!/bin/bash

# This file creates and fills the experiment's directory on scratch. 
# It then calls sbatch itself.
# This is done so the job name and output directory can use variables
# That part is adapted from here: https://stackoverflow.com/a/70740950

# Experiment variables
TIME_HOURS=23
TIME_MINUTES=59
NUM_REPLICATES=100
SEED_BASE=1000000000

#### Grab global variables, experiment name, etc.
# Do not touch this block unless you know what you're doing!
# Experiment name -> name of current directory
EXP_NAME=$(pwd | grep -oP "/\K[^/]+$")
# Experiment directory -> current directory
EXP_DIR=$(pwd)
# Root directory -> The root level of the repo, should be directory just above 'experiments'
REPO_ROOT_DIR=$(pwd | grep -oP ".+/(?=experiments/)")
source ${REPO_ROOT_DIR}/config_global.sh

echo "Launching jobs for experiment: ${EXP_NAME}"

#### Grab references to the various directories used in setup
LAUNCH_DIR=`pwd`
MABE_DIR=${REPO_ROOT_DIR}/MABE2
MABE_EXTRAS_DIR=${REPO_ROOT_DIR}/MABE2_extras
BASE_ROLL_Q_DIR=${REPO_ROOT_DIR}/roll_q
SCRATCH_ROLL_Q_DIR=${SCRATCH_ROOT_DIR}/roll_q
SCRATCH_EXP_DIR=${SCRATCH_ROOT_DIR}/${EXP_NAME}
SCRATCH_FILE_DIR=${SCRATCH_EXP_DIR}/shared_files
SCRATCH_SLURM_DIR=${SCRATCH_EXP_DIR}/slurm
SCRATCH_SLURM_JOB_DIR=${SCRATCH_SLURM_DIR}/jobs
SCRATCH_SLURM_OUT_DIR=${SCRATCH_SLURM_DIR}/out
TIMESTAMP=`date +%m_%d_%y__%H_%M_%S`
SLURM_FILENAME=${SCRATCH_SLURM_JOB_DIR}/slurm_job_${TIMESTAMP}.sb

# Setup the directory structure
if [ ! -d ${SCRATCH_ROLL_Q_DIR} ]
then
    echo "roll_q not found on scratch! Copying and initializing..."
    cp ${BASE_ROLL_Q_DIR} ${SCRATCH_ROLL_Q_DIR} -r
    echo "0" > ${SCRATCH_ROLL_Q_DIR}/roll_q_idx.txt
    rm ${SCRATCH_ROLL_Q_DIR}/roll_q_job_array.txt
    touch ${SCRATCH_ROLL_Q_DIR}/roll_q_job_array.txt
    echo "roll_q initialized!"
fi

echo "Creating directory structure in: ${SCRATCH_EXP_DIR}"
mkdir -p ${SCRATCH_FILE_DIR}
mkdir -p ${SCRATCH_SLURM_JOB_DIR}
mkdir -p ${SCRATCH_SLURM_OUT_DIR}
mkdir -p ${SCRATCH_EXP_DIR}/reps

# Copy all files that are shared across replicates
cp ${MABE_DIR}/build/MABE ${SCRATCH_FILE_DIR}
cp ${MABE_EXTRAS_DIR}/scripts/conversion/genome_conversion.py ${SCRATCH_FILE_DIR}
cp ${LAUNCH_DIR}/shared_files/* ${SCRATCH_FILE_DIR} -r

echo "Sending slurm job files to dir: ${SCRATCH_SLURM_JOB_DIR}"
echo "Sending slurm output files to dir: ${SCRATCH_SLURM_OUT_DIR}"
echo " "

# Pass the job script to sbatch, filling in some configuration variables
# Note: all variables in the job script will need the $ escaped!

cat <<EOF > ${SLURM_FILENAME} 
#!/bin/bash --login
#SBATCH --time=${TIME_HOURS}:${TIME_MINUTES}:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=1g
#SBATCH --job-name ${EXP_NAME}
#SBATCH --array=1-${NUM_REPLICATES}
#SBATCH --output=${SCRATCH_SLURM_OUT_DIR}/slurm-%A_%a.out

# Load the necessary modules
module purge
module load GCC/11.2.0
module load OpenMPI/4.1.1
module load R/4.1.2

#### Variables, defined by launch script 
# Experiment name
EXP_NAME=${EXP_NAME}
# Experiment directory
EXP_DIR=${EXP_DIR}
# Root directory of the repo
REPO_ROOT_DIR=${REPO_ROOT_DIR}
source \${REPO_ROOT_DIR}/config_global.sh
# The base seed (modified for individal replicates)
SEED_BASE=${SEED_BASE}

# Calculate the replicate's seed
SEED=\$((\${SEED_BASE} + \${SLURM_ARRAY_TASK_ID}))
echo "Random seed: \${SEED}: Replicate ID: \${SLURM_ARRAY_TASK_ID}"

# Grab all the needed directories
SCRATCH_EXP_DIR=\${SCRATCH_ROOT_DIR}/\${EXP_NAME}
SCRATCH_FILE_DIR=\${SCRATCH_EXP_DIR}/shared_files
SCRATCH_JOB_DIR=\${SCRATCH_EXP_DIR}/reps/\${SLURM_ARRAY_TASK_ID}

# Create replicate-specific directories
mkdir -p \${SCRATCH_JOB_DIR}
mkdir -p \${SCRATCH_JOB_DIR}/phylo
cd \${SCRATCH_JOB_DIR}

# Run!
time \${SCRATCH_FILE_DIR}/MABE -f \${SCRATCH_FILE_DIR}/evolution.mabe -s random_seed=\${SEED}

# Analyze final dominant org
Rscript \${SCRATCH_FILE_DIR}/phylo_analysis.R
DOMINANT_GENOME=\$(cat final_dominant_char.org)
python3 \${SCRATCH_FILE_DIR}/genome_conversion.py -c \${DOMINANT_GENOME} final_dominant.org inst_set_output.txt 
time \${SCRATCH_FILE_DIR}/MABE -f \${SCRATCH_FILE_DIR}/analysis.mabe -s random_seed=\${SEED}
mv single_org_fitness.csv final_dominant_org_fitness.csv

scontrol show job \$SLURM_JOB_ID
EOF

echo "${SLURM_FILENAME}" >> ${SCRATCH_ROLL_Q_DIR}/roll_q_job_array.txt
echo ""
echo "Finished creating jobs. Launching jobs now..."
echo ""
cd ${SCRATCH_ROLL_Q_DIR}
./roll_q.sh
cd ${LAUNCH_DIR}
