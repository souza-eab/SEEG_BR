
var age = ee.Image('users/celsohlsj/public/secondary_forest_age_collection6_v4');
var extent = ee.Image('users/celsohlsj/public/secondary_forest_extent_collection6_v4');
var incr = ee.Image('users/celsohlsj/public/secondary_forest_increment_collection6_v4');
var loss = ee.Image('users/celsohlsj/public/secondary_forest_loss_collection6_v4');



// Get color-ramp module
var vis = {
    'min': 0,
    'max': 49,
    'palette': require('users/mapbiomas/modules:Palettes.js').get('classification6')
};

print("bandas Def", i2.bandNames());// regeneration since 1990


// Visualization 

var mapbioDir = 'projects/mapbiomas-workspace/public/collection6/mapbiomas_collection60_integration_v1';
var mapbiomas = ee.Image(mapbioDir)

// View raw Celso Jr et al., 
Map.addLayer(age.select('classification_1989'), vis,"Age");
Map.addLayer(extent.select('classification_1989'), vis,"Extent");
Map.addLayer(incr.select('classification_1989'), vis,"Incremento");
Map.addLayer(loss.select('classification_1989'), vis,"Loss");


Map.addLayer(mapbiomas.select('classification_1989'), vis,"Mapbiomas");
Map.addLayer(i2.select('classification_2017'), vis,"MB_Celso");
Map.addLayer(image, vis,"MB+Felps");


