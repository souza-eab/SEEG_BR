var transicoes = ee.Image('projects/ee-seeg-brazil/assets/collection_10/v1/3_1_SEEG_Transitions_stacked');
var todas_equacoes = ee.FeatureCollection('projects/ee-seeg-brazil/assets/data_aux/List_transition_seeg10v2');
var incremento_QCN = ee.FeatureCollection('users/barbarazimbres/incremento_metodo_novo');
var estoques = ee.FeatureCollection('projects/ee-seeg-brazil/assets/data_aux/stk_2022');


/*var bounds = ee.Geometry.Polygon([
  [
    [-74.34040691705002, 5.9630086351511690],
    [-74.34040691705002, -34.09134700746099],
    [-33.64704754205002, -34.09134700746099],
    [-33.64704754205002, 5.9630086351511690]
  ]
]);*/

var START_YEAR = 1986;
var END_YEAR = 2021;

var QCN_1985 = QCN.select('total_1985').mosaic();


var biomes = [
  ['AMAZONIA','Amazônia'],
  ['CAATINGA','Caatinga'],
  ['CERRADO','Cerrado'],
  ['MATA_ATLANTICA','Mata Atlântica'],
  ['PAMPA','Pampa'],
  ['PANTANAL','Pantanal'],
];

var recipe = biomes.map(function(list){
  
  var BIOME = list[0];
  var bioma = list[1];
  
  var geom_bioma = ee.FeatureCollection('projects/mapbiomas-workspace/AUXILIAR/biomas_IBGE_250mil')
    .filter(ee.Filter.eq('Bioma',bioma))
    .geometry();

  var incremento_QCN_biome = incremento_QCN.filter(ee.Filter.eq('Bioma', BIOME.toUpperCase())).first();
  var estoques_biome = estoques.filter(ee.Filter.eq('Bioma', BIOME.toUpperCase())).first();
  var transicoes_estaveis = transicoes.eq(490049).or(transicoes.eq(50005)).or(transicoes.eq(40004)).or(transicoes.eq(30003))
                          .or(transicoes.eq(130013)).or(transicoes.eq(120012)).or(transicoes.eq(110011))
                          .or(transicoes.eq(40003)).or(transicoes.eq(50003)).or(transicoes.eq(490003))
                         .or(transicoes.eq(500003)).or(transicoes.eq(30004)).or(transicoes.eq(50004))
                         .or(transicoes.eq(490004)).or(transicoes.eq(500004)).or(transicoes.eq(30005))
                         .or(transicoes.eq(40005)).or(transicoes.eq(490005)).or(transicoes.eq(500005))
                         .or(transicoes.eq(120011)).or(transicoes.eq(130011)).or(transicoes.eq(110012))
                         .or(transicoes.eq(130012)).or(transicoes.eq(110013)).or(transicoes.eq(120013))
                         .or(transicoes.eq(30049)).or(transicoes.eq(40049)).or(transicoes.eq(50049))
                         .or(transicoes.eq(500049)).or(transicoes.eq(30050)).or(transicoes.eq(40050))
                         .or(transicoes.eq(50050)).or(transicoes.eq(490050))
                          .mask(ap).multiply(transicoes);
                         
  var transicoes_nao_estaveis = transicoes.neq(490049).and(transicoes.neq(50005)).and(transicoes.neq(40004)).and(transicoes.neq(30003))
                             .and(transicoes.neq(130013)).and(transicoes.neq(120012)).and(transicoes.neq(110011))
                             .and(transicoes.neq(40003)).and(transicoes.neq(50003)).and(transicoes.neq(490003))
                             .and(transicoes.neq(500003)).and(transicoes.neq(30004)).and(transicoes.neq(50004))
                             .and(transicoes.neq(490004)).and(transicoes.neq(500004)).and(transicoes.neq(30005))
                             .and(transicoes.neq(40005)).and(transicoes.neq(490005)).and(transicoes.neq(500005))
                             .and(transicoes.neq(120011)).and(transicoes.neq(130011)).and(transicoes.neq(110012))
                             .and(transicoes.neq(130012)).and(transicoes.neq(110013)).and(transicoes.neq(120013))
                             .and(transicoes.neq(30049)).and(transicoes.neq(40049)).and(transicoes.neq(50049))
                             .and(transicoes.neq(500049)).and(transicoes.neq(30050)).and(transicoes.neq(40050))
                             .and(transicoes.neq(50050)).and(transicoes.neq(490050))
                             .multiply(transicoes);

  transicoes = ee.ImageCollection([transicoes_estaveis, transicoes_nao_estaveis]).max();

  // cria um array de 0 com a quantidade de anos
  var zeros = Array.from({ length: END_YEAR-START_YEAR+1 }, function(v, k) {return 0});
  // array de anos no formato string
  var years = Array.from({ length: END_YEAR-START_YEAR+1 }, function(v, k) {return ('emissions_removals_' + (k + START_YEAR)).toString() });
  
  // imagem vazia com total de bandas iqual a quantidade de anos
  var image = ee.Image(zeros).rename(years);
  
  // nomes das propriedades de incremente QCN
  var props_names_iQCN = incremento_QCN_biome.propertyNames();
  // nomes das propriedades de estoques
  var props_names_estoques = estoques_biome.propertyNames();
  
  // códigos das classes
  var fsec = ee.List([300, 400, 500, 4900, 5000]); // floresta secundária
  var fp = ee.List([9]); // floresta plantada/silvicultura
  var ac = ee.List([20, 36, 39, 40, 41, 46, 47, 48, 21, 62]); // agricultura
  var ap = ee.List([15]); // pastagem
  var ot = ee.List([23, 24, 25, 29, 30, 31, 33]); // outros
  
  var emissoes_remocoes = todas_equacoes.map(function(feat) {

    var transicao = ee.Number(feat.get('transicao'));
    var equacao   = ee.String(feat.get('equacao'));
    var ct1_val   = ee.String(feat.get('Ct1')).trim();
    
    var from = transicao.divide(10000).int();
    var to = transicao.mod(10000);
    
    var Ct1 = ee.Number.parse(ee.Algorithms.If(props_names_estoques.contains(ee.String(from)), estoques_biome.get(from), 0));
        Ct1 = ee.Algorithms.If(ct1_val.compareTo('Valor do pixel'), ee.Image(Ct1), QCN_1985);
        Ct1 = ee.Algorithms.If(ct1_val.compareTo('Valor do pixel*0.44'), ee.Image(Ct1), QCN_1985.multiply(0.44));
    var Ct2 = ee.Number.parse(ee.Algorithms.If(props_names_estoques.contains(ee.String(to)), estoques_biome.get(to), 0));

    var Ci  = ee.Number.parse(ee.Algorithms.If(props_names_iQCN.contains(ee.String(from)), incremento_QCN_biome.get(from), 0));
        Ci  = ee.Number.parse(ee.Algorithms.If(fsec.cat(fp).containsAll([from, to]), incremento_QCN_biome.get('F-FSEC'), Ci));
        Ci  = ee.Number.parse(ee.Algorithms.If(fsec.cat(ac).containsAll([from, to]), incremento_QCN_biome.get('AC-FSEC'), Ci));
        Ci  = ee.Number.parse(ee.Algorithms.If(fsec.cat(ap).containsAll([from, to]), incremento_QCN_biome.get('AP_FSEC'), Ci));
        Ci  = ee.Number.parse(ee.Algorithms.If(fsec.cat(ot).containsAll([from, to]), incremento_QCN_biome.get('O-FSEC'), Ci));
        Ci  = ee.Number.parse(ee.Algorithms.If(fsec.containsAll([from, to]), incremento_QCN_biome.get('F-FSEC'), Ci));
    
    var transicao_image = transicoes.eq(transicao);
    
    return emissoes_remocoes = ee.Image().expression(equacao, {
          'image': image,
          'Ci': Ci,
          'Ct1': Ct1,
          'Ct2': Ct2
    })
    .updateMask(transicao_image)
    .updateMask(ee.Image().paint(geom_bioma).eq(0))
    .float();

  });

  var img =  ee.ImageCollection(emissoes_remocoes)
    .mosaic();

  return img.set({
        'BIOME':BIOME
    });

});

var emissoes_remocoes = ee.ImageCollection(recipe).mosaic();

//print(emissoes_remocoes,emissoes_remocoes.bandNames());
//Map.addLayer(emissoes_remocoes);

var description = 'Emissons_Removals';
var folder = 'projects/mapbiomas-workspace/SEEG/2022/SPATIAL/SEEG10_BR';

/**
  * Export to asset
  */
var assetGrids = 'projects/mapbiomas-workspace/AUXILIAR/cartas';

var grids = ee.FeatureCollection(assetGrids);

var gridNames = [
    "NA-19", "NA-20", "NA-21", "NA-22", "NB-20", "NB-21", "NB-22", "SA-19",
    "SA-20", "SA-21", "SA-22", "SA-23", "SA-24", "SB-18", "SB-19", "SB-20",
    "SB-21", "SB-22", "SB-23", "SB-24", "SB-25", "SC-18", "SC-19", "SC-20",
    "SC-21", "SC-22", "SC-23", "SC-24", "SC-25", "SD-20", "SD-21", "SD-22",
    "SD-23", "SD-24", "SE-20", "SE-21", "SE-22", "SE-23", "SE-24", "SF-21",
    "SF-22", "SF-23", "SF-24", "SG-21", "SG-22", "SG-23", "SH-21", "SH-22",
    "SI-22"
];

gridNames.forEach(
    function (gridName) {
        var grid = grids.filter(ee.Filter.stringContains('grid_name', gridName));

        Export.image.toAsset({
            'image': emissoes_remocoes,
            'description': description + '_' + gridName,
            'assetId': folder + '/' + description + '_' + gridName,
            'pyramidingPolicy': {
                ".default": "mode"
            },
            'region': grid.geometry().buffer(300).bounds(),
            'scale': 30,
            'maxPixels': 1e13
        });
    }
);

// var vis = {
//     bands: ['1990'],
//     min: -2,
//     max: 2,
//     palette:["006837","1a9850","66bd63","a6d96a","d9ef8b","ffffbf","fee08b","fdae61","f46d43","d73027","a50026"]
// };

var pal = require('users/gena/packages:palettes').matplotlib.viridis[7];
var Mapp = require('users/joaovsiqueira1/packages:Mapp.js');
var ColorRamp = require('users/joaovsiqueira1/packages:ColorRamp.js');

var visFlo = {
   bands: ['emissions_removals_1990'],
    min: -2,
     max: 2,
   palette:["006837",
               "1a9850",
               "66bd63",
               "a6d96a",
               "d9ef8b",
               "ffffbf",
               "fee08b",
               "fdae61",
               "f46d43",
               "d73027",
               "a50026"
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
   'title': 'Emissão/Remoção (CO2e)',
     'min': visFlo.min,
     'max': visFlo.max,
     'palette': visFlo.palette,
 });


// // Get legend widget
var legend = ColorRamp.getWidget();

Map.add(legend);
// // ### CAMADAS ###
// // Map.addLayer(transicoes, {}, 'transicoes', false);
Map.addLayer(emissoes_remocoes.selfMask(), visFlo, 'emissões e remoções');
// // Map.addLayer(QCN_1985, {}, 'QCN_1985', false);


Map.setOptions({
  'styles': {
    'Dark': Mapp.getStyle('Dark'),
    'Dark2':Mapp.getStyle('Dark2'),
    'Aubergine':Mapp.getStyle('Aubergine'),
    'Silver':Mapp.getStyle('Silver'),
    'Night':Mapp.getStyle('Night'),
  }
});
Map.setZoom(12.5)
