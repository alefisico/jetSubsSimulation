// -*- C++ -*-
//
// Package:    mySIM13TeV
// Class:      mySIM13TeV
// 
/**\class mySIM13TeV mySIM13TeV.cc mySIM13TeV/mySIM13TeV/plugins/mySIM13TeV.cc

 Description: [one line class summary]

 Implementation:
     [Notes on implementation]
*/
//
// Original Author:  alejandro gomez
//         Created:  Fri, 18 Jul 2014 20:40:47 GMT
// $Id$
//
//


// system include files
#include <memory>

// user include files
#include "TH1D.h"

#include "FWCore/Framework/interface/Frameworkfwd.h"
#include "FWCore/Framework/interface/EDAnalyzer.h"

#include "FWCore/Framework/interface/Event.h"
#include "FWCore/Framework/interface/MakerMacros.h"

#include "FWCore/ParameterSet/interface/ParameterSet.h"
#include "DataFormats/VertexReco/interface/Vertex.h"
#include "DataFormats/VertexReco/interface/VertexFwd.h"
#include "FWCore/ServiceRegistry/interface/Service.h"
#include "CommonTools/UtilAlgos/interface/TFileService.h"
//
// class declaration
//

class mySIM13TeV : public edm::EDAnalyzer {
   public:
      explicit mySIM13TeV(const edm::ParameterSet&);
      ~mySIM13TeV();

      static void fillDescriptions(edm::ConfigurationDescriptions& descriptions);


   private:
      virtual void beginJob() override;
      virtual void analyze(const edm::Event&, const edm::EventSetup&) override;
      virtual void endJob() override;
      edm::Service<TFileService> fs_;
      edm::InputTag srcVrtx_;
      TH1F *NPVHisto_;

      //virtual void beginRun(edm::Run const&, edm::EventSetup const&) override;
      //virtual void endRun(edm::Run const&, edm::EventSetup const&) override;
      //virtual void beginLuminosityBlock(edm::LuminosityBlock const&, edm::EventSetup const&) override;
      //virtual void endLuminosityBlock(edm::LuminosityBlock const&, edm::EventSetup const&) override;

      // ----------member data ---------------------------
};

//
// constants, enums and typedefs
//

//
// static data member definitions
//

//
// constructors and destructor
//
mySIM13TeV::mySIM13TeV(const edm::ParameterSet& iConfig)
{
	srcVrtx_                 = iConfig.getParameter<edm::InputTag>             ("vtx");

}


mySIM13TeV::~mySIM13TeV()
{
 
   // do anything here that needs to be done at desctruction time
   // (e.g. close files, deallocate resources etc.)

}


//
// member functions
//

// ------------ method called for each event  ------------
void
mySIM13TeV::analyze(const edm::Event& iEvent, const edm::EventSetup& iSetup)
{
   using namespace edm;

	edm::Handle<reco::VertexCollection> recVtxs;
	iEvent.getByLabel(srcVrtx_,recVtxs);

	NPVHisto_->Fill( recVtxs->size() );

}


// ------------ method called once each job just before starting event loop  ------------
void 
mySIM13TeV::beginJob()
{
	NPVHisto_ = fs_->make<TH1F>("NumberPrimaryVertex","NumberPrymaryVertex",80,0,80);
}

// ------------ method called once each job just after ending the event loop  ------------
void 
mySIM13TeV::endJob() 
{
}

// ------------ method called when starting to processes a run  ------------
/*
void 
mySIM13TeV::beginRun(edm::Run const&, edm::EventSetup const&)
{
}
*/

// ------------ method called when ending the processing of a run  ------------
/*
void 
mySIM13TeV::endRun(edm::Run const&, edm::EventSetup const&)
{
}
*/

// ------------ method called when starting to processes a luminosity block  ------------
/*
void 
mySIM13TeV::beginLuminosityBlock(edm::LuminosityBlock const&, edm::EventSetup const&)
{
}
*/

// ------------ method called when ending the processing of a luminosity block  ------------
/*
void 
mySIM13TeV::endLuminosityBlock(edm::LuminosityBlock const&, edm::EventSetup const&)
{
}
*/

// ------------ method fills 'descriptions' with the allowed parameters for the module  ------------
void
mySIM13TeV::fillDescriptions(edm::ConfigurationDescriptions& descriptions) {
  //The following says we do not know what parameters are allowed so do no validation
  // Please change this to state exactly what you do use, even if it is no parameters
  edm::ParameterSetDescription desc;
  desc.setUnknown();
  descriptions.addDefault(desc);
}

//define this as a plug-in
DEFINE_FWK_MODULE(mySIM13TeV);
