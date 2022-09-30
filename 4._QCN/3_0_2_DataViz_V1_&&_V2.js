
// import 'c_total' from qcn v1
var qcn_total = ee.ImageCollection('projects/mapbiomas-workspace/SEEG/2021/QCN/QCN_30m_c')
  .filterMetadata('biome', 'equals', 'caatinga')
  .mosaic();

// import rectified 'c_total' v1
var qcn_total_rect = ee.ImageCollection('projects/mapbiomas-workspace/SEEG/2021/QCN/QCN_30m_rect') 
  .filterMetadata('version', 'equals', '1')
  .filterMetadata('biome', 'equals', 'caatinga')
  .mosaic();

// import 'c_total' from qcn v2
var qcn_total2 = ee.ImageCollection('projects/mapbiomas-workspace/SEEG/2022/QCN/QCN_30m_BR_v2_0_1')
  .filterMetadata('biome', 'equals', 'caatinga')
  .mosaic();

// import rectified 'c_total' v2
var qcn_total_rect2 = ee.ImageCollection('projects/mapbiomas-workspace/SEEG/2022/QCN/QCN_30m_BR_v2_0_2_Rect') 
  .filterMetadata('version', 'equals', '2')
  .filterMetadata('biome', 'equals', 'caatinga')
  .mosaic();



// define pallete
var pal = require('users/gena/packages:palettes').matplotlib.viridis[7];
var Mapp = require('users/joaovsiqueira1/packages:Mapp.js');
var ColorRamp = require('users/joaovsiqueira1/packages:ColorRamp.js');

var visFlo = {
    bands: ['total'],
    min: 0,
    max: 182,
    palette:["#440154",
    "#46327e",
    "#365c8d",
     "#277f8e",
     "#1fa187",
     "#4ac16d",
      "#a0da39",
      "#fde725"
            ]
};


var visFlo2 = {
    bands: ['total_1985'],
    min: 0,
    max: 182,
    palette:["#440154",
    "#46327e",
    "#365c8d",
     "#277f8e",
     "#1fa187",
     "#4ac16d",
      "#a0da39",
      "#fde725"
            ]
};

ColorRamp.init(
    {
        'orientation': 'horizontal',
        'backgroundColor': '212121',
        'fontColor': 'ffffff',
        'height': '5px',
        'width': '300px',
    }
);

ColorRamp.add({
    'title': '4CN - Biomassa (tC/ha)',
    'min': visFlo.min,
    'max': visFlo.max,
    'palette': visFlo.palette,
});

ColorRamp.add({
    'title': '4CN_Rectity - Biomassa (tC/ha)',
    'min': visFlo2.min,
    'max': visFlo2.max,
    'palette': visFlo2.palette,
});


// Get legend widget
var legend = ColorRamp.getWidget();

Map.add(legend);



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



// plot v1
Map.addLayer(qcn_total.select(['total']), visFlo, 'QCN Total_V1'); 
//Map.addLayer(qcn_total_rect.select(['total_2020']), {min: 0, max: 168, palette: pal}, 'QCN Rect_V1 - 2020',false); 
Map.addLayer(qcn_total_rect.select(['total_1985']), visFlo2, 'QCN Rect_V1 - 1985');
Map.addLayer(qcn_total.select(['qcnclass']), vis2, 'qcn_classes_v1 - 2020'); 

// plot v2
Map.addLayer(qcn_total2.select(['total']), visFlo, 'QCN Total_V2'); 
//Map.addLayer(qcn_total_rect2.select(['total_2020']), visFlo, 'QCN Rect_V2 - 2020',false); 
Map.addLayer(qcn_total_rect2.select(['total_1985']), visFlo2, 'QCN Rect_V2 - 1985');
Map.addLayer(qcn_total2.select(['qcnclass']),vis, 'qcn_classes_v2 - 2020'); 

Map.setOptions({ 'styles': { 'Dark': Mapp.getStyle('Dark'), 'Dark2':Mapp.getStyle('Dark2'), 'Aubergine':Mapp.getStyle('Aubergine'), 'Silver':Mapp.getStyle('Silver'), 'Night':Mapp.getStyle('Night'), } });
// The most recent zoom is the one the view will have.
Map.setZoom(6)
