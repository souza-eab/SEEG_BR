
// import 'c_total' from qcn

// import 'c_total' from qcn
var qcn_total = ee.ImageCollection('projects/mapbiomas-workspace/SEEG/2021/QCN/QCN_30m_c')
                  .filterMetadata('biome', 'equals', 'cerrado')
                  .mosaic();
                  
// import rectified 'c_total'
var qcn_total_rect = ee.ImageCollection('projects/mapbiomas-workspace/SEEG/2021/QCN/QCN_30m_rect')
                        //.filterMetadata('version', 'equals', '1')
                        .filterMetadata('biome', 'equals', 'cerrado')
                        .mosaic();


// Add Asset Biomes_BR (Source: IBGE && INCRA, 2019)
var BiomesBR = ee.FeatureCollection('projects/ee-seeg-brazil/assets/collection_9/v1/Biomes_BR').filter('CD_LEGENDA == "CERRADO"');



// define pallete
var pal = require('users/gena/packages:palettes').matplotlib.viridis[7];

// plot
Map.addLayer(qcn_total.select(['total']).clip(geometry), {min: 0, max: 168, palette: pal}, 'QCN Total');
Map.addLayer(qcn_total_rect.select(['total_2020']).clip(geometry), {min: 0, max: 168, palette: pal}, 'QCN Rect - 2020');
Map.addLayer(qcn_total_rect.select(['total_1985']).clip(geometry), {min: 0, max: 168, palette: pal}, 'QCN Rect - 1985');
Map.addLayer(qcn_total_rect.select(['total_1990']).clip(geometry), {min: 0, max: 168, palette: pal}, 'QCN Rect - 1990');
Map.addLayer(qcn_total_rect.select(['total_1995']).clip(geometry), {min: 0, max: 168, palette: pal}, 'QCN Rect - 1995');
Map.addLayer(qcn_total_rect.select(['total_2000']).clip(geometry), {min: 0, max: 168, palette: pal}, 'QCN Rect - 2000');
Map.addLayer(qcn_total_rect.select(['total_2005']).clip(geometry), {min: 0, max: 168, palette: pal}, 'QCN Rect - 2005');
Map.addLayer(qcn_total_rect.select(['total_2010']).clip(geometry), {min: 0, max: 168, palette: pal}, 'QCN Rect - 2010');
Map.addLayer(qcn_total_rect.select(['total_2015']).clip(geometry), {min: 0, max: 168, palette: pal}, 'QCN Rect - 2015');
//Map.addLayer(qcn_total_rect.select(['total_2020']), {min: 0, max: 168, palette: pal}, 'QCN Rect - 2020');



var image = ee.Image('projects/mapbiomas-workspace/AUXILIAR/RASTER/regions/CERRADO');

//GEDI
var l4b = ee.Image('LARSE/GEDI/GEDI04_B_002')
print(l4b)

Map.addLayer(l4b.select('SE').clip(geometry), {min: 10, max: 50, palette: '000004,3b0f6f,8c2981,dd4a69,fe9f6d,fcfdbf'}, 'L4 Gedi_SE')
Map.addLayer(l4b.select('MU').clip(geometry), {min: 10, max: 250, palette: '440154,414387,2a788e,23a884,7ad151,fde725'}, 'L4 Gedi Mean Biomass')



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


// import_mask
var Mask_stable = ee.ImageCollection('projects/ee-seeg-brazil/assets/collection_9/v1/2_1_Mask_stable')
  .toBands()
  .aside(print);
// Asset Mapbimoas Col6
var MapBiomas_col6 = ee.Image("projects/mapbiomas-workspace/public/collection6/mapbiomas_collection60_integration_v1");

// Add Asset Biomes_BR (Source: IBGE && INCRA, 2019)
var BiomesBR = ee.FeatureCollection('projects/ee-seeg-brazil/assets/collection_9/v1/Biomes_BR').filter('CD_LEGENDA == "CERRADO"');
 
// Palettes
var palettes = require('users/mapbiomas/modules:Palettes.js');
var vis = {
    'min': 0,
    'max': 49,
    'palette': palettes.get('classification6')
    };


//Map Add Layer   
Map.addLayer(Mask_stable.select(['SEEG_c9_v1_2020_classification_2020']).clip(geometry), vis, '2_1_Mask_stable_2020', false);
Map.addLayer(Mask_stable.select(['SEEG_c9_v1_1985_classification_1985']).clip(geometry), vis, '2_1_Mask_stable_1985', false);
Map.addLayer(MapBiomas_col6.select('classification_1985').clip(geometry), vis,"Mapbiomas_1985",false);
Map.addLayer(MapBiomas_col6.select('classification_2020').clip(geometry), vis,"Mapbiomas_2020",false);

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


function bufferPoints(radius, bounds) {
  return function(pt) { 
    pt = ee.Feature(pt);
    return bounds ? pt.buffer(radius).bounds() : pt.buffer(radius);
  };
}
// var utils = require('users/gena/packages:utils')
var palettes = require('users/gena/packages:palettes') 

//Set area editing the geometry

//QA function
var qualityMask = function(im) {
  return im.updateMask(im.select('quality_flag').eq(1))
            .updateMask(im.select('degrade_flag').eq(0))
            .updateMask(im.select('solar_elevation').lt(0)) // <0 for night observations (to use night observation if possible)
            .updateMask(im.select('beam').gt(4)) // >4 for power beams (for forest use only power beams)
            .updateMask(im.select('sensitivity').gte(0.95)) // sensitivity > 90
            .updateMask(im.select('landsat_treecover').gt(0)) // PTC filter (0-100)
            .updateMask(im.select('leaf_off_flag').eq(0)) // Leaf-off = 1, Leaf-on =0
            .updateMask(im.select('landsat_water_persistence').lt(50)) // water persistence 0-100
            ;
};

//Required output metrics 
var metrics = ['rh100','rh98','rh95','rh50','delta_time','shot_number','beam','pft_class']

//Set dates
var startDate = '2019-01-01'
var endDate = '2020-12-31'

//Filtering collection 
var dataset = ee.ImageCollection('LARSE/GEDI/GEDI02_A_002_MONTHLY')
                  .filter(ee.Filter.date(startDate, endDate))
                  .filterBounds(geometry)
                  .map(qualityMask)
                  .select(metrics);

//Vis parameters
var gediVis = {
  min: 1,
  max: 40,
  palette: 'darkred,red,orange,green,darkgreen',
};

Map.centerObject(geometry,8);


//Set proejection and scale
var projection = dataset.first().projection()
//.aside(print);
var scale = projection.nominalScale()
//.aside(print);

var mosaic = dataset.mosaic().setDefaultProjection({crs:projection, scale:scale});
Map.addLayer(mosaic.select(0).clip(geometry), gediVis, 'metric');


//Generating feature
var points = mosaic.sample({
  factor: null,
  numPixels: null,
  region:geometry,
  scale: scale,
  projection: projection,
  geometries:true});
  
print('number of footprints: ', points.size());
print(points.limit(10));

// Map.addLayer(points);

var points = points.map(bufferPoints(12.5, false)); 
//
var empty = ee.Image().byte();

var fills = empty.paint({
  featureCollection: points,
  color: 'rh98',
});

// var palette = ['#801D08','#E32B04','#F08E17', '#35DA1E', '#32622C'];
var palette = palettes.crameri.bamako[50].reverse()

Map.addLayer(fills, {palette: palette, max:40}, 'colored fills');  

  

  
