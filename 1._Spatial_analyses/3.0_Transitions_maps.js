////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////// GOALS: Generate and Export Transition wall-to-wall mapping paired year from a MapBiomas collection (eg. col 6.0) //
//////////  Coordination: Barbara Zimbres, Julia Shimbo, and Ane Alencar /////////////////////////////////////////////////////
//////////  Developed by: IPAM, SEEG and Climate Observatory ////////////////////////////////////////////////////////////////
//////////  Citing: Zimbres et al.,2022.  //////////////////////////////////////////////////////////////////////////////////
/////////   Processing time <2h> in Google Earth Engine ///////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// @. UPDATE HISTORIC EXECUTABLE//
// 1: Generate and Export Transition wall-to-wall mapping paired year from a MapBiomas collection (eg. col 6.0)
// 1.1: Set Asset
// 1.2: Load the assets from the previouly step 'Mask_stable" in coverage 
// 1.3:  Loop to do the arithmetic of bands with all pairs of years, multiplying t1 (y1) by 10000     
// 1.4: Exporting data
// @. ~~~~~~~~~~~~~~ //


/* @. Set user parameters */// eg.

// set directory for the output file
var dir_output = 'projects/ee-seeg-brazil/assets/collection_9/v1/';

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Feature of the region of interest, in this case, all biomes in Brazil
var assetRegions = "projects/ee-seeg-brazil/assets/collection_9/v1/Biomes_BR";
var regions = ee.FeatureCollection(assetRegions);

//List years
var years = ['1989', '1990','1991','1992','1993','1994','1995','1996','1997','1998','1999','2000','2001','2002','2003','2004','2005','2006','2007','2008','2009','2010','2011','2012','2013','2014','2015','2016','2017','2018','2019', '2020'];

// Load the assets from the previouly step 'Mask_stable" in coverage 
var coverage = ee.ImageCollection('projects/ee-seeg-brazil/assets/collection_9/v1/2_1_Mask_stable').aside(print);

// Loop to do the arithmetic of bands with all pairs of years, multiplying t1 (y1) by 10000
years.forEach(function(year){
  var coveraget1 = coverage.filter(ee.Filter.eq("year", ee.Number.parse(year).int())).mosaic();
  var coveraget2 = coverage.filter(ee.Filter.eq("year", ee.Number.parse(year).add(1).int())).mosaic();
  var Transitions = coveraget1.multiply(10000).add(coveraget2).int32();
  var namet1 = ee.Number.parse(year).int();
  var namet2 = ee.Number.parse(String(parseInt(year)+1)).int();
  var Transitions2=Transitions.rename(ee.String("transicao_").cat(ee.String(namet1)).cat(ee.String("_")).cat(namet2));
  print(Transitions2);

// Steps for exporting the pairwise transition maps as an Image Collection
// Create an empty Image Collection in your Asset to store each image that is iteratively being exported
// Eg. we named it "Transitions" that is the name of the Image Collection  
// // *** NOTE: Image pairs will be generated year by year until the last year +1, which does not exist. 
// Please ignore the Task to export this last non-existing year pair (eg. 2021_2022)
// Export Transition wall-to-wall mapping paired year from a MapBiomas collection (eg. col 6.0)
Export.image.toAsset({
  "image": Transitions2.unmask(0).uint32(),
  "description": 'SEEG_Transitions_'+ (parseInt(year))+'_'+(parseInt(year)+1),
  "assetId": 'projects/ee-seeg-brazil/assets/collection_9/v1/3_0_Transitions_maps/SEEG_Transitions_' + (parseInt(year))+'_'+(parseInt(year)+1), // Enter the address and name 'project/seeg/col9/v1'of the Asset to be exported
  "scale": 30,
  "pyramidingPolicy": {
      '.default': 'mode'
  },
  "maxPixels": 1e13,
  "region": regions.geometry().bounds() //If desired, change here to the name of the desired region in Brazil
});   
  
});
