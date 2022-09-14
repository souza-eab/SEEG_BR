
// adjust total band - that is wrongly imported by edriano.souza@ipam.org.br or dhemerson.costa@ipam.org.br --'

// define output directory
var dir_out = 'projects/mapbiomas-workspace/SEEG/2021/QCN/QCN_30m_c/';

// read collection
var qcn = ee.ImageCollection('projects/mapbiomas-workspace/SEEG/2021/QCN/QCN_30m_b')
            .mosaic();
            
// import biomes
var biomes = ee.Image('projects/mapbiomas-workspace/AUXILIAR/biomas-2019-raster');

// define biomes to be processed
var list_biomes = [1, // amazonia
                   2, // mata atlantica
                   3, // pantanal
                   4, // cerrado
                   5, // caatinga
                   6 // pampa
                   ];

// remve 'total' band
var bands = qcn.bandNames();
var bands = bands.remove("total");
var qcn = qcn.select(bands);

// summarize carbon stock from all compartiments
var total = qcn.select(['cagb'])
                .add(qcn.select(['cbgb']))
                .add(qcn.select(['cdw']))
                .add(qcn.select(['clitter']))
                .rename(['total']);
                
// stack into data
var qcn = qcn.addBands(total);

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
  var temp_biome = qcn.updateMask(biomes.eq(process_biome))
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
