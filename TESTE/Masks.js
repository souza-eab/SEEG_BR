////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////// GOALS: Transition wall-to-wall mapping paired year from a MapBiomas collection (eg. col 6.0) //////////////////////
//////////  Coordination: Barbara Zimbres, Julia Shimbo, and Ane Alencar /////////////////////////////////////////////////////
//////////  Developed by: IPAM, SEEG and Climate Observatory ////////////////////////////////////////////////////////////////
//////////  Citing: Zimbres et al.,2022.  //////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// Asset Mapbimoas Col6
var MapBiomas_col6 = ee.Image("projects/mapbiomas-workspace/public/collection6/mapbiomas_collection60_integration_v1");

// Create a circle by drawing a 20000 meter buffer around a point.
var roi = ee.Geometry.Point([-47.8657, -15.9119]).buffer(20000);

// Add Asset Biomes_BR (Source: IBGE && INCRA, 2019)
var BiomesBR = ee.FeatureCollection('projects/ee-seeg-brazil/assets/collection_9/v1/Biomes_BR').filter('CD_LEGENDA == "CERRADO"');
 
 
// Add Asset  3.0 Transitions_maps
var listImages = ee.data.listAssets('projects/ee-seeg-brazil/assets/collection_9/v1/3_0_Transitions_maps').assets;

var image = ee.Image().select();

listImages.forEach(function(obj){
  image = image.addBands(obj.id);
});

print(image)

var palettes = require('users/mapbiomas/modules:Palettes.js');
var vis = {
    'min': 0,
    'max': 49,
    'palette': palettes.get('classification6'),
    bands:['transicao_2019_2020']
    };


Map.addLayer(image,vis,'original',false);

var image_2 = image.divide(10000).int();
var image_3 = image.divide(100).int()
var image_4 = image.mod(100);
var image_5 = image.divide(100).mod(100).int();

//Map.addLayer(image_2.clip(roi),vis,'img-2 .divide(10000).int()-ROI2',false);
Map.addLayer(image_2.clip(BiomesBR),vis,'img-3 .divide(100).int().mod(100)-ROI3',false);
Map.addLayer(image_4.clip(BiomesBR),vis,'img-4 .mod(100)-Roi4',false);
Map.addLayer(image_5.clip(BiomesBR),vis,'Joint',false);



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

Map.setOptions('SATELLITE');
Map.setCenter(-47.8657, -15.9119, 12);
