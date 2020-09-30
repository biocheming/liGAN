#!/bin/bash
<JOB_PARAMS>
source ~/.bashrc

WORK_DIR=$1
EXAMPLE_INDEX=$2
JOB_ID=$3

cd $WORK_DIR

SCR_DIR=$WORK_DIR/$JOB_ID
if [[ ! -e $SCR_DIR ]]; then
        mkdir -p $SCR_DIR
fi

echo ================================
echo Running on `whoami`@`hostname`
echo work_dir `pwd`
echo scr_dir $SCR_DIR
echo ld_library_path $LD_LIBRARY_PATH
echo ================================

TRAIN_JOB_NAME=<GEN_MODEL_NAME>_<DISC_MODEL_NAME>_<TRAIN_SEED>
GEN_WEIGHTS_NAME=$TRAIN_JOB_NAME.<TRAIN_DATA_NAME>.<TRAIN_SEED>.<TRAIN_FOLD>_gen_iter_<TRAIN_ITER>

DATA_FILE=<DATA_DIR>/<DATA_NAME>.types
if [${EXAMPLE_INDEX} -gt $(cat ${DATA_FILE} | wc -l) ];
then
	exit
fi
LINE=$(head ${DATA_FILE} -n${EXAMPLE_INDEX} | tail -n1)
REC=$(echo $LINE | cut -d' ' -f 3)
LIG=$(echo $LINE | cut -d' ' -f 4)

cp <LIGAN_DIR>/my_{rec,lig}_map $SCR_DIR

cd $SCR_DIR

trap "cp *.{types,model,caffemodel,dx,sdf,pymol,gen_metrics} ${WORK_DIR}" EXIT

python3 <LIGAN_DIR>/generate.py --data_model ../<MODEL_DIR>/<DATA_MODEL_NAME>.model --gen_model ../<MODEL_DIR>/<GEN_MODEL_NAME>.model --gen_weights ../<WEIGHTS_DIR>/${GEN_WEIGHTS_NAME}.caffemodel -r ${REC} -l ${LIG} --data_root <DATA_ROOT> -b lig -b lig_gen --fit_atoms --output_sdf --output_channels --verbose 3 --gpu --n_samples <N_SAMPLES> <GEN_OPTIONS> --threshold <THRESHOLD> --peak_value <PEAK_VALUE> --min_dist <MIN_DIST> --interm_gd_iters <INTERM_GD_ITERS> --final_gd_iters <FINAL_GD_ITERS> --learning_rate <LEARNING_RATE> --beta1 <BETA1> --beta2 <BETA2> --weight_decay <WEIGHT_DECAY> -o <JOB_NAME>_${SLURM_ARRAY_TASK_ID}
exit
