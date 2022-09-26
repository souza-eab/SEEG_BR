// import 'c_total' from qcn

// import 'c_total' from qcn 
var qcn_total = ee.ImageCollection('projects/mapbiomas-workspace/SEEG/2021/QCN/QCN_30m_c')
  //.filterMetadata('biome', 'equals', 'caatinga')
  .mosaic();

// import rectified 'c_total' 
var qcn_total_rect = ee.ImageCollection('projects/mapbiomas-workspace/SEEG/2021/QCN/QCN_30m_rect') 
  .filterMetadata('version', 'equals', '1')
  //.filterMetadata('biome', 'equals', 'caatinga')
  .mosaic();

// Add Asset Biomes_BR (Source: IBGE && INCRA, 2019) var BiomesBR = ee.FeatureCollection('projects/ee-seeg-brazil/assets/collection_9/v1/Biomes_BR').filter('CD_LEGENDA == "CERRADO"');

// define pallete 
var pal = require('users/gena/packages:palettes').matplotlib.viridis[7];

// Palettes 
var vis = {
    //'bands': 'b1',
    'min': 0,
    'max': 62,  //*BZ
    'palette': require('users/mapbiomas/modules:Palettes.js').get('classification7')  //*ok
};


// Palettes 
var vis2 = {
    //'bands': 
    'min': 0,
    'max': 49,  //*BZ
    'palette': require('users/mapbiomas/modules:Palettes.js').get('classification6')  //*ok
};
var Mapp = require('users/joaovsiqueira1/packages:Mapp.js');

// plot 
Map.addLayer(qcn_total.select(['total']), {min: 0, max: 168, palette: pal}, 'QCN Total_V1',false); 
Map.addLayer(qcn_total_rect.select(['total_2020']), {min: 0, max: 168, palette: pal}, 'QCN Rect_V1 - 2020',false); 
Map.addLayer(qcn_total_rect.select(['total_1985']), {min: 0, max: 168, palette: pal}, 'QCN Rect_V1 - 1985',false);
Map.addLayer(qcn_total.select(['qcnclass']), vis2, 'qcn_classes_v1 - 2020'); 

// import 'c_total' from qcn

// import 'c_total' from qcn 
var qcn_total2 = ee.ImageCollection('projects/mapbiomas-workspace/SEEG/2022/QCN/QCN_30m_rect_v2_0')
  //.filterMetadata('biome', 'equals', 'caatinga')
  .mosaic();

// import rectified 'c_total' 
var qcn_total_rect2 = ee.ImageCollection('projects/mapbiomas-workspace/SEEG/2022/QCN/QCN_30m_rect_v2_0_0') 
  .filterMetadata('version', 'equals', '2')
  //.filterMetadata('biome', 'equals', 'caatinga')
  .mosaic();

// plot 
Map.addLayer(qcn_total2.select(['total']), vis, 'QCN Total_V2', false); 
Map.addLayer(qcn_total_rect2.select(['total_2020']), {min: 0, max: 168, palette: pal}, 'QCN Rect_V2 - 2020',false); 
Map.addLayer(qcn_total_rect2.select(['total_1985']), {min: 0, max: 168, palette: pal}, 'QCN Rect_V2 - 1985',false);
Map.addLayer(qcn_total2.select(['qcnclass']),[], 'qcn_classes_v2 - 2020'); 


Map.setOptions({ 'styles': { 'Dark': Mapp.getStyle('Dark'), 'Dark2':Mapp.getStyle('Dark2'), 'Aubergine':Mapp.getStyle('Aubergine'), 'Silver':Mapp.getStyle('Silver'), 'Night':Mapp.getStyle('Night'), } });

