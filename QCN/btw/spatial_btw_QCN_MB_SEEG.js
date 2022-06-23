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
Map.addLayer(qcn_total.select(['total']).clip(roi), {min: 0, max: 168, palette: pal}, 'QCN Total');
Map.addLayer(qcn_total_rect.select(['total_2020']).clip(roi), {min: 0, max: 168, palette: pal}, 'QCN Rect - 2020');
Map.addLayer(qcn_total_rect.select(['total_1985']).clip(roi), {min: 0, max: 168, palette: pal}, 'QCN Rect - 1985');
Map.addLayer(qcn_total_rect.select(['total_1990']).clip(roi), {min: 0, max: 168, palette: pal}, 'QCN Rect - 1990');
Map.addLayer(qcn_total_rect.select(['total_1995']).clip(roi), {min: 0, max: 168, palette: pal}, 'QCN Rect - 1995');
Map.addLayer(qcn_total_rect.select(['total_2000']).clip(roi), {min: 0, max: 168, palette: pal}, 'QCN Rect - 2000');
Map.addLayer(qcn_total_rect.select(['total_2005']).clip(roi), {min: 0, max: 168, palette: pal}, 'QCN Rect - 2005');
Map.addLayer(qcn_total_rect.select(['total_2010']).clip(roi), {min: 0, max: 168, palette: pal}, 'QCN Rect - 2010');
Map.addLayer(qcn_total_rect.select(['total_2015']).clip(roi), {min: 0, max: 168, palette: pal}, 'QCN Rect - 2015');
//Map.addLayer(qcn_total_rect.select(['total_2020']), {min: 0, max: 168, palette: pal}, 'QCN Rect - 2020');



var roi = ee.Geometry.Polygon(
        [[[-74.34040691705002, 5.9630086351511690],
                [-74.34040691705002, -34.09134700746099],
                [-33.64704754205002, -34.09134700746099],
                [-33.64704754205002, 5.9630086351511690]]])
                
                
// Create a circle by drawing a 20000 meter buffer around a point.
var roi1 = ee.Geometry.Point([-47.8657, -15.9119]).buffer(200000);


// Create a circle by drawing a 20000 meter buffer around a point.
var roi = ee.Geometry.Point([-47.8657, -15.9119]).buffer(20000);

var image = ee.Image('projects/mapbiomas-workspace/AUXILIAR/RASTER/regions/CERRADO');

//GEDI
var l4b = ee.Image('LARSE/GEDI/GEDI04_B_002')
print(l4b)

Map.addLayer(l4b.select('SE').clip(roi), {min: 10, max: 50, palette: '000004,3b0f6f,8c2981,dd4a69,fe9f6d,fcfdbf'}, 'L4 Gedi_SE')
Map.addLayer(l4b.select('MU').clip(roi), {min: 10, max: 250, palette: '440154,414387,2a788e,23a884,7ad151,fde725'}, 'L4 Gedi Mean Biomass')



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



// Create a circle by drawing a 20000 meter buffer around a point.
var roi = ee.Geometry.Point([-47.8657, -15.9119]).buffer(20000);


//Map Add Layer   
Map.addLayer(Mask_stable.select(['SEEG_c9_v1_2020_classification_2020']).clip(roi), vis, '2_1_Mask_stable_2020', false);
Map.addLayer(Mask_stable.select(['SEEG_c9_v1_1985_classification_1985']).clip(roi), vis, '2_1_Mask_stable_1985', false);
Map.addLayer(MapBiomas_col6.select('classification_1985').clip(roi), vis,"Mapbiomas_1985",false);
Map.addLayer(MapBiomas_col6.select('classification_2020').clip(roi), vis,"Mapbiomas_2020",false);

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
