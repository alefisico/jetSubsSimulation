#!/bin/sh

MAINDIR=`pwd`
TAG=$1
JOBS="100"
HADRONIZER="Hadronizer_TuneD6T_8TeV_madgraph_tauola_cff_py_GEN_SIM_DIGI_L1_DIGI2RAW_HLT_RAW2DIGI_L1Reco_RECO_PU.py"

cd ${MAINDIR}

# Creating condor configuraion file
cat templates/condor_template.jdl | sed "s/TAG/${TAG}/g" > scripts/condor_${TAG}.jdl
#echo "transfer_input_files = /cms/gomez/Substructure/Generation/Simulation/CMSSW_5_3_2_patch4/src/mySimulations/templates/Hadronizer_TuneD6T_8TeV_madgraph_tauola_cff_py_GEN_SIM_DIGI_L1_DIGI2RAW_HLT_RAW2DIGI_L1Reco_RECO_PU.py, /cms/gomez/Substructure/Generation/MadGraph5_v1_5_11/stop_UDD312_ISR_upto2j/Events/${TAG}/unweighted_${TAG}_fixed.lhe" >> scripts/condor_${TAG}.jdl
echo "" >> scripts/condor_${TAG}.jdl

echo -e "Outputdir = ${MAINDIR}/${TAG}/condorlogs\n" >> scripts/condor_${TAG}.jdl

# Appending lines to condor configuration file
for (( number = $2; number <= $3; number = number+1 ))
do

for (( job = 1; job <= $JOBS; job = job+1 ))
do

events=$(echo "1+(${job}-1)*1000" | bc)

echo "Output = \$(Outputdir)/${TAG}_${number}_${job}_\$(Cluster)_\$(Process).stdout" >> scripts/condor_${TAG}.jdl
echo "Error  = \$(Outputdir)/${TAG}_${number}_${job}_\$(Cluster)_\$(Process).stderr" >> scripts/condor_${TAG}.jdl
echo "Log    = \$(Outputdir)/${TAG}_${number}_${job}_\$(Cluster)_\$(Process).stdlog" >> scripts/condor_${TAG}.jdl
echo "Arguments = ${TAG} ${number} ${job} ${events} ${MAINDIR}" >> scripts/condor_${TAG}.jdl
echo -e "Queue\n" >> scripts/condor_${TAG}.jdl

done
done

# Creating run script for condor configuration file
cat templates/run_template.sh > scripts/run_${TAG}.sh
chmod a+x scripts/run_${TAG}.sh

# Appending lines to run script for condor configuration file
echo -e 'MAINDIR="${5}"\n' >> scripts/run_${TAG}.sh
#echo -e 'cd $MAINDIR\n' >> scripts/run_${TAG}.sh
echo 'cmsRun templates/'${HADRONIZER}' $1 $2 $3 $4 $5' >> scripts/run_${TAG}.sh
#echo 'cmsRun templates/'${HADRONIZER}' $1 $2 $3 $4 $5 \' >> scripts/run_${TAG}.sh
#echo -e '>& ${1}/cmsswlogs/${1}_PU_532_AODSIM_${2}_${3}.log\n' >> scripts/run_${TAG}.sh
#echo 'cmsRun templates/nTuple_mc_532_v0_cfg.py $1 $2 $3 $5 \' >> scripts/run_${TAG}.sh
#echo -e '>& ${1}/cmsswlogs/${1}_PU_532_NTUPLE_${2}_${3}.log\n' >> scripts/run_${TAG}.sh
echo 'rm NuclearInteractionOutputFile.txt PileUpOutputFile.txt' >> scripts/run_${TAG}.sh
echo 'rm events.tree fort.1 histProbFunction.root' >> scripts/run_${TAG}.sh
