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


// GT*100 + classe original do MapBiomas,
/* @. Set user parameters */// eg.
var dir_output = 'projects/mapbiomas-workspace/SEEG/2022/';

// Load Asset
// Load asset Biomes of Brazil
var Biomes = ee.FeatureCollection("projects/ee-seeg-brazil/assets/collection_9/v1/Biomes_BR"); 

var vis1 = {min: 0, max: 49, palette: ['#21653e', '#fc0a12']};

// Load ImageCollection from Mapbiomas 6.0 (deforestation_regeneration_v1)
var MapBiomas_col6 = ee.Image("projects/mapbiomas-workspace/public/collection6/mapbiomas_collection60_deforestation_regeneration_v1");
print(MapBiomas_col6);
Map.addLayer(MapBiomas_col6,{},'AA',true);

var MapBiomas_col16 = ee.Image(MapBiomas_col6.divide(100).round());

Map.addLayer(MapBiomas_col16, {},'AB',true);
print(MapBiomas_col16.visualize({
//	bands:null,
//	gain:null,
//	bias:null,
//	min:null,
//	max:null,
//	gamma:null,
//	opacity:null,
//	palette:null,
//	forceRgbOutput:false,
}))

// Reclassify native vegetation classes to 0 and anthropic classes to 1 for the base year of 1985 (classify what does not apply to 9)
var col6forest87 = MapBiomas_col16.select('classification_1987').remap(
                  [1,2,3,4,5,6,7],
                  [0,0,0,0,1,0,0]);

// Changing band names
col6forest87 = col6forest87.select([0],['regeneration1987']).int8();
var Viz = {min: 0.5, max: 1, palette:['ffffff', '1eff10']};
Map.addLayer(col6forest87, Viz,'Teste_Pixel_ID=5',true);

// List years
var years = ['1987','1988','1989','1990','1991','1992','1993','1994','1995','1996','1997','1998','1999','2000','2001','2002','2003','2004','2005','2006','2007','2008','2009','2010','2011','2012','2013','2014','2015','2016','2017','2018','2019'];

// Reclassify all other years 
for (var i_year=0;i_year<years.length; i_year++){ 
  var year = years[i_year];

  var col6flor = MapBiomas_col16.select('classification_'+year).remap(
                  [1,2,3,4,5,6,7],
                  [0,0,0,0,1,0,0]);
                    
  col6forest87 = col6forest87.addBands(col6flor.select([0],['regeneration'+year])).int8();
}

// Generate a function that applies the general rule of the temporal filter (3 years before and 2 years after the transition)
var geraMask3_3 = function(year){
  var mask =  col6forest87.select('regeneration'+(year - 3)).eq(0)
              .and(col6forest87.select('regeneration'+(year - 2)).eq(0))
              .and(col6forest87.select('regeneration'+(year - 1)).eq(0))
              .and(col6forest87.select('regeneration'+(year    )).eq(1))
              .and(col6forest87.select('regeneration'+(year + 1)).eq(1))
              .and(col6forest87.select('regeneration'+(year + 2)).eq(1));
  mask = mask.mask(mask.eq(1));
  return mask;
};

// Apply rules adapted to the first two (1986 and 1987) and last two years (2019 and 2020) of the time series
var imageZero = ee.Image(0);
  var mask88 =  col6forest87.select('regeneration'+(1988 - 1)).eq(0)
              .and(col6forest87.select('regeneration'+(1988    )).eq(1))
              .and(col6forest87.select('regeneration'+(1988 + 1)).eq(1))
              .and(col6forest87.select('regeneration'+(1988 + 2)).eq(1))
              .and(col6forest87.select('regeneration'+(1988 + 3)).eq(1))
              .and(col6forest87.select('regeneration'+(1988 + 4)).eq(1))
              .and(col6forest87.select('regeneration'+(1988 + 5)).eq(1))
              .and(col6forest87.select('regeneration'+(1988 + 6)).eq(1))
              .and(col6forest87.select('regeneration'+(1988 + 7)).eq(1))
              .and(col6forest87.select('regeneration'+(1988 + 8)).eq(1));
              
  mask88 = mask88.mask(mask88.eq(1));
  mask88 = mask88.unmask(imageZero);  
  mask88 = mask88.updateMask(mask88.neq(0));
  mask88 = mask88.select([0], ['regeneration1988']);

  var mask89 =  col6forest87.select('regeneration'+(1989 - 2)).eq(0)
              .and(col6forest87.select('regeneration'+(1989 - 1)).eq(0))
              .and(col6forest87.select('regeneration'+(1989    )).eq(1))
              .and(col6forest87.select('regeneration'+(1989 + 1)).eq(1))
              .and(col6forest87.select('regeneration'+(1989 + 2)).eq(1))
              .and(col6forest87.select('regeneration'+(1989 + 3)).eq(1))
              .and(col6forest87.select('regeneration'+(1989 + 4)).eq(1));

  mask89 = mask89.mask(mask89.eq(1));
  mask89 = mask89.unmask(imageZero);  
  mask89 = mask89.updateMask(mask89.neq(0));
  mask89 = mask89.select([0], ['regeneration1989']);
  
  
  var mask18 =  col6forest87.select('regeneration'+(2018 - 6)).eq(0)
            .and(col6forest87.select('regeneration'+(2018 - 5)).eq(0))
            .and(col6forest87.select('regeneration'+(2018 - 4)).eq(0))
            .and(col6forest87.select('regeneration'+(2018 - 3)).eq(0))
            .and(col6forest87.select('regeneration'+(2018 - 2)).eq(0))
            .and(col6forest87.select('regeneration'+(2018 - 1)).eq(0))
            .and(col6forest87.select('regeneration'+(2018    )).eq(1))
            .and(col6forest87.select('regeneration'+(2018 + 1)).eq(1));
              
  mask18 = mask18.mask(mask18.eq(1));
  mask18 = mask18.unmask(imageZero);  
  mask18 = mask18.updateMask(mask18.neq(0));
  mask18 = mask18.select([0], ['regeneration2018']);
  
  var mask19 =  col6forest87.select('regeneration'+(2019 - 8)).eq(0)
            .and(col6forest87.select('regeneration'+(2019 - 7)).eq(0))
            .and(col6forest87.select('regeneration'+(2019 - 6)).eq(0))
            .and(col6forest87.select('regeneration'+(2019 - 5)).eq(0))
            .and(col6forest87.select('regeneration'+(2019 - 4)).eq(0))
            .and(col6forest87.select('regeneration'+(2019 - 3)).eq(0))
            .and(col6forest87.select('regeneration'+(2019 - 2)).eq(0))             
            .and(col6forest87.select('regeneration'+(2019 - 1)).eq(0))
            .and(col6forest87.select('regeneration'+(2019    )).eq(1));
              
  mask19 = mask19.mask(mask19.eq(1));
  mask19 = mask19.unmask(imageZero);  
  mask19 = mask19.updateMask(mask19.neq(0));
  mask19 = mask19.select([0], ['regeneration2019']);

// Sum the bands of the first two years
var regeneration = mask88.addBands(mask89);

// Create a first-year rule band
var regeneration90 = geraMask3_3(1990);
regeneration90 = regeneration90.unmask(imageZero);  
regeneration90 = regeneration90.updateMask(regeneration90.neq(0));
regeneration90 = regeneration90.select(['regeneration1990'],['regeneration1990']);

// Adds bands
regeneration = regeneration.addBands(regeneration90);

// Generate the bands by applying the filter for all other years of the general rule (in this case, until 2019)
for (var i = 1989; i < 2019; i++) {
   var regeneration_general = geraMask3_3(i);
      regeneration_general = regeneration_general.unmask(imageZero);
      regeneration_general = regeneration_general.updateMask(regeneration_general.neq(0));
  regeneration = regeneration.addBands(regeneration_general.select([0],['regeneration'+ i]));
}

//// Adds the last two years
regeneration = regeneration.addBands(mask18).addBands(mask19);
print(regeneration);

// Visualization
Map.addLayer(regeneration.select('regeneration_2013'), {'min': 0,'max': 1, 'palette': 'blue'},'Regeneration_2013');
Map.addLayer(regeneration.select('regeneration_2019'), {'min': 0,'max': 1, 'palette': 'blue'},'Regeneration_2019');

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
// Table (https://mapbiomas.org/metodo-desmatamento)
// 2 Veg. Primária Indica ausência de evento de Desmatamento: permanência desde o ano-base em uma ou mais classes de Vegetação Nativa ou transição para classe de Uso Antrópico com permanência nesta classe por período inferior ao estabelecido (item 2.)
// 4 Supressão de Veg. Primária: Indica evento de Desmatamento, em um dado ano t, em pixel alocado anteriormente na classe Vegetação Primária, após o qual o pixel é alocado na classe Antrópico (em t+1).
// 5 Recuperação para Veg. Secundária: Indica evento de Regeneração em um dado ano t, após o qual o pixel é alocado na classe Vegetação Secundária (em t+1).
// 3 Veg. Secundária: Indica trajetória com presença de evento de Recuperação para Vegetação Secundária em anos anteriores.
// 6 Supressão de Veg. Secundária: Indica evento de Desmatamento, em um dado ano t, em pixel alocado anteriormente na classe Veg. Secundária, após o qual o pixel é alocado na classe Antrópico (em t+1).
// 1 Antrópico: Indica permanência em alguma classe de Uso Antrópico desde o ano-base ou trajetórias com evento de Supressão de Veg. Primária ou evento de Veg. Secundária em anos anteriores.



