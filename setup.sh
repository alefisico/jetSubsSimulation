rm SUBALL.sh
while read line
do

NAME=$line

cp -r BACKGROUND_TEMPLATE ${NAME}
#ln -s /cms/gomez/Substructure/Generation/MadGraph5_v1_5_11/stop_UDD312_ISR_upto2j/Events/${NAME}/unweighted_${NAME}_fixed.lhe ${NAME}/lhe/${NAME}.lhe
ln -s /cms/gomez/Stops/st_jj/lhe/unweighted_${NAME}_fixed.lhe ${NAME}/lhe/${NAME}.lhe

bash make_ntuples.sh ${NAME} 1 1

echo condor_submit scripts/condor_${NAME}.jdl >> SUBALL.sh

cp templates/Hadronizer_testjob.py .

done < stufftoprocess.txt
