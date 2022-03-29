////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////// GOAL: Acess RECLASSIFICATION TO GENERATE DEFORESTATION AND REGENERATION MASKS  ////////////////////////////////////
//////////  Coordination: Barbara Zimbres, Julia Shimbo, and Ane Alencar /////////////////////////////////////////////////////
//////////  Developed by: IPAM, SEEG and Climate Observatory ////////////////////////////////////////////////////////////////
//////////  Citing: Zimbres et al.,2022.  //////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// set directory for the output file
var dir_output = 'projects/ee-seeg-brazil/assets/collection_9/v1/';


// Add Asset Collection Mapbiomas 6.0 
var MapBiomas_col6 = ee.Image("projects/mapbiomas-workspace/public/collection6/mapbiomas_collection60_integration_v1");


// Create a circle by drawing a 20000 meter buffer around a point.
var roi = ee.Geometry.Point([-47.8657, -15.9119]).buffer(20000);

// Add Asset Biomes_BR (Source: IBGE && INCRA, 2019)
var BiomesBR = ee.FeatureCollection('projects/ee-seeg-brazil/assets/collection_9/v1/Biomes_BR').filter('CD_LEGENDA == "CERRADO"');
 

// Add Asset Deforestation 
var Def = ee.Image('projects/ee-seeg-brazil/assets/collection_9/v1/1_0_Deforestation_masks');

// Add Asset Deforestation 1.0
var Reg = ee.Image('projects/ee-seeg-brazil/assets/collection_9/v1/1_0_Regeneration_masks');


//////////////////////////////////////////////////////
//? Map.addLayer
/////////////////////////////////////////////////////

// get color-ramp module
var vis = {
    'min': 0,
    'max': 49,
    'palette': require('users/mapbiomas/modules:Palettes.js').get('classification6')
};


// Asset Collection Mapbiomas 6.0 eg. Biome Cerrado
Map.addLayer(MapBiomas_col6.select('classification_2020').clip(roi), vis,"Mapbiomas_2020",false);


// Asset Collection Mapbiomas 6.0 eg. Biome Cerrado
Map.addLayer(BiomesBR.select('CD_LEGENDA1'),{},'Biome_CERRADO');

// Asset Biomes_BR (Source: IBGE && INCRA, 2019)
// Deforestation
Map.addLayer(Def.select('deforestation2020').selfMask().clip(BiomesBR), {'min': 0,'max': 1, 'palette': '#FFFFFF,#FF0000'},"Deforestation_2020");
// Deforestation from ROI
Map.addLayer(Def.select('deforestation2020').selfMask().clip(roi), {'min': 0,'max': 1, 'palette': '#FFFFFF,#FF0000'},"ROI_Deforestation_2020");

// Regeneration
Map.addLayer(Reg.select('regeneration2020').selfMask().clip(BiomesBR), {'min': 0,'max': 1, 'palette': '#FFFFFF,#00FF00'},"Regeneration_2020") 
Map.addLayer(Reg.select('regeneration2020').selfMask().clip(roi), {'min': 0,'max': 1, 'palette': '#FFFFFF,#00FF00'},"ROI_Regeneration_2020") 


var Mapp = require('users/joaovsiqueira1/packages:Mapp.js');

Map.setOptions({
  'styles': {
    'Dark': Mapp.getStyle('Dark'),
    'Dark2':Mapp.getStyle('Dark2'),
    'Aubergine':Mapp.getStyle('Aubergine'),
    'Silver':Mapp.getStyle('Silver'),
    'Night':Mapp.getStyle('Night'),
  }
});


//Map.setOptions('SATELLITE');
//Map.setCenter(-47.8657, -15.9119, 12);

