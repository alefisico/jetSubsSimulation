import FWCore.ParameterSet.Config as cms

process = cms.Process("Demo")

process.load("FWCore.MessageService.MessageLogger_cfi")

process.maxEvents = cms.untracked.PSet( input = cms.untracked.int32(-1) )

process.source = cms.Source("PoolSource",
    # replace 'myfile.root' with the source file you want to use
    fileNames = cms.untracked.vstring(
        'file:RPVSt200tojj_13TeV_AODSIM_test.root'
    )
)

process.TFileService = cms.Service("TFileService",
		fileName = cms.string('testNPV.root')
)

process.demo = cms.EDAnalyzer('mySIM13TeV',
		vtx = cms.InputTag( 'offlinePrimaryVertices' )
)


process.p = cms.Path(process.demo)
