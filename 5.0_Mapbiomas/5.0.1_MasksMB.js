/* @. Set user parameters */// eg.
// Set directory for the output file
var dir_output = 'projects/mapbiomas-workspace/SEEG/2022/';

// Load Asset from MapBiomas collection 6.0  
var mapbioDir = 'projects/mapbiomas-workspace/public/collection6/mapbiomas_collection60_integration_v1';
var mapbiomas = ee.Image(mapbioDir)

// Feature of the region of interest, in this case, all biomes in Brazil
var assetRegions = "projects/ee-seeg-brazil/assets/collection_9/v1/Biomes_BR";
var regions = ee.FeatureCollection(assetRegions);

// Load the filtered deforestation and regeneration masks
var regenDir = ee.Image('projects/mapbiomas-workspace/public/collection6/mapbiomas_collection60_deforestation_regeneration_v1');

// intervalo de tempo 
var time = ee.List.sequence({'start': 1987, 'end': 2019,  'step': 1});

// criar recipiente 
var recipe = ee.Image([]);

// para cada ano
time.getInfo().forEach(function(year_i) {
  // Load regen
  var img = regenDir.select(['classification_' + year_i]).rename(['regeneration_' + year_i])
  // Rectify class
  img = img.divide(100).round();
  img = img.remap(
                  [1,2,3,4,5,6,7],
                  [0,0,0,0,1,0,0]).rename(['regeneration_' + year_i]);
  // empilha
  recipe = recipe.addBands(img);
});
// resultado
print(recipe);

var regen = recipe;

print("bandas regen", regen.bandNames());// regeneration since 1990

Map.addLayer(regen,{},"RegeneraçãoMB");



////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Load the filtered deforestation and regeneration masks
var DefDir = ee.Image('projects/mapbiomas-workspace/public/collection6/mapbiomas_collection60_deforestation_regeneration_v1');

// intervalo de tempo 
var time = ee.List.sequence({'start': 1987, 'end': 2019,  'step': 1});

// criar recipiente 
var recipe = ee.Image([]);

// para cada ano
time.getInfo().forEach(function(year_i) {
  // Load deforestation
  var img = DefDir.select(['classification_' + year_i]).rename(['deforestation_' + year_i])
  // Rectify class
  img = img.divide(100).round();
  img = img.remap(
                  [1,2,3,4,5,6,7],
                  [0,0,0,1,0,1,0]).rename(['deforestation_' + year_i]);
  // empilha
  recipe = recipe.addBands(img);
});
// resultado
print(recipe);

var Def = recipe;

print("bandas Def", Def.bandNames());// regeneration since 1990

Map.addLayer(Def,{},"DeforestationMB");
