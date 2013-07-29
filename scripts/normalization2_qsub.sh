#!/bin/bash
#$ -S /bin/bash
set -x -e

ID=$1
IROOT=/home/hwang3/SATA2013/MICCAI-2013-SATA-Challenge-Data/canine-legs
OROOT=/home/hwang3/SATA2013/MICCAI-2013-SATA-Challenge-Registration/canine-legs
input=$OROOT/$ID/alignMod_${ID}_T2FS.nii.gz
output=$OROOT/Normalized/${ID}_T2FS.nii.gz

ImageMath 3  $output TruncateImageIntensity $input 0.01 0.99 500
N4BiasFieldCorrection -d 3 -i $output -s 2 -c [50x40x30,1e-8] -b [200] -o $output
RescaleImageIntensity 3 $output $output 0 1

