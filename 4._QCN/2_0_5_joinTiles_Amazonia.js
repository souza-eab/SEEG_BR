// Perform join tiles and Rasterize variables AGB, BGB, LITTER, CDW, TOTAL and Mapbiomas Reclass with 4° Comunication Nacional (QCN)
// For any issue/bug, please write to wallace.silva@ipam.org.br or edriano.souza@ipam.org.br 
// Developed by: IPAM, SEEG and OC
// Citing: SEEG/Observatório do Clima and IPAM

// @. UPDATE HISTORIC //
// 1:   Insert tiles 
// 1.1: Perform correction of QCN by following rules
// @. ~~~~~~~~~~~~~~ // 
 
/* @. Set user parameters *///

// Insert patch Asset -
var address =   'projects/mapbiomas-workspace/SEEG/2022/QCN/Amz_tiles/tile_id_';

// Id for tiles {Amazon Biome = 25 tiles }
var tiles = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25];

//Geometry
var geom =ee.Image('users/edrianosouza/QCN/am_ctotal4inv').geometry();

 /* @. Set user parameters */// eg.
var dir_output = 'projects/mapbiomas-workspace/SEEG/2022/QCN/';

var version = '2';

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
  
 //Function - Change the variable's format
  return ee.FeatureCollection(asset).set('name',name)
    .map(function(feature){
    return feature.set({
      'name':name,
      'C7_MAPBIOM':ee.Algorithms.If({
        condition:ee.String("").compareTo(feature.getString('C7_MAPBIOM')),
        trueCase:ee.Number.parse(feature.get('C7_MAPBIOM')),
        falseCase:null
      }),
    });
  });
});

featureCollection = ee.FeatureCollection(featureCollection)
  .flatten();

print(featureCollection.limit(10),featureCollection.aggregate_array('C7_MAPBIOM').distinct(),'featureCollection');

Map.addLayer(featureCollection,{},'featureCollection',false);

print(featureCollection.first(),'featureCollection');

Map.addLayer(ee.FeatureCollection([featureCollection.first()]),{},'featureCollection.first()',false);
Map.centerObject(featureCollection.first());


var pastVegetation = ee.Image().select();
var propertieNames = ['cagb','cbgb','clitter','cdw','C7_MAPBIOM','ctotal4inv'];

propertieNames.forEach(function(propertie){
  
  var bandName = 'past_vegetation_'+propertie;

  pastVegetation = pastVegetation.addBands(ee.Image(0).mask(0).paint(featureCollection,propertie)
    .rename(bandName)
    .float()
    );
    
  Map.addLayer(pastVegetation.select(bandName),{palette:palt},bandName);
});

print('pastVegetation',pastVegetation);

// export as GEE asset
Export.image.toAsset({
    "image": pastVegetation,
    "description": 'pastVegetation',
    "assetId": dir_output + 'pastVegetation' + version,
    "scale": 30,
    "pyramidingPolicy": {
        '.default': 'mode'
    },
    "maxPixels": 1e13,
    "region": geom
});
