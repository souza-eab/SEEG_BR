////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////// GOALS: Generate and Export Transition wall-to-wall mapping paired year from a MapBiomas collection (eg. col 6.0) //
//////////  Coordination: Barbara Zimbres, Julia Shimbo, and Ane Alencar /////////////////////////////////////////////////////
//////////  Developed by: IPAM, SEEG and Climate Observatory ////////////////////////////////////////////////////////////////
//////////  Citing: Zimbres et al.,2022.  //////////////////////////////////////////////////////////////////////////////////
/////////   Processing time <2h> in Google Earth Engine ///////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// @. UPDATE HISTORIC //
// 1: SCRIPT TO GENERATE REGENERATION MASKS FROM A COLLECTION OF MAPBIOMAS (eg. col 6.0)
// 1.1: Acess Asset MapBiomas and Biomes BRAZIL
// 1.1: Remap layer col. 6.0 Mapiomas 
// @. ~~~~~~~~~~~~~~ // 

/* @. Set user parameters */// eg.

// set directory for the output file
var dir_output = 'projects/mapbiomas-workspace/SEEG/2021/Col9/';

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Feature of the region of interest, in this case, all biomes in Brazil
var assetRegions = "projects/mapbiomas-workspace/AUXILIAR/biomas-2019";
var regions = ee.FeatureCollection(assetRegions);

//List years
var anos = ['1989', '1990','1991','1992','1993','1994','1995','1996','1997','1998','1999','2000','2001','2002','2003','2004','2005','2006','2007','2008','2009','2010','2011','2012','2013','2014','2015','2016','2017','2018','2019', '2020'];

// Load the assets from the MapBiomas collection used (col6)
var cobertura = ee.ImageCollection('projects/mapbiomas-workspace/SEEG/2021/Col9/mask_stable').aside(print);

// Loop to do the arithmetic of bands with all pairs of years, multiplying t1 (y1) by 10000
anos.forEach(function(ano){
  var coberturat1 = cobertura.filter(ee.Filter.eq("year", ee.Number.parse(ano).int())).mosaic();
  var coberturat2 = cobertura.filter(ee.Filter.eq("year", ee.Number.parse(ano).add(1).int())).mosaic();
  var transicoes = coberturat1.multiply(10000).add(coberturat2).int32();
  var namet1 = ee.Number.parse(ano).int();
  var namet2 = ee.Number.parse(String(parseInt(ano)+1)).int();
  var transicoes2=transicoes.rename(ee.String("transicao_").cat(ee.String(namet1)).cat(ee.String("_")).cat(namet2));
  print(transicoes2);

// Steps for exporting the pairwise transition maps as an Image Collection
// Create an empty Image Collection in your Asset to store each image that is iteratively being exported
// Eg. we named it "Transitions" that is the name of the Image Collection  
// // *** NOTE: Image pairs will be generated year by year until the last year +1, which does not exist. 
// Please ignore the Task to export this last non-existing year pair (eg. 2021_2022)

Translated with www.DeepL.com/Translator (free version)
  
// Export Transition wall-to-wall mapping paired year from a MapBiomas collection (eg. col 6.0)
Export.image.toAsset({
  "image": transicoes2.unmask(0).uint32(),
  "description": 'SEEG_Transicoes_2021_c6_'+ (parseInt(ano))+'_'+(parseInt(ano)+1),
  "assetId": 'projects/mapbiomas-workspace/SEEG/2021/Col9/Transicoes/SEEG_Transicoes_2021_c6_'+ (parseInt(ano))+'_'+(parseInt(ano)+1), // Enter the address and name 'project/seeg/col9/v1'of the Asset to be exported
  "scale": 30,
  "pyramidingPolicy": {
      '.default': 'mode'
  },
  "maxPixels": 1e13,
  "region": regions.geometry().bounds() //If desired, change here to the name of the desired region in Brazil
});   
  
});
