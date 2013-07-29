BIN=/home/hwang3/SATA2013/MICCAI-2013-SATA-Challenge-Registration/canine-legs
ROOT=/home/hwang3/SATA2013/MICCAI-2013-SATA-Challenge-Data/canine-legs
TRAIN=`cat $ROOT/training-images/canine-legs_Train`
TEST=`cat $ROOT/testing-images/canine-legs_Test`

echo $IDs

for ref_id in $TEST; do
##for ref_id in DD_092; do
    for mov_id in $TRAIN; do
##    for mov_id in DD_092; do
	if [[ $ref_id == $mov_id ]]; then
            continue;
        fi
	check=`ls $BIN/newReg/${mov_id}_To_${ref_id}/registered*T2FS*`
        if [[ $check != '' ]]; then
##            echo $check 'has been processed!';
            continue;
        fi
        id=`qsub -p -10 -o $BIN/running -e $BIN/running -cwd -N "d_${mov_id}_To_${ref_id}" -pe serial 3 -l h_stack=128M -V $BIN/registerPairsMod.sh $BIN/newReg $ref_id $mov_id| awk '{print $3}'`
        sleep 0.01
        jobIDs="$jobIDs $id"
    done
done

