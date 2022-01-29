///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Script to Generate and Export Transition Maps Between Pair of years from a MapBiomas collection (eg. col 6.0) 
// For any issue/bug, please write to <edriano.souza@ipam.org.br>; <dhemerson.costa@ipam.org.br>; <barbara.zimbres@ipam.org.br>
// Developed by: IPAM, SEEG and OC
// Citing: SEEG/Observatório do Clima and IPAM
// Processing time (14:30h as ) in Google Earth Engine

// Set Asset
// Apply set

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Carregar o asset da região considerada. No caso, biomas do Brasil
var assetRegions = "projects/mapbiomas-workspace/AUXILIAR/biomas-2019";
var regions = ee.FeatureCollection(assetRegions);

var anos = ['1989', '1990','1991','1992','1993','1994','1995','1996','1997','1998','1999','2000','2001','2002','2003','2004','2005','2006','2007','2008','2009','2010','2011','2012','2013','2014','2015','2016','2017','2018','2019', '2020'];

//Carregar os asset da coleção do MapBiomas utilizada
var cobertura = ee.ImageCollection('projects/mapbiomas-workspace/SEEG/2021/Col9/mask_stable').aside(print);

//Loop para fazer a arimética de bandas com todos os pares de anos, multiplicando t1 por 10000
anos.forEach(function(ano){
  var coberturat1 = cobertura.filter(ee.Filter.eq("year", ee.Number.parse(ano).int())).mosaic();
  var coberturat2 = cobertura.filter(ee.Filter.eq("year", ee.Number.parse(ano).add(1).int())).mosaic();
  var transicoes = coberturat1.multiply(10000).add(coberturat2).int32();
  var namet1 = ee.Number.parse(ano).int();
  var namet2 = ee.Number.parse(String(parseInt(ano)+1)).int();
  var transicoes2=transicoes.rename(ee.String("transicao_").cat(ee.String(namet1)).cat(ee.String("_")).cat(namet2));
  print(transicoes2);

//Exportar os mapas de transição par a par como uma Image Collection
//(é necessário criar uma Image Collection vazia no Asset para armazenar cada imagem que for iterativamente sendo exportada)
//"Transicoes" é o nome da Image Collection que eu criei na pasta desejada
// SEEG_Transicoes_2021_c6_ irá ser o code 

//OBS.: vão ser gerados pares de anos até o último ano +1, que não existe. 
//Ignorar a Task para exportar esse último par de anos inexistente

Export.image.toAsset({
  "image": transicoes2.unmask(0).uint32(),
  "description": 'SEEG_Transicoes_2021_c6_'+ (parseInt(ano))+'_'+(parseInt(ano)+1),
  //alterar o endereço da sua Image Collection:
  "assetId": 'projects/mapbiomas-workspace/SEEG/2021/Col9/Transicoes/SEEG_Transicoes_2021_c6_'+ (parseInt(ano))+'_'+(parseInt(ano)+1),
  "scale": 30,
  "pyramidingPolicy": {
      '.default': 'mode'
  },
  "maxPixels": 1e13,
  "region": regions.geometry().bounds() //alterar para a região utilizada
});   
  
});
