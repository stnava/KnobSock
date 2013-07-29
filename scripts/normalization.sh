BIN=/home/hwang3/SATA2013/MICCAI-2013-SATA-Challenge-Registration/canine-legs
ROOT=/home/hwang3/SATA2013/MICCAI-2013-SATA-Challenge-Data/canine-legs
TRAIN=`cat $ROOT/training-images/canine-legs_Train`
TEST=`cat $ROOT/testing-images/canine-legs_Test`

echo $IDs

    for id in $TRAIN; do
	check=`ls $BIN/Normalized/${id}_T2FS.nii.gz`
        if [[ $check != '' ]]; then
            echo $check 'has been processed!';
##            continue;
        fi
        id=`qsub -p 0 -o $BIN/running -e $BIN/running -cwd -N "ncanine_${id}" -pe serial 1 -l h_stack=64M -V $BIN/normalization2_qsub.sh $id| awk '{print $3}'`
        sleep 0.01
        jobIDs="$jobIDs $id"
    done

