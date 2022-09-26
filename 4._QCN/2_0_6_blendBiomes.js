// standardize assets per biome
// edriano.souza@ipam.org.br; dhemerson.costa@ipam.org.br ; wallace.silva@ipam.org.br

// define output directory
var dir_out = 'projects/mapbiomas-workspace/SEEG/2022/QCN/QCN_30m_rect_v2_0_1/';

// import QCN with 30 meters
var qcn_ic = ee.ImageCollection('projects/mapbiomas-workspace/SEEG/2022/QCN/QCN_30m_rect').aside(print,'others biomes');
var qcn_amazonia = ee.Image('projects/mapbiomas-workspace/SEEG/2022/QCN/pastVegetation_v2').aside(print,'biome amazonia');

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
    });

// aggregate all biomes
var qcn_cagb = ee.ImageCollection([
    qcn_amazonia.select(['past_vegetation_cagb'],['cagb']),
    qcn_ic.filterMetadata('band', 'equals', 'cagb').mosaic().rename('cagb')
  ]).mosaic();

var qcn_cbgb = ee.ImageCollection([
    qcn_amazonia.select(['past_vegetation_cbgb'],['cbgb']),
    qcn_ic.filterMetadata('band', 'equals', 'cbgb').mosaic().rename('cbgb')
  ]).mosaic();
  
var qcn_cdw = ee.ImageCollection([
    qcn_amazonia.select(['past_vegetation_cdw'],['cdw']),
    qcn_ic.filterMetadata('band', 'equals', 'cdw').mosaic().rename('cdw')
  ]).mosaic();
  
var qcn_clitter = ee.ImageCollection([
    qcn_amazonia.select(['past_vegetation_clitter'],['clitter']),
    qcn_ic.filterMetadata('band', 'equals', 'clitter').mosaic().rename('clitter')
  ]).mosaic();
  
var qcn_total = ee.ImageCollection([
    qcn_amazonia.select(['past_vegetation_ctotal4inv'],['total']),
    qcn_ic.filterMetadata('band', 'equals', 'total').mosaic().rename('total')
  ]).mosaic();
  
var qcn_class = ee.ImageCollection([
    qcn_amazonia.select(['past_vegetation__MB_C7'],['qcnclass']),
    qcn_ic.filterMetadata('band', 'equals', '_c7_qcnclass').mosaic().rename('qcnclass')
  ]).mosaic();
  
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
  
  
  print(temp_biome,biome_name)
  Map.addLayer(temp_biome,{},biome_name)
  print(temp_biome.geometry(),biome_name)
  Map.addLayer(temp_biome.geometry(),{},biome_name)


  // export
  Export.image.toAsset({
    "image": temp_biome,
    "description": biome_name,
    "assetId": dir_out + biome_name,
    "scale": 30,
    "pyramidingPolicy": {
        '.default': 'mode'
    },
    "maxPixels": 1e13,
    "region": temp_biome.geometry()
  });  
});
