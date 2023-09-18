// standardize assets per biome
// dhemerson.costa@ipam.org.br ; wallace.silva@ipam.org.br ; edrinao.souza@ipam.org.br

// define output directory
var dir_out = 'projects/mapbiomas-workspace/SEEG/2023/QCN/Asset_v0-1/'; // 30m
//var dir_out = 'projects/mapbiomas-workspace/SEEG/2023/QCN/Asset_v0-2/'; // 250 m

var version = '_v0-1'
// import QCN with 30 meters
var qcn_ic = ee.ImageCollection('projects/mapbiomas-workspace/SEEG/2023/QCN/Data_Official').aside(print,'outros biomas');
var qcn_amazonia = ee.Image('projects/mapbiomas-workspace/SEEG/2023/QCN/pastVegetation_v0-1').aside(print,'amazonia'); // 30m
//var qcn_amazonia = ee.Image('projects/mapbiomas-workspace/SEEG/2023/QCN/pastVegetation_v0-2').aside(print,'amazonia'); // 250 m

// import biomes
var biomes = ee.Image('projects/mapbiomas-workspace/AUXILIAR/biomas-2019-raster');
Map.addLayer(biomes);

// define biomes to be processed
var list_biomes = [1, // amazonia
                   2, // mata atlantica
                   3, // pantanal
                   4, // cerrado
                   5, // caatinga
                   6 // pampa
                   ];

// read filename and paste as metadata
var qcn_ic= qcn_ic.map(function(image){return image.set({
      band: ee.String(image.get('system:index')).split('_').get(2)}); 
    })

// aggregate all biomes
var qcn_cagb = ee.ImageCollection([
    qcn_amazonia.select(['past_vegetation_c_agb'],['c_agb']),
    qcn_ic.filterMetadata('band', 'equals', 'c_agb').mosaic().rename('c_agb')
  ]).mosaic();

var qcn_cbgb = ee.ImageCollection([
    qcn_amazonia.select(['past_vegetation_c_bgb'],['c_bgb']),
    qcn_ic.filterMetadata('band', 'equals', 'c_bgb').mosaic().rename('c_bgb')
  ]).mosaic();
  
var qcn_clitter = ee.ImageCollection([
    qcn_amazonia.select(['past_vegetation_c_litter'],['c_litter']),
    qcn_ic.filterMetadata('band', 'equals', 'c_litter').mosaic().rename('c_litter')
  ]).mosaic();

var qcn_cdw = ee.ImageCollection([
    qcn_amazonia.select(['past_vegetation_c_dw'],['c_dw']),
    qcn_ic.filterMetadata('band', 'equals', 'c_dw').mosaic().rename('c_dw')
  ]).mosaic();
  
  
var qcn_total = ee.ImageCollection([
    qcn_amazonia.select(['past_vegetation_c_total'],['total']),
    qcn_ic.filterMetadata('band', 'equals', 'total').mosaic().rename('total')
  ]).mosaic();
  
var qcn_class = ee.ImageCollection([
    qcn_amazonia.select(['past_vegetation_MB_C8'],['MB_C8']),
    qcn_ic.filterMetadata('band', 'equals', 'C8').mosaic().rename('MB_C8')
  ]).mosaic();
  
//Map.addLayer(qcn_class,{},'aaa')
// stack bands
var stacked_brazil = qcn_cagb.addBands(qcn_cbgb)
                             .addBands(qcn_cdw)
                             .addBands(qcn_clitter)
                             .addBands(qcn_total)
                             .addBands(qcn_class)
                            // .rename(['cagb', 'cbgb', 'cdw',
                            //           'clitter', 'total', 'class']);
                                      
// export per biome
list_biomes.forEach(function(process_biome) {
  var biome_name;

  if (process_biome == 1) {
    biome_name = 'amazonia';
  }
  if (process_biome == 2) {
    biome_name = 'mata_atlantica';
  }
  if (process_biome == 3) {
    biome_name = 'pantanal';
  }
  if (process_biome == 4) {
    biome_name = 'cerrado';
  }
  if (process_biome == 5) {
    biome_name = 'caatinga';
  }
  if (process_biome == 6) {
    biome_name = 'pampa';
  }
  
  // clip to biomee
  var temp_biome = stacked_brazil.updateMask(biomes.eq(process_biome))
    .set({biome: ee.String(biome_name)});
  
  /*
  print(temp_biome,biome_name)
  Map.addLayer(temp_biome,{},biome_name)
  print(temp_biome.geometry(),biome_name)
  Map.addLayer(temp_biome.geometry(),{},biome_name)
  */

  // export
  Export.image.toAsset({
    "image": temp_biome,
    "description": biome_name + version,
    "assetId": dir_out + biome_name,
    "scale": 30,
    //"scale": 250,
    "pyramidingPolicy": {
        '.default': 'mode'
    },
    "maxPixels": 1e13,
    "region": temp_biome.geometry()
  });  
});
