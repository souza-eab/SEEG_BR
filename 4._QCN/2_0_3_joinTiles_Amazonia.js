// Perform join tiles and Rasterize variables AGB, BGB, LITTER, CDW, TOTAL and Mapbiomas Reclass with 4° Fourth Comunication Nacional (QCN/4CN/FCN)
// For any issue/bug, please write to edriano.souza@ipam.org.br or wallace.silva@ipam.org.br 
// Developed by: IPAM, SEEG and OC
// Citing: SEEG/Observatório do Clima and IPAM
// Time processing: v0-1: 250m = 180min | v0-2: 250m = 18min

// @. UPDATE HISTORIC //
// 1:   Insert tiles 
// 1.1: Perform correction of QCN by following rules (next step)
// 2.0: Updated and Congruence QCN and 4
// @. ~~~~~~~~~~~~~~ // 
 
/* @. Set user parameters *///

// Insert list sequence 
//var assets = ee.List.sequence(6,6,1).getInfo();

// Insert Acsess 
var address =   'projects/mapbiomas-workspace/SEEG/2023/QCN/Amz_tiles/tile_id_';

// Id for tiles
var tiles = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25];

//var geom =ee.Image('users/edrianosouza/QCN/am_ctotal4inv').geometry();


var geom = ee.Geometry.Polygon(
        [[[-74.34040691705002, 5.9630086351511690],
                [-74.34040691705002, -34.09134700746099],
                [-33.64704754205002, -34.09134700746099],
                [-33.64704754205002, 5.9630086351511690]]])
                
 /* @. Set user parameters */// eg.
var dir_output = 'projects/mapbiomas-workspace/SEEG/2023/QCN/';

var version1 = 'v0-1'; // 30m 
var version2 = 'v0-2'; //250m

///////////////////////////////////////
/* @. Don't change below this line *///
///////////////////////////////////////


// pre-definied palletes
var pal = require('users/gena/packages:palettes');
var palt = pal.matplotlib.viridis[7]; // AGB e TOTAL
var pala = pal.kovesi.rainbow_bgyr_35_85_c72[7];


var featureCollection = tiles.map(function(i){
  
  var asset = address + i;
  
  var name = asset.split()[6];
  
  return ee.FeatureCollection(asset).set('name',name);
});

featureCollection = ee.FeatureCollection(featureCollection).flatten();

print(featureCollection,'featureCollection');


Map.addLayer(ee.FeatureCollection([featureCollection.first()]),{},'featureCollection.first()',false);
//Map.centerObject(featureCollection.first());


var pastVegetation = ee.Image().select();
var propertieNames = ['c_agb','c_bgb','c_litter','c_dw','MB_C8','c_total'];

propertieNames.forEach(function(propertie){
  
  var bandName = 'past_vegetation_'+propertie;

  pastVegetation = pastVegetation.addBands(ee.Image(0).mask(0).paint(featureCollection,propertie)
    .rename(bandName)
    .float()
    );
    
  Map.addLayer(pastVegetation.select(bandName),{palette:palt},bandName);
});

print('pastVegetation',pastVegetation);


//print('Projection, crs, and crs_transform:', pastVegetation.projection());
//print('Scale in meters:', pastVegetation.projection().nominalScale());

// export as GEE asset
Export.image.toAsset({
    "image": pastVegetation,
    "description": 'pastVegetation' + '_' +version1,
    "assetId": dir_output + 'pastVegetation'  + '_' + version1,
    "scale": 30, // Asset - pastVegetatio_v0-1
    //"scale": 250, // Asset - pastVegetatio_v0-2
    "pyramidingPolicy": {
        '.default': 'mode'
    },
    "maxPixels": 1e13,
    "region": geom
});
