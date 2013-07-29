BIN=/home/hwang3/SATA2013/MICCAI-2013-SATA-Challenge-Registration/canine-legs
ROOT=/home/hwang3/SATA2013/MICCAI-2013-SATA-Challenge-Data/canine-legs
TRAIN=`cat $ROOT/training-images/canine-legs_Train`
TEST=`cat $ROOT/testing-images/canine-legs_Test`

echo $IDs

for ref_id in $TEST; do
##for ref_id in DD_092; do
##    for mov_id in $TRAIN; do
##    for mov_id in DD_092; do
##	if [[ $ref_id == $mov_id ]]; then
##            continue;
##        fi
	check=`ls $BIN/${ref_id}/alignMod_${ref_id}_T2FS.nii.gz`
        if [[ $check != '' ]]; then
            echo $check 'has been processed!';
            continue;
        fi
echo $ref_id
echo $BIN/alignMod.sh $BIN $ref_id
##exit
        qsub -p -10 -o $BIN/running -e $BIN/running -cwd -N "a_${ref_id}" -pe serial 3 -l h_stack=128M $BIN/alignMod.sh $BIN $ref_id
        sleep 0.01
        jobIDs="$jobIDs $id"
##    done
done

