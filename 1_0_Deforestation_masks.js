///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////// SCRIPT TO GENERATE REGENERATION MASKS FROM A COLLECTION OF MAPBIOMAS (eg. col 6.0) /////////////////////////////////////////////////////////
////////////////////////////////// For any issue/bug, please write to <edriano.souza@ipam.org.br>; <dhemerson.costa@ipam.org.br>; <barbara.zimbres@ipam.org.br> ///////////////
////////////////////////////////// Coordination: Barbara Zimbres, Julia Shimbo, and Ane Alencar ///////////////////////////////////////////////////////////////////////////////
////////////////////////////////// Developed by: IPAM, SEEG and OC ////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////// Citing: SEEG/Observatório do Clima and IPAM ////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////// Processing time <2h> in Google Earth Engine ////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// @. UPDATE HISTORIC //
// 1: SCRIPT TO GENERATE REGENERATION MASKS FROM A COLLECTION OF MAPBIOMAS (eg. col 6.0)
// 1.1: Acess Asset MapBiomas and Biomes BRAZIL
// 1.1: Remap layer col. 6.0 Mapiomas 
// @. ~~~~~~~~~~~~~~ // 

/* @. Set user parameters */// eg.
var dir_output = 'projects/mapbiomas-workspace/SEEG/2021/Col9/';

// Set assets
// Asset Biomes Brazil
var Bioma = ee.FeatureCollection("users/SEEGMapBiomas/bioma_1milhao_uf2015_250mil_IBGE_geo_v4_revisao_pampa_lagoas"); 

// Add ImageCollection Mapbiomas 6.0
var colecao6 = ee.ImageCollection("projects/mapbiomas-workspace/COLECAO6/mapbiomas-collection60-integration-v0-12").mosaic();

//Remap layers for native vegetation in 1985 to 1; what is anthropic, is 0; and what does not apply, is 9
var col6floresta85 = colecao6.select('classification_1985').remap(
                  [3,4,5,9,11,12,13,15,20,21,23,24,25,29,30,31,32,33,39,40,41,46,47,48,49],
                  [1,1,1,0, 1, 1, 1, 0, 0, 0, 9, 0, 0, 9, 0, 0, 9, 9, 0, 0, 0, 0, 0, 0, 1]);

// Changing names of bands 
col6floresta85 = col6floresta85.select([0],['regen1985']).int8();

// List years
var anos = ['1985','1986','1987','1988','1989','1990','1991','1992','1993','1994','1995','1996','1997','1998','1999','2000','2001','2002','2003','2004','2005','2006','2007','2008','2009','2010','2011','2012','2013','2014','2015','2016','2017','2018','2019','2020'];

// Complete doing the same thing for the other years
for (var i_ano=0;i_ano<anos.length; i_ano++){ 
  var ano = anos[i_ano];

  var col6flor = colecao6.select('classification_'+ano).remap(
                  [3,4,5,9,11,12,13,15,20,21,23,24,25,29,30,31,32,33,39,40,41,46,47,48,49],
                  [1,1,1,0, 1, 1, 1, 0, 0, 0, 9, 0, 0, 9, 0, 0, 9, 9, 0, 0, 0, 0, 0, 0, 1]);
                    
  col6floresta85 = col6floresta85.addBands(col6flor.select([0],['regen'+ano])).int8();
}

//Gera a função que aplica a regra geral do filtro temporal (3 anos antes e 2 depois da transição)
var geraMask3_3 = function(ano){
  var mask =  col6floresta85.select('regen'+(ano - 3)).eq(0)
              .and(col6floresta85.select('regen'+(ano - 2)).eq(0))
              .and(col6floresta85.select('regen'+(ano - 1)).eq(0))
              .and(col6floresta85.select('regen'+(ano    )).eq(1))
              .and(col6floresta85.select('regen'+(ano + 1)).eq(1))
              .and(col6floresta85.select('regen'+(ano + 2)).eq(1));
  mask = mask.mask(mask.eq(1));
  return mask;
};

//Aplica as exceções das regras nos dois primeiros (1986 e 1987) e dois últimos anos (2019 e 2020) da série temporal
var imageZero = ee.Image(0);
  var mask86 =  col6floresta85.select('regen'+(1986 - 1)).eq(0)
              .and(col6floresta85.select('regen'+(1986    )).eq(1))
              .and(col6floresta85.select('regen'+(1986 + 1)).eq(1))
              .and(col6floresta85.select('regen'+(1986 + 2)).eq(1))
              .and(col6floresta85.select('regen'+(1986 + 3)).eq(1))
              .and(col6floresta85.select('regen'+(1986 + 4)).eq(1))
              .and(col6floresta85.select('regen'+(1986 + 5)).eq(1))
              .and(col6floresta85.select('regen'+(1986 + 6)).eq(1))
              .and(col6floresta85.select('regen'+(1986 + 7)).eq(1))
              .and(col6floresta85.select('regen'+(1986 + 8)).eq(1));
              
  mask86 = mask86.mask(mask86.eq(1));
  mask86 = mask86.unmask(imageZero);  
  mask86 = mask86.updateMask(mask86.neq(0));
  mask86 = mask86.select([0], ['regen1986']);

  var mask87 =  col6floresta85.select('regen'+(1987 - 2)).eq(0)
              .and(col6floresta85.select('regen'+(1987 - 1)).eq(0))
              .and(col6floresta85.select('regen'+(1987    )).eq(1))
              .and(col6floresta85.select('regen'+(1987 + 1)).eq(1))
              .and(col6floresta85.select('regen'+(1987 + 2)).eq(1))
              .and(col6floresta85.select('regen'+(1987 + 3)).eq(1))
              .and(col6floresta85.select('regen'+(1987 + 4)).eq(1));

  mask87 = mask87.mask(mask87.eq(1));
  mask87 = mask87.unmask(imageZero);  
  mask87 = mask87.updateMask(mask87.neq(0));
  mask87 = mask87.select([0], ['regen1987']);
  
  
  var mask19 =  col6floresta85.select('regen'+(2019 - 6)).eq(0)
            .and(col6floresta85.select('regen'+(2019 - 5)).eq(0))
            .and(col6floresta85.select('regen'+(2019 - 4)).eq(0))
            .and(col6floresta85.select('regen'+(2019 - 3)).eq(0))
            .and(col6floresta85.select('regen'+(2019 - 2)).eq(0))
            .and(col6floresta85.select('regen'+(2019 - 1)).eq(0))
            .and(col6floresta85.select('regen'+(2019    )).eq(1))
            .and(col6floresta85.select('regen'+(2019 + 1)).eq(1));
              
  mask19 = mask19.mask(mask19.eq(1));
  mask19 = mask19.unmask(imageZero);  
  mask19 = mask19.updateMask(mask19.neq(0));
  mask19 = mask19.select([0], ['regen2019']);
  
  var mask20 =  col6floresta85.select('regen'+(2020 - 8)).eq(0)
            .and(col6floresta85.select('regen'+(2020 - 7)).eq(0))
            .and(col6floresta85.select('regen'+(2020 - 6)).eq(0))
            .and(col6floresta85.select('regen'+(2020 - 5)).eq(0))
            .and(col6floresta85.select('regen'+(2020 - 4)).eq(0))
            .and(col6floresta85.select('regen'+(2020 - 3)).eq(0))
            .and(col6floresta85.select('regen'+(2020 - 2)).eq(0))             
            .and(col6floresta85.select('regen'+(2020 - 1)).eq(0))
            .and(col6floresta85.select('regen'+(2020    )).eq(1));
              
  mask20 = mask20.mask(mask20.eq(1));
  mask20 = mask20.unmask(imageZero);  
  mask20 = mask20.updateMask(mask20.neq(0));
  mask20 = mask20.select([0], ['regen2020']);

//Soma as bandas dos dois primeiros anos
var regen = mask86.addBands(mask87);

//Cria uma banda do primeiro ano da regra geral
var regen88 = geraMask3_3(1988);
regen88 = regen88.unmask(imageZero);  
regen88 = regen88.updateMask(regen88.neq(0));
regen88 = regen88.select(['regen1985'],['regen1988']);

//Soma as bandas 
regen = regen.addBands(regen88);

//Gera as bandas aplicando o filtro para todos os demais anos da regra geral (no caso, até 2016)
for (var i = 1989; i < 2019; i++) {
   var regen_geral = geraMask3_3(i);
      regen_geral = regen_geral.unmask(imageZero);
      regen_geral = regen_geral.updateMask(regen_geral.neq(0));
  regen = regen.addBands(regen_geral.select([0],['regen'+ i]));
}

//Adiciona os dois últimos anos
regen = regen.addBands(mask19).addBands(mask20);
print(regen);

Map.addLayer(regen.select('regen2019'), {'min': 0,'max': 1, 'palette': 'blue'},'Regen_2019');
Map.addLayer(regen.select('regen2020'), {'min': 0,'max': 1, 'palette': 'blue'},'Regen_2020');

Export.image.toAsset({
    "image": regen.unmask(0).uint8(),
    "description": 'regenSEEGc6',
    "assetId": dir_output + 'regenSEEGc6', //inserir aqui o endereço e o nome do Asset a ser exportado
    "scale": 30,
    "pyramidingPolicy": {
        '.default': 'mode'
    },
    "maxPixels": 1e13,
    "region": Bioma.geometry().bounds() //alterar aqui para o nome da região usada
});    
