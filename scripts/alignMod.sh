#!/bin/bash 
#$ -S /bin/bash
set -x -e

workDir=$1
ref_id=$2
##mov_id=$3



##ref_id=$1
##mov_id=$2

##BIN_ANTS=/home/avants/bin/ants
BIN_ANTS=/home/hwang3/ahead_joint/turnkey/ext/Linux/bin/ants
BIN_ANTS=/home/hwang3/SATA2013/MICCAI-2013-SATA-Challenge-Registration
PROCESS_GR_LOCAL=${PROCESS_GROUNDTRUTH}
NO_QSUB=0

GENERATED=$workDir/${ref_id}
if [ ! -d $GENERATED ]; then
    mkdir $GENERATED
fi

ROUGH_MOV=${GENERATED}/RoughRegTraing${mov_id}
ROUGH_MOV_FILE=${ROUGH_MOV}.nii.gz
ROUGH_MOV_MASK=${ROUGH_MOV}mask_from_Template.nii.gz

##BRAINIMAGE_MOV=/home/hwang3/SATA2013/MICCAI-2013-SATA-Challenge-Registration/canine-legs/Normalized/${ref_id}_T2FS.nii.gz
BRAINIMAGE_MOV=/home/hwang3/SATA2013/MICCAI-2013-SATA-Challenge-Data/canine-legs/testing-images/${ref_id}_T2FS.nii.gz

##GROUNDTRUTH_MOV=/home/hwang3/SATA2013/MICCAI-2013-SATA-Challenge-Data/canine-legs/training-labels/${mov_id}_seg.nii.gz

##c3d $BRAINIMAGE_MOVO -orient RIA -o $BRAINIMAGE_MOV 
##c3d $GROUNDTRUTH_MOVO -orient RIA -o $GROUNDTRUTH_MOV

##BRAINIMAGE_FIX=/home/hwang3/SATA2013/MICCAI-2013-SATA-Challenge-Registration/canine-legs/Normalized/${ref_id}.nii.gz

BRAINIMAGE_FIX=/home/hwang3/SATA2013/MICCAI-2013-SATA-Challenge-Data/canine-legs/testing-images/${ref_id}_T2.nii.gz

OUTPUT=${GENERATED}/alignMod_${ref_id}
OUTPUT_FILE=${GENERATED}/alignMod_${ref_id}
REGISTERED_FINE_BRAIN=${OUTPUT}_T2FS.nii.gz

imgs=" $BRAINIMAGE_FIX,$BRAINIMAGE_MOV "

reg=$BIN_ANTS/antsRegistration

##${BIN_ANTS}/antsRegistration -d 3 -w [0.01,0.995] -o [$OUTPUT_FILE,$REGISTERED_FINE_BRAIN] \
##    -r [$imgs ,1] \
##    -t Rigid[0.1] -m Mattes[$imgs,1,32,Regular,0.25] -s 2x1x0 -f 4x2x1 -c [500x20x0,1e-8,15] \
##    -t Affine[0.1] -m Mattes[$imgs,1,32,Regular,0.25] -s 2x1x0 -f 4x2x1 -c [500x20x0,1e-8,15] \
##    -t BSplineSyN[0.1,10x10x11,0x0x0] -m CC[$imgs,1,4] -s 2x1x0 -f 4x2x1 -c [70x10x0,1e-8,15]

##RECONSTRUCTED_FINE_SEG=${OUTPUT}_reconstructed_seg.nii.gz
##$BIN_ANTS/antsApplyTransforms -d 3 -r $BRAINIMAGE_FIX -i $GROUNDTRUTH_MOV -o $RECONSTRUCTED_FINE_SEG -t ${OUTPUT_FILE}1Warp.nii.gz ${OUTPUT_FILE}0GenericAffine.mat -n NearestNeighbor


regparams="  -m Mattes[ $imgs ,1,32,Regular,0.05] -f 4x2x1 -s 2x1x0 -c [1000x1000x40,1e-08,10] "
##regparams="  -m MI[ $imgs ,1,32,Regular,0.05] -f 4x2x1 -s 2x1x0 -c [1000x1000x40,1e-08,10] "

##regparams="  -m CC[ $imgs ,1,2,Regular,0.25] -f 4x2x1 -s 2x1x0 -c [100x100x10,1e-08,10] "

$reg -d 3 -o [ $OUTPUT_FILE,$REGISTERED_FINE_BRAIN ] \
    -t Rigid[0.1] $regparams \
    -l 1 -u 1 -w [0.0,0.995] -b 0 -z 1

c3d $REGISTERED_FINE_BRAIN -orient LPI -o $REGISTERED_FINE_BRAIN
##    -t Similarity[0.1] $regparams \

##    -t Translation[0.1] $regparams \
##    -t Rigid[0.1] $regparams \
##    -t SyN[0.25,3,0] $regparams \


##RECONSTRUCTED_FINE_SEG=${OUTPUT}_reconstructed_seg.nii.gz

##$BIN_ANTS/antsApplyTransforms -d 3 -r $BRAINIMAGE_FIX -i $GROUNDTRUTH_MOV -o $RECONSTRUCTED_FINE_SEG -t ${OUTPUT_FILE}1Warp.nii.gz ${OUTPUT_FILE}0GenericAffine.mat -n NearestNeighbor

##$BIN_ANTS/antsApplyTransforms -d 3 -r $BRAINIMAGE_FIX -i $GROUNDTRUTH_MOV -o $RECONSTRUCTED_FINE_SEG -t ${OUTPUT_FILE}4Warp.nii.gz ${OUTPUT_FILE}3Similarity.mat ${OUTPUT_FILE}2Rigid.mat ${OUTPUT_FILE}1Translation.mat ${OUTPUT_FILE}0DerivedInitialMovingTranslation.mat -n NearestNeighbor



