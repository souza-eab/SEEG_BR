/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////// GOALS: TO CREATE A MASK OF DEFORESTATION FROM A MAPBIOMAS COLLECTION (eg. col 6.0) /////////////////////////////////
//////////  Created by: Felipe Lenti, Barbara Zimbres /////////////////////////////////////////////////////////////////////////
//////////  Developed by: IPAM, SEEG and Climate Observatory /////////////////////////////////////////////////////////////////
/////////   Processing time <2h> in Google Earth Engine /////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// @. UPDATE HISTORIC EXECUTABLE//
// 1: SCRIPT TO GENERATE DEFORESTATION MASKS FROM A COLLECTION OF MAPBIOMAS (eg. col 6.0)
// 1.1: Access the assets from the MapBiomas collection and Biomes of Brazil
// 1.2: Reclassify layers from Mapbiomas 
// 1.3: Temporal filter
// 1.4: Apply the temporal rules adapted to the first two and last two years of the time series
// 1.5: Export the data
// @. ~~~~~~~~~~~~~~ // 

/* @. Set user parameters */// eg.
var dir_output = 'projects/ee-seeg-brazil/assets/collection_9/v1/mapbiomas';

// Load Asset
// Load asset Biomes of Brazil
var Biomes = ee.FeatureCollection("projects/ee-seeg-brazil/assets/collection_9/v1/Biomes_BR"); 

// Load ImageCollection from Mapbiomas 6.0 
var MapBiomas_col6 = ee.Image("projects/mapbiomas-workspace/public/collection6/mapbiomas_collection60_deforestation_regeneration_v1");

print(MapBiomas_col6);

// Reclassify native vegetation classes to 0 and anthropic classes to 1 for the base year of 1985 (classify what does not apply to 9)
var col6antrop85 = MapBiomas_col6.select('classification_1985').remap(
                  [3,4,5,9,11,12,13,15,20,21,23,24,25,29,30,31,32,33,39,40,41,46,47,48,49],
                  [0,0,0,1, 0, 0, 0, 1, 1, 1, 9, 1, 1, 9, 1, 1, 9, 9, 1, 1, 1, 1, 1, 1, 0]);

// Changing band names
col6antrop85 = col6antrop85.select([0],['deforestation1985']).int8();

// List years
var years = ['1985','1986','1987','1988','1989','1990','1991','1992','1993','1994','1995','1996','1997','1998','1999','2000','2001','2002','2003','2004','2005','2006','2007','2008','2009','2010','2011','2012','2013','2014','2015','2016','2017','2018','2019','2020'];

// Reclassify all other years 
for (var i_year=0;i_year<years.length; i_year++){
  var year = years[i_year];

  var col6uso = MapBiomas_col6.select('classification_'+year).remap(
                  [3,4,5,9,11,12,13,15,20,21,23,24,25,29,30,31,32,33,39,40,41,46,47,48,49],
                  [0,0,0,1, 0, 0, 0, 1, 1, 1, 9, 1, 1, 9, 1, 1, 9, 9, 1, 1, 1, 1, 1, 1, 0]);
                    
  col6antrop85 = col6antrop85.addBands(col6uso.select([0],['deforestation'+year])).int8();
}

// Generate a function that applies the general rule of the temporal filter (3 years before and 2 years after the transition)
var geraMask3_3 = function(year){
  var mask =  col6antrop85.select('deforestation'+(year - 3)).eq(0)
              .and(col6antrop85.select('deforestation'+(year - 2)).eq(0))
              .and(col6antrop85.select('deforestation'+(year - 1)).eq(0))
              .and(col6antrop85.select('deforestation'+(year    )).eq(1))
              .and(col6antrop85.select('deforestation'+(year + 1)).eq(1))
              .and(col6antrop85.select('deforestation'+(year + 2)).eq(1));
  mask = mask.mask(mask.eq(1));
  return mask;
};

// Apply rules adapted to the first two (1986 and 1987) and last two years (2019 and 2020) of the time series
var imageZero = ee.Image(0);
var mask86 =  col6antrop85.select('deforestation'+(1986 - 1)).eq(0)
              .and(col6antrop85.select('deforestation'+(1986    )).eq(1))
              .and(col6antrop85.select('deforestation'+(1986 + 1)).eq(1))
              .and(col6antrop85.select('deforestation'+(1986 + 2)).eq(1))
              .and(col6antrop85.select('deforestation'+(1986 + 3)).eq(1))
              .and(col6antrop85.select('deforestation'+(1986 + 4)).eq(1))
              .and(col6antrop85.select('deforestation'+(1986 + 5)).eq(1))
              .and(col6antrop85.select('deforestation'+(1986 + 6)).eq(1))
              .and(col6antrop85.select('deforestation'+(1986 + 7)).eq(1))
              .and(col6antrop85.select('deforestation'+(1986 + 8)).eq(1));
              
  mask86 = mask86.mask(mask86.eq(1));
  mask86 = mask86.unmask(imageZero);  
  mask86 = mask86.updateMask(mask86.neq(0));
  mask86 = mask86.select([0], ['deforestation1986']);

  var mask87 =  col6antrop85.select('deforestation'+(1987 - 2)).eq(0)
              .and(col6antrop85.select('deforestation'+(1987 - 1)).eq(0))
              .and(col6antrop85.select('deforestation'+(1987    )).eq(1))
              .and(col6antrop85.select('deforestation'+(1987 + 1)).eq(1))
              .and(col6antrop85.select('deforestation'+(1987 + 2)).eq(1))
              .and(col6antrop85.select('deforestation'+(1987 + 3)).eq(1))
              .and(col6antrop85.select('deforestation'+(1987 + 4)).eq(1));
              
  mask87 = mask87.mask(mask87.eq(1));
  mask87 = mask87.unmask(imageZero);  
  mask87 = mask87.updateMask(mask87.neq(0));
  mask87 = mask87.select([0], ['deforestation1987']);
  
  
  var mask19 =  col6antrop85.select('deforestation'+(2019 - 6)).eq(0)
            .and(col6antrop85.select('deforestation'+(2019 - 5)).eq(0))
            .and(col6antrop85.select('deforestation'+(2019 - 4)).eq(0))
            .and(col6antrop85.select('deforestation'+(2019 - 3)).eq(0))
            .and(col6antrop85.select('deforestation'+(2019 - 2)).eq(0))
            .and(col6antrop85.select('deforestation'+(2019 - 1)).eq(0))
            .and(col6antrop85.select('deforestation'+(2019    )).eq(1))
            .and(col6antrop85.select('deforestation'+(2019 + 1)).eq(1));
              
  mask19 = mask19.mask(mask19.eq(1));
  mask19 = mask19.unmask(imageZero);  
  mask19 = mask19.updateMask(mask19.neq(0));
  mask19 = mask19.select([0], ['deforestation2019']);
  
  var mask20 =  col6antrop85.select('deforestation'+(2020 - 8)).eq(0)
            .and(col6antrop85.select('deforestation'+(2020 - 7)).eq(0))
            .and(col6antrop85.select('deforestation'+(2020 - 6)).eq(0))
            .and(col6antrop85.select('deforestation'+(2020 - 5)).eq(0))
            .and(col6antrop85.select('deforestation'+(2020 - 4)).eq(0))
            .and(col6antrop85.select('deforestation'+(2020 - 3)).eq(0))
            .and(col6antrop85.select('deforestation'+(2020 - 2)).eq(0))             
            .and(col6antrop85.select('deforestation'+(2020 - 1)).eq(0))
            .and(col6antrop85.select('deforestation'+(2020    )).eq(1));
            
  mask20 = mask20.mask(mask20.eq(1));
  mask20 = mask20.unmask(imageZero);  
  mask20 = mask20.updateMask(mask20.neq(0));
  mask20 = mask20.select([0], ['deforestation2020']);

// Sum the bands of the first two years
var deforestation = mask86.addBands(mask87);

// Create a first-year rule band
var deforestation88 = geraMask3_3(1988);
deforestation88 = deforestation88.unmask(imageZero);  
deforestation88 = deforestation88.updateMask(deforestation88.neq(0));
deforestation88 = deforestation88.select(['deforestation1985'],['deforestation1988']);

// Adds bands 
deforestation = deforestation.addBands(deforestation88);

// Generate the bands by applying the filter for all other years of the general rule (in this case, until 2019)
for (var i = 1989; i < 2019; i++) {
   var deforestation_general = geraMask3_3(i);
      deforestation_general = deforestation_general.unmask(imageZero);
      deforestation_general = deforestation_general.updateMask(deforestation_general.neq(0));
  deforestation = deforestation.addBands(deforestation_general.select([0],['deforestation'+ i]));
}

// Adds the last two years
deforestation = deforestation.addBands(mask19).addBands(mask20);
print(deforestation);


// Get color-ramp module
var vis = {
    'min': 0,
    'max': 49,
    'palette': require('users/mapbiomas/modules:Palettes.js').get('classification6')
};


// Visualization 
Map.addLayer(deforestation.select('deforestation2013'), {'min': 0,'max': 1, 'palette': 'red'},"Desm_2013");
Map.addLayer(deforestation.select('deforestation2020'), {'min': 0,'max': 1, 'palette': 'red'},"Desm_2020");
Map.addLayer(MapBiomas_col6.select('classification_2020'), vis,"Mapbiomas_2020");
Map.addLayer(MapBiomas_col6.select('classification_2013'), vis,"Mapbiomas_2013"); 

// Exporting data
Export.image.toAsset({
    "image": deforestation.unmask(0).uint8(),
    "description": '1_0_Deforestation_masks',
    "assetId":dir_output + '1_0_Deforestation_masks', // Enter the address and name eg.' projects/ee-seeg-brazil/assets/collection_9/v1/' of the Asset to be exported
    "scale": 30,
    "pyramidingPolicy": {
        '.default': 'mode'
    },
    "maxPixels": 1e13,
    "region": Biomes.geometry().bounds() // If desired, change here to the name of the desired region in Brazil
});



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////// GOALS: TO CREATE A MASK OF REGENERATION FROM A MAPBIOMAS COLLECTION (eg. col 6.0) //////////////////////////////////
//////////  Created by: Felipe Lenti, Barbara Zimbres /////////////////////////////////////////////////////////////////////////
//////////  Developed by: IPAM, SEEG and Climate Observatory /////////////////////////////////////////////////////////////////
/////////   Processing time <2h> in Google Earth Engine /////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// @. UPDATE HISTORIC EXECUTABLE//
// 1: SCRIPT TO GENERATE REGENERATION MASKS FROM A COLLECTION OF MAPBIOMAS (eg. col 6.0)
// 1.1: Accessing the assets from the MapBiomas collection and Biomes of Brazil
// 1.2: Reclassifying layers from Mapbiomas 
// 1.3: Temporal filter
// 1.4: Applying the temporal rules adapted to the first two and last two years of the time series
// 1.5: Exporting the data
// @. ~~~~~~~~~~~~~~ // 

/* @. Set user parameters */// eg.

// Set directory for the output file
var dir_output = 'projects/ee-seeg-brazil/assets/collection_9/v1/';

// Load assets
// Load asset Biomes of Brazil
var Biomes = ee.FeatureCollection("projects/ee-seeg-brazil/assets/collection_9/v1/Biomes_BR"); 

//  Load ImageCollection from Mapbiomas 6.0 
var MapBiomas_col6 = ee.Image("projects/mapbiomas-workspace/public/collection6/mapbiomas_collection60_integration_v1");

// Reclassify native vegetation classes to 0 and anthropic classes to 1 for the base year of 1985 (classify what does not apply to 9)
var col6forest85 = MapBiomas_col6.select('classification_1985').remap(
                  [3,4,5,9,11,12,13,15,20,21,23,24,25,29,30,31,32,33,39,40,41,46,47,48,49],
                  [1,1,1,0, 1, 1, 1, 0, 0, 0, 9, 0, 0, 9, 0, 0, 9, 9, 0, 0, 0, 0, 0, 0, 1]);

// Changing band names
col6forest85 = col6forest85.select([0],['regeneration1985']).int8();

// List years
var years = ['1985','1986','1987','1988','1989','1990','1991','1992','1993','1994','1995','1996','1997','1998','1999','2000','2001','2002','2003','2004','2005','2006','2007','2008','2009','2010','2011','2012','2013','2014','2015','2016','2017','2018','2019','2020'];

// Reclassify all other years 
for (var i_year=0;i_year<years.length; i_year++){ 
  var year = years[i_year];

  var col6flor = MapBiomas_col6.select('classification_'+year).remap(
                  [3,4,5,9,11,12,13,15,20,21,23,24,25,29,30,31,32,33,39,40,41,46,47,48,49],
                  [1,1,1,0, 1, 1, 1, 0, 0, 0, 9, 0, 0, 9, 0, 0, 9, 9, 0, 0, 0, 0, 0, 0, 1]);
                    
  col6forest85 = col6forest85.addBands(col6flor.select([0],['regeneration'+year])).int8();
}

// Generate a function that applies the general rule of the temporal filter (3 years before and 2 years after the transition)
var geraMask3_3 = function(year){
  var mask =  col6forest85.select('regeneration'+(year - 3)).eq(0)
              .and(col6forest85.select('regeneration'+(year - 2)).eq(0))
              .and(col6forest85.select('regeneration'+(year - 1)).eq(0))
              .and(col6forest85.select('regeneration'+(year    )).eq(1))
              .and(col6forest85.select('regeneration'+(year + 1)).eq(1))
              .and(col6forest85.select('regeneration'+(year + 2)).eq(1));
  mask = mask.mask(mask.eq(1));
  return mask;
};

// Apply rules adapted to the first two (1986 and 1987) and last two years (2019 and 2020) of the time series
var imageZero = ee.Image(0);
  var mask86 =  col6forest85.select('regeneration'+(1986 - 1)).eq(0)
              .and(col6forest85.select('regeneration'+(1986    )).eq(1))
              .and(col6forest85.select('regeneration'+(1986 + 1)).eq(1))
              .and(col6forest85.select('regeneration'+(1986 + 2)).eq(1))
              .and(col6forest85.select('regeneration'+(1986 + 3)).eq(1))
              .and(col6forest85.select('regeneration'+(1986 + 4)).eq(1))
              .and(col6forest85.select('regeneration'+(1986 + 5)).eq(1))
              .and(col6forest85.select('regeneration'+(1986 + 6)).eq(1))
              .and(col6forest85.select('regeneration'+(1986 + 7)).eq(1))
              .and(col6forest85.select('regeneration'+(1986 + 8)).eq(1));
              
  mask86 = mask86.mask(mask86.eq(1));
  mask86 = mask86.unmask(imageZero);  
  mask86 = mask86.updateMask(mask86.neq(0));
  mask86 = mask86.select([0], ['regeneration1986']);

  var mask87 =  col6forest85.select('regeneration'+(1987 - 2)).eq(0)
              .and(col6forest85.select('regeneration'+(1987 - 1)).eq(0))
              .and(col6forest85.select('regeneration'+(1987    )).eq(1))
              .and(col6forest85.select('regeneration'+(1987 + 1)).eq(1))
              .and(col6forest85.select('regeneration'+(1987 + 2)).eq(1))
              .and(col6forest85.select('regeneration'+(1987 + 3)).eq(1))
              .and(col6forest85.select('regeneration'+(1987 + 4)).eq(1));

  mask87 = mask87.mask(mask87.eq(1));
  mask87 = mask87.unmask(imageZero);  
  mask87 = mask87.updateMask(mask87.neq(0));
  mask87 = mask87.select([0], ['regeneration1987']);
  
  
  var mask19 =  col6forest85.select('regeneration'+(2019 - 6)).eq(0)
            .and(col6forest85.select('regeneration'+(2019 - 5)).eq(0))
            .and(col6forest85.select('regeneration'+(2019 - 4)).eq(0))
            .and(col6forest85.select('regeneration'+(2019 - 3)).eq(0))
            .and(col6forest85.select('regeneration'+(2019 - 2)).eq(0))
            .and(col6forest85.select('regeneration'+(2019 - 1)).eq(0))
            .and(col6forest85.select('regeneration'+(2019    )).eq(1))
            .and(col6forest85.select('regeneration'+(2019 + 1)).eq(1));
              
  mask19 = mask19.mask(mask19.eq(1));
  mask19 = mask19.unmask(imageZero);  
  mask19 = mask19.updateMask(mask19.neq(0));
  mask19 = mask19.select([0], ['regeneration2019']);
  
  var mask20 =  col6forest85.select('regeneration'+(2020 - 8)).eq(0)
            .and(col6forest85.select('regeneration'+(2020 - 7)).eq(0))
            .and(col6forest85.select('regeneration'+(2020 - 6)).eq(0))
            .and(col6forest85.select('regeneration'+(2020 - 5)).eq(0))
            .and(col6forest85.select('regeneration'+(2020 - 4)).eq(0))
            .and(col6forest85.select('regeneration'+(2020 - 3)).eq(0))
            .and(col6forest85.select('regeneration'+(2020 - 2)).eq(0))             
            .and(col6forest85.select('regeneration'+(2020 - 1)).eq(0))
            .and(col6forest85.select('regeneration'+(2020    )).eq(1));
              
  mask20 = mask20.mask(mask20.eq(1));
  mask20 = mask20.unmask(imageZero);  
  mask20 = mask20.updateMask(mask20.neq(0));
  mask20 = mask20.select([0], ['regeneration2020']);

// Sum the bands of the first two years
var regeneration = mask86.addBands(mask87);

// Create a first-year rule band
var regeneration88 = geraMask3_3(1988);
regeneration88 = regeneration88.unmask(imageZero);  
regeneration88 = regeneration88.updateMask(regeneration88.neq(0));
regeneration88 = regeneration88.select(['regeneration1985'],['regeneration1988']);

// Adds bands
regeneration = regeneration.addBands(regeneration88);

// Generate the bands by applying the filter for all other years of the general rule (in this case, until 2019)
for (var i = 1989; i < 2019; i++) {
   var regeneration_general = geraMask3_3(i);
      regeneration_general = regeneration_general.unmask(imageZero);
      regeneration_general = regeneration_general.updateMask(regeneration_general.neq(0));
  regeneration = regeneration.addBands(regeneration_general.select([0],['regeneration'+ i]));
}

//// Adds the last two years
regeneration = regeneration.addBands(mask19).addBands(mask20);
print(regeneration);

// Visualization
Map.addLayer(regeneration.select('regeneration2013'), {'min': 0,'max': 1, 'palette': 'blue'},'Regeneration_2013');
Map.addLayer(regeneration.select('regeneration2020'), {'min': 0,'max': 1, 'palette': 'blue'},'Regeneration_2020');

Export.image.toAsset({
    "image": regeneration.unmask(0).uint8(),
    "description": '1_0_Regeneration_masks',
    "assetId": dir_output + '1_0_Regeneration_masks', // Enter the address and name eg. ' projects/ee-seeg-brazil/assets/collection_9/v1/' of the Asset to be exported
    "scale": 30,
    "pyramidingPolicy": {
        '.default': 'mode'
    },
    "maxPixels": 1e13,
    "region": Biomes.geometry().bounds() // If desired, change here to the name of the desired region in Brazil
});
