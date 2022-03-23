//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Script to generate and stabilize annual coverage basemaps from a MapBiomas collection (eg. col 6.0) 
// For any issue/bug, please write to <edriano.souza@ipam.org.br>; <dhemerson.costa@ipam.org.br>; <barbara.zimbres@ipam.org.br>
// Developed by: IPAM, SEEG and OC
// Citing: SEEG/Observatório do Clima and IPAM
// Processing time 24-48 hs in Google Earth Engine

/// Definition of the functions used
/// Set Asset
/// Apply set

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//'projects/ee-seeg-brazil/assets/collection_9/v1/'
// Set Asset collection  6.0 MapBiomas 
var mapbioDir = 'projects/mapbiomas-workspace/public/collection6/mapbiomas_collection60_integration_v1';
var mapbiomas = ee.ImageCollection(mapbioDir).mosaic();

//Carregar o asset da região considerada. No caso, biomas do Brasil
var assetRegions = "projects/ee-seeg-brazil/assets/collection_9/v1/Biomes_BR";
var regions = ee.FeatureCollection(assetRegions);

//Carregar as máscaras de desmatamento e regeneração, já filtradas para eliminar ruído
var regenDir = 'projects/ee-seeg-brazil/assets/collection_9/v1/2_0_Temporal_filter_regeneration';
var regen = ee.Image(regenDir);
print("bandas regen", regen.bandNames());//regeneração a partir de 1990

var annualDesm = 'projects/ee-seeg-brazil/assets/collection_9/v1/2_0_Temporal_filter_deforestation';
var annualLoss = ee.Image(annualDesm); // desmatamento a partir de 1990
print("bandas annualLoss", annualLoss.bandNames());

//Seleciona bandas da coleção do MapBiomas a partir de 1989 (compõe a dupla da transição 1989-1990, que será a primeira a ser considerada)
var bandNames = mapbiomas.bandNames().slice(4);
print("bandas", bandNames);
      mapbiomas = mapbiomas.select(bandNames);

// 1986 -> 2020
////////Calculando frequencia (número de anos) em que cada pixel foi uma certa classe
// General rule (proporção do período)
var exp = '100*((b(0)+b(1)+b(2)+b(3)+b(4)+b(5)+b(6)+b(7)+b(8)+b(9)+b(10)+b(11)+b(12)+b(13)+b(14)+b(15)' +
    '+b(16)+b(17)+b(18)+b(19)+b(20)+b(21)+b(22)+b(23)+b(24)+b(25)+b(26)+b(27)+b(28)+b(29)+b(30)+b(31))/32)';

// Get frequency of each class
var florFreq = mapbiomas.eq(3).expression(exp); //floresta
var savFreq = mapbiomas.eq(4).expression(exp); //savana
var WrestFreq = mapbiomas.eq(49).expression(exp);  //////////////////////////////////////////////// 'Add class Wooded Restinga'
var manFreq = mapbiomas.eq(5).expression(exp);  //mangue
var umiFreq = mapbiomas.eq(11).expression(exp); //área úmida não florestal
var grassFreq = mapbiomas.eq(12).expression(exp); //veg campestre
var naoFlorFreq = mapbiomas.eq(13).expression(exp); //outra formação natural não florestal

var silviFreq = mapbiomas.eq(9).expression(exp); //silvicultura (floresta plantada)
var pastFreq = mapbiomas.eq(15).expression(exp); //pastagem
var agroAnnFreq = mapbiomas.eq(19).expression(exp); //agricultura anual e perene
var canaFreq = mapbiomas.eq(20).expression(exp); //agricultura semi-perene
var agroFreq = mapbiomas.eq(21).expression(exp); //mosaico de agricultura e pastagem
var praiasFreq = mapbiomas.eq(23).expression(exp); //praia e duna
var urbanFreq = mapbiomas.eq(24).expression(exp); //infraestrutura urbana
var naoVegFreq = mapbiomas.eq(25).expression(exp); //outra área não vegetada
var rockFreq = mapbiomas.eq(29).expression(exp); //afloramento rochoso
var mineFreq = mapbiomas.eq(30).expression(exp); //mineração
var aquiFreq = mapbiomas.eq(31).expression(exp); //aquicultura
var aguaFreq = mapbiomas.eq(33).expression(exp); //rio, lago, oceano
var agroPerFreq = mapbiomas.eq(36).expression(exp); //agricultura perene
var agroSojaFreq = mapbiomas.eq(39).expression(exp); //soja
var agroTempRice = mapbiomas.eq(40).expression(exp); //////////////////////////////////////////// 'Add class agricultura perene de 'Arroz'
var agroTempFreq = mapbiomas.eq(41).expression(exp); // agricultura anual (outras)
var agroPerFreqCoffee = mapbiomas.eq(46).expression(exp); //////////////////////////////////////// 'Add class agricultura perene de 'Café'
var agroPerFreqCitrus = mapbiomas.eq(47).expression(exp); //////////////////////////////////////// 'Add class agricultura perene de 'Citrus'
var agroPerFreqOther = mapbiomas.eq(48).expression(exp); //////////////////////////////////////// 'Add class agricultura perene de 'Outras Lavouras perenes' 


//////Máscara de vegetacao nativa e agua (freq >95%) estáveis
var vegMask = ee.Image(0).clip(regions)
                         .where(florFreq.gt(95), 1)  //ESTAVA 99, MAS NO ESQUEMA DA METODOLOGIA DIZ 95%. TROQUEI...
                         .where(savFreq.gt(95), 1)
                         .where(WrestFreq.gt(95), 1) 
                         .where(manFreq.gt(95), 1)
                         .where(umiFreq.gt(95), 1)
                         .where(grassFreq.gt(95), 1)
                         .where(naoFlorFreq.gt(95), 1)
                         .where(aguaFreq.gt(95), 1);

//////Máscara de uso e afloramento rochoso (freq >99%)    estáveis                      
var usoMask = ee.Image(0).clip(regions)                         
                          .where(silviFreq.gt(99), 1) //9
                          .where(pastFreq.gt(99), 1)  //15
                          .where(agroAnnFreq.gt(99), 1) //19
                          .where(agroPerFreq.gt(99), 1) //36
                          .where(agroPerFreqCoffee.gt(99), 1)     //46
                          .where(agroPerFreqCitrus.gt(99), 1)     //47
                          .where(agroPerFreqOther.gt(99), 1)      //48
                          .where(agroSojaFreq.gt(99), 1)          //39
                          .where(agroTempFreq.gt(99), 1)          //41
                          .where(canaFreq.gt(99), 1)              //20
                          .where(agroTempRice.gt(99), 1)          //40      
                          .where(agroFreq.gt(99), 1)              //21
                          .where(praiasFreq.gt(99), 1)            //23
                          .where(urbanFreq.gt(99), 1)             //24
                          .where(naoVegFreq.gt(99), 1)            //25
                          .where(mineFreq.gt(99), 1)              //30
                          .where(aquiFreq.gt(99), 1)              //31
                          .where(rockFreq.gt(0), 0);  //POR QUÊ 0?//29

/////Mapa base: 
var  baseMap = ee.Image(0).clip(regions)
///Aloca classe mais frequente na máscara de uso no mapa base
//Aqui a ordem importa, a ordenação é hierárquica
                              .where(usoMask.eq(1), 21) //classe 21 menor poder na hierarquia - OK - 30
                              .where(usoMask.eq(1).and(silviFreq.gt(99)), 9) // Ok include - 3.2 - 7 Hierarquica but nível 2  #Igual a 2019
                              .where(usoMask.eq(1).and(pastFreq.gt(99)), 15) /// Ok Include - 29
                              .where(usoMask.eq(1).and(agroAnnFreq.gt(99)), 19) /// Não existe
                              .where(usoMask.eq(1).and(agroPerFreqCoffee.gt(99)), 46) //46
                              .where(usoMask.eq(1).and(agroPerFreqCitrus.gt(99)), 47) //47
                              .where(usoMask.eq(1).and(agroPerFreqOther.gt(99)), 48)  //48
                              .where(usoMask.eq(1).and(agroPerFreq.gt(99)), 36) /// Não existe
                              .where(usoMask.eq(1).and(agroSojaFreq.gt(99)), 39)
                              .where(usoMask.eq(1).and(agroTempFreq.gt(99)), 41)
                              .where(usoMask.eq(1).and(agroTempRice.gt(99)), 40)          //40
                              .where(usoMask.eq(1).and(canaFreq.gt(99)), 20)
                              .where(usoMask.eq(1).and(praiasFreq.gt(99)), 23)
                              .where(usoMask.eq(1).and(urbanFreq.gt(99)), 24)
                              .where(usoMask.eq(1).and(naoVegFreq.gt(99)), 25)
                              .where(usoMask.eq(1).and(mineFreq.gt(99)), 30)
                              .where(usoMask.eq(1).and(aquiFreq.gt(99)), 31)
                              .where(usoMask.eq(1).and(rockFreq.gt(0)), 29)                               
                        
// Verificar pois aqui a alocação está como sendo florestas + ordem hierarquica                             
//Aloca classe mais frequente na máscara de vegetacao nativa, com um critério de 60% de corte e depois sobrepondo as áreas nativas estáveis                             
                              .where(vegMask.eq(1).and(florFreq.gt(60)), 3)
                              .where(vegMask.eq(1).and(savFreq.gt(60)), 4)
                              .where(vegMask.eq(1).and(WrestFreq.gt(60)), 49) ///// Lembrar da ordem
                              .where(vegMask.eq(1).and(manFreq.gt(60)), 5)
                              .where(vegMask.eq(1).and(umiFreq.gt(60)), 11)
                              .where(vegMask.eq(1).and(grassFreq.gt(60)), 12)
                              .where(vegMask.eq(1).and(naoFlorFreq.gt(60)), 13)
                              .where(vegMask.eq(1).and(aguaFreq.gt(95)), 33)
                              
                              .where(vegMask.eq(1).and(florFreq.gt(95)), 3) //ESTAVA 99, MAS NO ESQUEMA DA METODOLOGIA DIZ 95%. TROQUEI...
                              .where(vegMask.eq(1).and(savFreq.gt(95)), 4)
                              .where(vegMask.eq(1).and(WrestFreq.gt(95)), 49) //////////////////////////////////// Include 49
                              .where(vegMask.eq(1).and(manFreq.gt(95)), 5)
                              .where(vegMask.eq(1).and(umiFreq.gt(95)), 11)
                              .where(vegMask.eq(1).and(grassFreq.gt(95)), 12)
                              .where(vegMask.eq(1).and(naoFlorFreq.gt(95)), 13);
                                     
//Para preencher vazios: mapa de 1989 (exceto classe 21)
//Máscara vegetacao nativa em 1989
  var mapBiomas89vegMask = mapbiomas.select("classification_1989").remap([3, 4, 5, 49, 11, 12, 13], [1, 1, 1, 1, 1, 1, 1], 0);
//Máscara uso e água em 1989
  var mapBiomas89UsoMask = mapbiomas.select("classification_1989").remap([9, 15, 20, 23, 24, 25, 30, 31,  39, 40, 41, 46, 47, 48], //POR TINHA CLASSE 33 AQUI EM USO? ADICIONEI AS CLASSES AGRO NOVAS
                                                                         [1,  1,  1,  1,  1,  1,  1,  1,   1,  1,  1,  1,  1,  1], 0);
// Include 21 Mosaic Of Agriculture and Pasture // 23 if =1 ?
//Junta as duas máscaras                                                     
  var mapBiomas89Mask = mapBiomas89vegMask.where(mapBiomas89vegMask.eq(0), mapBiomas89UsoMask);

//Preenche as áreas não estáveis com as máscaras de uso e vegetação nativa em 1989
  baseMap = baseMap.where(baseMap.eq(0).and(mapBiomas89Mask.eq(1)),
                                            mapbiomas.select("classification_1989"));
  baseMap = baseMap.updateMask(baseMap.neq(0));
  baseMap = baseMap.select([0], ["classification_1989"]).unmask(0);

var years = [
    1990, 1991, 1992, 1993, 1994, 1995, 1996,
    1997, 1998, 1999, 2000, 2001, 2002, 2003,
    2004, 2005, 2006, 2007, 2008, 2009, 2010,
    2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020
]; 
var eeYears = ee.List(years);


/////Cria função para desmatamento com regeneração no mesmo ano
var goSEEG1_1 = function (element, accumList) {
  //chama elementos gerados anteriormente p dentro da funcao
  annualLoss = annualLoss.unmask(0); 
  mapbiomas = mapbiomas.unmask(0);
  baseMap = baseMap.unmask(0);
  usoMask = usoMask.unmask(0);
  bandNames;

///Mapa de desmatamento no ano t
  var thisYearLossMap =  annualLoss.select(eeYears.indexOf(element));

///Mapa de regeneracao no ano t
  var thisYearGainMap = regen.select(eeYears.indexOf(element));

///Cobertura MapBiomas no ano t  
  var presentBand = bandNames.get(eeYears.indexOf(element).add(1));
      presentBand = ee.List([presentBand]);
  var presentMapBio = mapbiomas.select(presentBand);

//Cobertura MapBiomas no ano t-1
  var previous = ee.List(accumList).get(-1);
      previous = ee.Image(previous);
  
//Outros nomes de bandas a serem usados (necessários para algum passo na função)
//////Mapa SEEG t-1
  var lastYearMap = previous.slice(-1);

//////MapBiomas t  
  var currentMapBioBand = bandNames.get(eeYears.indexOf(element).add(1));
      currentMapBioBand = ee.List([currentMapBioBand]);
//////MapBiomas t-1      
  var lastMapBioBand = bandNames.get(eeYears.indexOf(element));
      lastMapBioBand = ee.List([lastMapBioBand]);


//Construindo mapa de cobertura estabilizada para ano t      
/////Mapa no ano t = mapa do t-1. Onde desmatamento (t) = 1, alocar classe MapBiomas no ano t
  var thisYearCoverMap = lastYearMap.where(thisYearLossMap.eq(1),
                                           mapbiomas.select(currentMapBioBand));
/////Onde regeneracao (t) = 1, alocar classe MapBiomas no ano t (*100)
      thisYearCoverMap = thisYearCoverMap.where(thisYearGainMap.eq(1),
                                           mapbiomas.select(currentMapBioBand)
                                           .multiply(100));
////Onde houver classes 30 ou 24 no MapBiomas no ano t (exceto 21), alocar no mapa ano t   // Pq não a classe 21                                     
      thisYearCoverMap = thisYearCoverMap.where(mapbiomas.select(currentMapBioBand).eq(24)
                                                .or(mapbiomas.select(currentMapBioBand).eq(30)),
                                                mapbiomas.select(currentMapBioBand));

//This year anthropic land-use Mask
var thisYearLandUseMask = thisYearCoverMap.remap([9, 15, 20, 23, 24, 25, 30, 31,  39, 40, 41, 46, 47, 48],
                                                 [1,  1,  1,  1,  1,  1,  1,  1,   1,  1,  1,  1,  1,  1], 0);


////Libera transições entre classes de uso (retorna classes de uso do mapa do MapBiomas no ano considerado)                             
    thisYearCoverMap = thisYearCoverMap.where(thisYearLandUseMask.eq(1).and(mapbiomas.select(currentMapBioBand).eq(9)
                                                .or(mapbiomas.select(currentMapBioBand).eq(15))
                                                .or(mapbiomas.select(currentMapBioBand).eq(20))
                                                .or(mapbiomas.select(currentMapBioBand).eq(23))
                                                .or(mapbiomas.select(currentMapBioBand).eq(24))
                                                .or(mapbiomas.select(currentMapBioBand).eq(25))
                                                .or(mapbiomas.select(currentMapBioBand).eq(30))
                                                .or(mapbiomas.select(currentMapBioBand).eq(31))
                                                .or(mapbiomas.select(currentMapBioBand).eq(39))
                                                .or(mapbiomas.select(currentMapBioBand).eq(40))
                                                .or(mapbiomas.select(currentMapBioBand).eq(41))
                                                .or(mapbiomas.select(currentMapBioBand).eq(46))
                                                .or(mapbiomas.select(currentMapBioBand).eq(47))
                                                .or(mapbiomas.select(currentMapBioBand).eq(48))),
                                                mapbiomas.select(currentMapBioBand));
      
      thisYearCoverMap = thisYearCoverMap.select([0], currentMapBioBand);

///Bandas de anos passados para preencher mapas entre 1986 e t-1, com base nos dados de regeneracao e desmatamento e mapbiomas  
  var pastBandsVoid = ee.Algorithms.If(ee.Number(eeYears.indexOf(element)).eq(0),
    previous.bandNames().get(0),
    previous.bandNames());
    
    pastBandsVoid = ee.List([pastBandsVoid]).flatten();

///Mapas do MapBiomas a serem usados  
/////Constante (classes estáveis)
  var pastConstMapBio = ee.Algorithms.If(ee.Number(eeYears.indexOf(element)).eq(0),
    mapbiomas.select(lastMapBioBand, ee.List(["classification_1989"])),
    mapbiomas.select(ee.List.repeat(ee.String(lastMapBioBand.get(0)), eeYears.indexOf(element).add(1)),
                     bandNames.slice(0, eeYears.indexOf(element).add(1))));
  pastConstMapBio = ee.Image(pastConstMapBio);

/////Literal (classes como eram na coleção original)
  var pastFreeMapBio = ee.Algorithms.If(ee.Number(eeYears.indexOf(element)).eq(0),
    mapbiomas.select(["classification_1989"]),
    mapbiomas.select(pastBandsVoid));
    
  pastFreeMapBio = ee.Image(pastFreeMapBio);
  
//////Janela frequência classes entre t0 E t
var florFreq = pastFreeMapBio.eq(3).reduce(ee.Reducer.sum()) //OK
var savFreq = pastFreeMapBio.eq(4).reduce(ee.Reducer.sum()) //OK
var WrestFreq = pastFreeMapBio.eq(49).reduce(ee.Reducer.sum()) //OK
var manFreq = pastFreeMapBio.eq(5).reduce(ee.Reducer.sum()) //OK
var umiFreq = pastFreeMapBio.eq(11).reduce(ee.Reducer.sum()) //OK
var grassFreq = pastFreeMapBio.eq(12).reduce(ee.Reducer.sum()) //OK
var naoFlorFreq = pastFreeMapBio.eq(13).reduce(ee.Reducer.sum()) //OK
        
var silviFreq = pastFreeMapBio.eq(9).reduce(ee.Reducer.sum()) //OK
var pastFreq = pastFreeMapBio.eq(15).reduce(ee.Reducer.sum()) //OK
var canaFreq = pastFreeMapBio.eq(20).reduce(ee.Reducer.sum()) //OK
var praiasFreq = pastFreeMapBio.eq(23).reduce(ee.Reducer.sum()) //OK
var urbanFreq = pastFreeMapBio.eq(24).reduce(ee.Reducer.sum()) //OK
var naoVegFreq = pastFreeMapBio.eq(25).reduce(ee.Reducer.sum()) //OK
var mineFreq = pastFreeMapBio.eq(30).reduce(ee.Reducer.sum()) //OK
var aquiFreq = pastFreeMapBio.eq(31).reduce(ee.Reducer.sum()) //OK
var agroSojaFreq = pastFreeMapBio.eq(39).reduce(ee.Reducer.sum()) //OK
var agroTempRice = pastFreeMapBio.eq(40).reduce(ee.Reducer.sum()) //OK
var agroTempFreq = pastFreeMapBio.eq(41).reduce(ee.Reducer.sum()) //OK
var agroPerFreqCoffee = pastFreeMapBio.eq(46).reduce(ee.Reducer.sum()) //OK
var agroPerFreqCitrus = pastFreeMapBio.eq(47).reduce(ee.Reducer.sum()) //OK
var agroPerFreqOther = pastFreeMapBio.eq(48).reduce(ee.Reducer.sum()) //OK


var frequencyWindow = florFreq.addBands(savFreq).addBands(WrestFreq).addBands(manFreq).addBands(umiFreq).addBands(grassFreq)
                              .addBands(naoFlorFreq).addBands(silviFreq).addBands(pastFreq).addBands(canaFreq)
                              .addBands(praiasFreq).addBands(urbanFreq).addBands(naoVegFreq).addBands(mineFreq)
                              .addBands(aquiFreq).addBands(agroSojaFreq).addBands(agroTempRice).addBands(agroTempFreq)
                              .addBands(agroPerFreqCoffee).addBands(agroPerFreqCitrus).addBands(agroPerFreqOther);
                              
var moreFrequent = ee.Algorithms.If(frequencyWindow.reduce(ee.Reducer.max())
                                                    .eq(0), mapbiomas.select(currentMapBioBand),
                    ee.Algorithms.If(frequencyWindow.reduce(ee.Reducer.max())
                                                    .eq(frequencyWindow.select(0)), ee.Image(3),
                    ee.Algorithms.If(frequencyWindow.reduce(ee.Reducer.max())
                                                    .eq(frequencyWindow.select(1)), ee.Image(4),
                     ee.Algorithms.If(frequencyWindow.reduce(ee.Reducer.max())
                                                     .eq(frequencyWindow.select(2)), ee.Image(49),
                       ee.Algorithms.If(frequencyWindow.reduce(ee.Reducer.max())
                                                      .eq(frequencyWindow.select(3)), ee.Image(5),
                        ee.Algorithms.If(frequencyWindow.reduce(ee.Reducer.max())               
                                                       .eq(frequencyWindow.select(4)), ee.Image(11) ,
                         ee.Algorithms.If(frequencyWindow.reduce(ee.Reducer.max())
                                                         .eq(frequencyWindow.select(5)), ee.Image(12) ,
                           ee.Algorithms.If(frequencyWindow.reduce(ee.Reducer.max())
                                                           .eq(frequencyWindow.select(6)), ee.Image(13) ,
                             ee.Algorithms.If(frequencyWindow.reduce(ee.Reducer.max())
                                                             .eq(frequencyWindow.select(7)), ee.Image(9) ,
                               ee.Algorithms.If(frequencyWindow.reduce(ee.Reducer.max())
                                                               .eq(frequencyWindow.select(8)), ee.Image(15) ,
                                ee.Algorithms.If(frequencyWindow.reduce(ee.Reducer.max())
                                                               .eq(frequencyWindow.select(9)), ee.Image(20) ,
                                 ee.Algorithms.If(frequencyWindow.reduce(ee.Reducer.max())
                                                                 .eq(frequencyWindow.select(10)), ee.Image(23) ,
                                     ee.Algorithms.If(frequencyWindow.reduce(ee.Reducer.max())
                                                                     .eq(frequencyWindow.select(11)), ee.Image(24) ,
                                       ee.Algorithms.If(frequencyWindow.reduce(ee.Reducer.max())
                                                                       .eq(frequencyWindow.select(12)), ee.Image(25) ,
                                         ee.Algorithms.If(frequencyWindow.reduce(ee.Reducer.max())
                                                                         .eq(frequencyWindow.select(13)), ee.Image(30) ,
                                           ee.Algorithms.If(frequencyWindow.reduce(ee.Reducer.max())
                                                                           .eq(frequencyWindow.select(14)), ee.Image(31) ,
                                             ee.Algorithms.If(frequencyWindow.reduce(ee.Reducer.max())
                                                                             .eq(frequencyWindow.select(15)), ee.Image(39) ,
                                               ee.Algorithms.If(frequencyWindow.reduce(ee.Reducer.max())
                                                                                .eq(frequencyWindow.select(16)), ee.Image(40) ,
                                                 ee.Algorithms.If(frequencyWindow.reduce(ee.Reducer.max())
                                                                                  .eq(frequencyWindow.select(17)), ee.Image(41) ,
                                                    ee.Algorithms.If(frequencyWindow.reduce(ee.Reducer.max())
                                                                                      .eq(frequencyWindow.select(18)), ee.Image(46) ,
                                                      ee.Algorithms.If(frequencyWindow.reduce(ee.Reducer.max())
                                                                                         .eq(frequencyWindow.select(19)), ee.Image(47) ,
                                                        ee.Algorithms.If(frequencyWindow.reduce(ee.Reducer.max())
                                                                                          .eq(frequencyWindow.select(20)), ee.Image(48) ,
                                                                                  mapbiomas.select(currentMapBioBand))
                                                )))))))))))))))))))));
    moreFrequent = ee.Image(moreFrequent);
    
var pastFreqMapBio = ee.Algorithms.If(ee.Number(eeYears.indexOf(element)).eq(0),
    ee.Image(moreFrequent.select([0], ["classification_1989"])),
    ee.Image(pastBandsVoid.iterate(function(element, accumImg){
      return ee.Image(accumImg).addBands(ee.Image(moreFrequent.select([0], [element]))).slice(1);
    },ee.Image(moreFrequent.select([0], ["classification_1989"])))));

  pastFreqMapBio = ee.Image(pastFreqMapBio);

/////Onde há desmatamento (ano t) e 'vazio', preencher anos anteriores com classe de vegetacao MapBiomas em t-1
  var adequatedPastMaps = previous.select(pastBandsVoid).where((thisYearLossMap.eq(1)
                                                               .and(lastYearMap.eq(0)))
                                                               ,
                                                    pastConstMapBio);
                                                    
                                                    
/////Onde os dados de temas transversais ocorrem pela primeira vez (ano t) e era 'vazio' no mapa base,
/////preencher todos os anos anteriores com série temporal original do MapBiomas
      adequatedPastMaps = adequatedPastMaps.select(pastBandsVoid).where((thisYearGainMap.eq(1)
                                                                        .and(lastYearMap.eq(0)))
                                                    ,pastConstMapBio);                                                                               

 /////Onde há regeneracao (ano t) e 'vazio', preencher todos os anos anteriores com classe de uso MapBiomas em t-1
      adequatedPastMaps = adequatedPastMaps.select(pastBandsVoid).where(
                                                (lastYearMap.eq(0)).and( 
                                                thisYearCoverMap.eq(9)
                                                .or(thisYearCoverMap.eq(15))
                                                .or(thisYearCoverMap.eq(20)) // 19
                                                .or(thisYearCoverMap.eq(24))
                                                .or(thisYearCoverMap.eq(25))
                                                .or(thisYearCoverMap.eq(30))
                                                .or(thisYearCoverMap.eq(31))
                                                .or(thisYearCoverMap.eq(39)) // 19
                                                .or(thisYearCoverMap.eq(40)) // 19
                                                .or(thisYearCoverMap.eq(41))
                                                .or(thisYearCoverMap.eq(46))
                                                .or(thisYearCoverMap.eq(47))
                                                .or(thisYearCoverMap.eq(48))),
                                                pastFreqMapBio);
                                                
////Mapa adequado: passado 'preenchido' + mapa do ano atual
  var adequatedSack = adequatedPastMaps.addBands(thisYearCoverMap);                                                

return ee.List(accumList).add(ee.Image(adequatedSack));
  
};

//Aplicar a função sobre a coleção
var mapsSEEG1_1 = eeYears.iterate(goSEEG1_1, ee.List([baseMap]));
    mapsSEEG1_1 = ee.List(mapsSEEG1_1);

var SEEGmap1_1 = ee.Image(mapsSEEG1_1.get(31));
print('SEEGmap1_1 Maps_pos_desmate*regen', SEEGmap1_1 );

///////////////////////////////////
//Exportar os mapas de cobertura estabilizados como uma Image Collection
//(é necessário criar uma Image Collection vazia no Asset para armazenar cada imagem que for iterativamente sendo exportada)

for (var i = 0; i < 32; i++){ //MAIS UM ANO
  var bandName = SEEGmap1_1.bandNames().get(i);
  var image = SEEGmap1_1.select([bandName]).set('year', ee.Number(1989).add(i));
  
  Export.image.toAsset({
    "image": image.unmask(0).uint32(),
    "description": 'SEEG_2021_c6_'+ (1989+i),
    "assetId": 'projects/mapbiomas-workspace/SEEG/2021/Col9/mask_stable/SEEG_2021_c6_'+ (1989+i), //alterar o endereço da sua Image Collection
    "scale": 30,
    "pyramidingPolicy": {
        '.default': 'mode'
    },
    "maxPixels": 1e13,
    "region": regions.geometry().bounds() //alterar para a região utilizada
});   
  
}

