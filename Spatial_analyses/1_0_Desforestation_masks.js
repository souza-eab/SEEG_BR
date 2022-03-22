////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////// GOALS: RECLASSIFICATION TO GENERATE DESFORESTATION MASKS FROM A COLLECTION OF MAPBIOMAS (eg. col 6.0) //////////////
//////////  Coordination: Barbara Zimbres, Julia Shimbo, and Ane Alencar /////////////////////////////////////////////////////
//////////  Developed by: IPAM, SEEG and Climate Observatory ////////////////////////////////////////////////////////////////
////////// Citing: Zimbres et al.,2022.  ///////////////////////////////////////////////////////////////////////////////////
/////////  Processing time <2h> in Google Earth Engine ////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// @. UPDATE HISTORIC //
// 1: SCRIPT TO GENERATE DEFORESTATION MASKS FROM A COLLECTION OF MAPBIOMAS (eg. col 6.0)
// 1.1: Acess Asset MapBiomas and Biomes BRAZIL
// 1.1: Remap layer col. 6.0 Mapiomas 
// @. ~~~~~~~~~~~~~~ // 

/* @. Set user parameters */// eg.
var dir_output = 'projects/mapbiomas-workspace/SEEG/2021/Col9/';

// Set Asset
// Asset Biomes brazilian
var Bioma = ee.FeatureCollection("users/SEEGMapBiomas/bioma_1milhao_uf2015_250mil_IBGE_geo_v4_revisao_pampa_lagoas"); 

// Add ImageCollection Mapbiomas 6.0
var colecao6 = ee.ImageCollection("projects/mapbiomas-workspace/COLECAO6/mapbiomas-collection60-integration-v0-12").mosaic();

//Remap layers for native vegetation in 1985 to 1; what is anthropic, is 0; and what does not apply, is 9
var col6antrop85 = colecao6.select('classification_1985').remap(
                  [3,4,5,9,11,12,13,15,20,21,23,24,25,29,30,31,32,33,39,40,41,46,47,48,49],
                  [0,0,0,1, 0, 0, 0, 1, 1, 1, 9, 1, 1, 9, 1, 1, 9, 9, 1, 1, 1, 1, 1, 1, 0]);

//Changing names of bands 
col6antrop85 = col6antrop85.select([0],['desmat1985']).int8();

// List years
var anos = ['1985','1986','1987','1988','1989','1990','1991','1992','1993','1994','1995','1996','1997','1998','1999','2000','2001','2002','2003','2004','2005','2006','2007','2008','2009','2010','2011','2012','2013','2014','2015','2016','2017','2018','2019','2020'];

// Complete doing the same thing for the other years 
for (var i_ano=0;i_ano<anos.length; i_ano++){
  var ano = anos[i_ano];

  var col6uso = colecao6.select('classification_'+ano).remap(
                  [3,4,5,9,11,12,13,15,20,21,23,24,25,29,30,31,32,33,39,40,41,46,47,48,49],
                  [0,0,0,1, 0, 0, 0, 1, 1, 1, 9, 1, 1, 9, 1, 1, 9, 9, 1, 1, 1, 1, 1, 1, 0]);
                    
  col6antrop85 = col6antrop85.addBands(col6uso.select([0],['desm'+ano])).int8();
}

// Generate the function that applies the general rule of time filter (3 years before and 2 years after the transition)
var geraMask3_3 = function(ano){
  var mask =  col6antrop85.select('desm'+(ano - 3)).eq(0)
              .and(col6antrop85.select('desm'+(ano - 2)).eq(0))
              .and(col6antrop85.select('desm'+(ano - 1)).eq(0))
              .and(col6antrop85.select('desm'+(ano    )).eq(1))
              .and(col6antrop85.select('desm'+(ano + 1)).eq(1))
              .and(col6antrop85.select('desm'+(ano + 2)).eq(1));
  mask = mask.mask(mask.eq(1));
  return mask;
};

// Applies the rule exceptions in the first two (1986 and 1987) and last two years (2019 and 2020) of the time series
var imageZero = ee.Image(0);
var mask86 =  col6antrop85.select('desm'+(1986 - 1)).eq(0)
              .and(col6antrop85.select('desm'+(1986    )).eq(1))
              .and(col6antrop85.select('desm'+(1986 + 1)).eq(1))
              .and(col6antrop85.select('desm'+(1986 + 2)).eq(1))
              .and(col6antrop85.select('desm'+(1986 + 3)).eq(1))
              .and(col6antrop85.select('desm'+(1986 + 4)).eq(1))
              .and(col6antrop85.select('desm'+(1986 + 5)).eq(1))
              .and(col6antrop85.select('desm'+(1986 + 6)).eq(1))
              .and(col6antrop85.select('desm'+(1986 + 7)).eq(1))
              .and(col6antrop85.select('desm'+(1986 + 8)).eq(1));
              
  mask86 = mask86.mask(mask86.eq(1));
  mask86 = mask86.unmask(imageZero);  
  mask86 = mask86.updateMask(mask86.neq(0));
  mask86 = mask86.select([0], ['desm1986']);

  var mask87 =  col6antrop85.select('desm'+(1987 - 2)).eq(0)
              .and(col6antrop85.select('desm'+(1987 - 1)).eq(0))
              .and(col6antrop85.select('desm'+(1987    )).eq(1))
              .and(col6antrop85.select('desm'+(1987 + 1)).eq(1))
              .and(col6antrop85.select('desm'+(1987 + 2)).eq(1))
              .and(col6antrop85.select('desm'+(1987 + 3)).eq(1))
              .and(col6antrop85.select('desm'+(1987 + 4)).eq(1));
              
  mask87 = mask87.mask(mask87.eq(1));
  mask87 = mask87.unmask(imageZero);  
  mask87 = mask87.updateMask(mask87.neq(0));
  mask87 = mask87.select([0], ['desm1987']);
  
  
  var mask19 =  col6antrop85.select('desm'+(2019 - 6)).eq(0)
            .and(col6antrop85.select('desm'+(2019 - 5)).eq(0))
            .and(col6antrop85.select('desm'+(2019 - 4)).eq(0))
            .and(col6antrop85.select('desm'+(2019 - 3)).eq(0))
            .and(col6antrop85.select('desm'+(2019 - 2)).eq(0))
            .and(col6antrop85.select('desm'+(2019 - 1)).eq(0))
            .and(col6antrop85.select('desm'+(2019    )).eq(1))
            .and(col6antrop85.select('desm'+(2019 + 1)).eq(1));
              
  mask19 = mask19.mask(mask19.eq(1));
  mask19 = mask19.unmask(imageZero);  
  mask19 = mask19.updateMask(mask19.neq(0));
  mask19 = mask19.select([0], ['desm2019']);
  
  var mask20 =  col6antrop85.select('desm'+(2020 - 8)).eq(0)
            .and(col6antrop85.select('desm'+(2020 - 7)).eq(0))
            .and(col6antrop85.select('desm'+(2020 - 6)).eq(0))
            .and(col6antrop85.select('desm'+(2020 - 5)).eq(0))
            .and(col6antrop85.select('desm'+(2020 - 4)).eq(0))
            .and(col6antrop85.select('desm'+(2020 - 3)).eq(0))
            .and(col6antrop85.select('desm'+(2020 - 2)).eq(0))             
            .and(col6antrop85.select('desm'+(2020 - 1)).eq(0))
            .and(col6antrop85.select('desm'+(2020    )).eq(1));
            
  mask20 = mask20.mask(mask20.eq(1));
  mask20 = mask20.unmask(imageZero);  
  mask20 = mask20.updateMask(mask20.neq(0));
  mask20 = mask20.select([0], ['desm2020']);

// Sum the bands of the first two years
var desm = mask86.addBands(mask87);

// Create a first-year rule band
var desm88 = geraMask3_3(1988);
desm88 = desm88.unmask(imageZero);  
desm88 = desm88.updateMask(desm88.neq(0));
desm88 = desm88.select(['desm1985'],['desm1988']);

// Adds Bands 
desm = desm.addBands(desm88);

// Generate the bands by applying the filter for all other years of the general rule (in this case, until 2019)
for (var i = 1989; i < 2019; i++) {
   var desm_geral = geraMask3_3(i);
      desm_geral = desm_geral.unmask(imageZero);
      desm_geral = desm_geral.updateMask(desm_geral.neq(0));
  desm = desm.addBands(desm_geral.select([0],['desm'+ i]));
}

// Adds the last two years
desm = desm.addBands(mask19).addBands(mask20);
print(desm);

// View eg. 
Map.addLayer(desm.select('desm2019'), {'min': 0,'max': 1, 'palette': 'red'},"Desm_2019");
Map.addLayer(desm.select('desm2020'), {'min': 0,'max': 1, 'palette': 'red'},"Desm_2020");

// Exporting data
Export.image.toAsset({
    "image": desm.unmask(0).uint8(),
    "description": 'desmSEEGc6',
    "assetId":dir_output + 'desmSEEGc6', // Enter the address and name 'project/seeg/col9/v1'of the Asset to be exported
    "scale": 30,
    "pyramidingPolicy": {
        '.default': 'mode'
    },
    "maxPixels": 1e13,
    "region": Bioma.geometry().bounds() // If desired, change here to the name of the desired region
});
