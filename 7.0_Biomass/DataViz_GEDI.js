// Code Get link 
//*@ <https://code.earthengine.google.com/c45a1dbb3505b01d9bfdf24f6d5470e2>

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////// GOALS: DataVis Biomass  /////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////  Created by: Edriano Souza  //////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////  Developed by: IPAM, SEEG and Climate Observatory ////////////////////////////////////////////////////////////////////////////////////
/////////   Processing time <2h> in Google Earth Engine /////////////////////////////////////////////////////////////////////////////////////////
// /////    For clarification or an issue/bug report, please write to edriano.souza@ipam.org.br and/or barbara.zimbres@ipam.org.br //////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




//*@ Mapbiomas ( LULC- pixel 30m)
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


 // Asset Mapbimoas Col6
var MapBiomas_col6 = ee.Image("projects/mapbiomas-workspace/public/collection6/mapbiomas_collection60_integration_v1");

// Palettes
var palettes = require('users/mapbiomas/modules:Palettes.js');
var vis = {
    'min': 0,
    'max': 49,
    'palette': palettes.get('classification6')
    };

Map.addLayer(MapBiomas_col6.select('classification_1985').clip(geometry), vis,"Mapbiomas_1985",false);
Map.addLayer(MapBiomas_col6.select('classification_2020').clip(geometry), vis,"Mapbiomas_2020",false);


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//*@ QCN ( AGB_total - pixel 30_250m)
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// import 'c_total' from qcn
var qcn_total = ee.ImageCollection('projects/mapbiomas-workspace/SEEG/2021/QCN/QCN_30m_c')
                  .filterMetadata('biome', 'equals', 'cerrado')
                  .mosaic();
                  
// import rectified 'c_total'
var qcn_total_rect = ee.ImageCollection('projects/mapbiomas-workspace/SEEG/2021/QCN/QCN_30m_rect')
                        //.filterMetadata('version', 'equals', '1')
                        .filterMetadata('biome', 'equals', 'cerrado')
                        .mosaic();

// define pallete
var pal = require('users/gena/packages:palettes').matplotlib.viridis[7];
var Mapp = require('users/joaovsiqueira1/packages:Mapp.js');
var ColorRamp = require('users/joaovsiqueira1/packages:ColorRamp.js');

var visFlo = {
    bands: ['total'],
    min: 1,
    max: 75,
    palette:["#fde725",
            "#a0da39",
            "#4ac16d",
            "#1fa187",
            "#277f8e",
            "#365c8d",
            "#46327e",
            "#440154"
            ]
};


var visFlo2 = {
    bands: ['total_2020'],
    min: 1,
    max: 75,
    palette:["#fde725",
            "#a0da39",
            "#4ac16d",
            "#1fa187",
            "#277f8e",
            "#365c8d",
            "#46327e",
            "#440154"
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



// plot
Map.addLayer(qcn_total.select(['total']).clip(geometry),  visFlo, 'QCN_bruto Total');
Map.addLayer(qcn_total_rect.clip(geometry), visFlo2, 'QCN Rectify');


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//*@ GEDI l4b (AGBD - Biomass - pixel 1km)
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


var l4b = ee.Image('LARSE/GEDI/GEDI04_B_002')
print(l4b)

var visFlo3 = {
    bands: ['SE'],
    min: 1,
    max: 50,
    palette:['#000004',
            '#3b0f6f',
            '#8c2981',
            '#dd4a69',
            '#fe9f6d',
            '#fcfdbf'
            ]
};


var visFlo4 = {
    bands: ['MU'],
    min: 1,
    max: 75,
    palette:["#fde725",
            "#a0da39",
            "#4ac16d",
            "#1fa187",
            "#277f8e",
            "#365c8d",
            "#46327e",
            "#440154"
            ]
};



ColorRamp.add({
    'title': 'L4 Gedi Mean Biomass',
    'min': visFlo4.min,
    'max': visFlo4.max,
    'palette': visFlo4.palette,
});


ColorRamp.add({
    'title': 'L4 Gedi_SE',
    'min': visFlo3.min,
    'max': visFlo3.max,
    'palette': visFlo3.palette,
});



//DataVis
Map.addLayer(l4b.select('SE').clip(geometry), visFlo3, 'L4 Gedi_SE')
Map.addLayer(l4b.select('MU').clip(geometry), visFlo4, 'L4 Gedi Mean Biomass')




Map.setOptions('SATELLITE');
Map.setCenter(-47.8657, -15.9119, 12);


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//*@ GEDI l2a ( Height - radius 25m)
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


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


ColorRamp.add({
    'title': 'rh100 metric',
    'min': gediVis.min,
    'max': gediVis.max,
    'palette': gediVis.palette,
});


//Set proejection and scale
var projection = dataset.first().projection()
//.aside(print);
var scale = projection.nominalScale()
//.aside(print);

var mosaic = dataset.mosaic().setDefaultProjection({crs:projection, scale:scale});
Map.addLayer(mosaic.select(0).clip(geometry), gediVis, 'rh100 metric');


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

Map.addLayer(fills, {palette: palette, max:40}, 'Colored fills rh98');  

  
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
