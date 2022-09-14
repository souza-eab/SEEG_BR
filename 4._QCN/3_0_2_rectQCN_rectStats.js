// extract mean value and store as statistics 
// any issue or bug, please write to edriano.souza@ipam.org.br and/or dhemerson.costa@ipam.org.br  

// define years to be processed 
var list_mapb_years = [1985//, 1986, 1987, 1988, 1989, 1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997,
                       //1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010,
                       //2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019,
                       //2020
                       ];
                       
// define biomes to be processed
var list_biomes = [//1, // amazonia
                   //2, // mata atlantica
                   //3, // pantanal
                   4, // cerrado
                   //5, // caatinga
                   //6 // pampa
                   ];
                       
// define QCN classes to extract statistics 
var list_qcn_classes = [3,  // Forest formation
                        //4,  // Savanna formation 
                        //5,  // Mangrove
                        //12, // Grassland 
                        ];

// define mapbiomas colelction 6.0 reclassification matrix
var raw_mapbiomas  = [3, 4, 5, 9, 11, 12, 13, 15, 20, 21, 23, 24, 25, 29, 30, 31, 32, 33, 39, 40, 41, 46, 47, 48, 49];   
var reclass_vector = [3, 4, 5, 0, 12, 12,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  5];   

// total c - raw qcn
var raw_qcn = ee.ImageCollection('projects/mapbiomas-workspace/SEEG/2021/QCN/QCN_30m_c')
                .mosaic()
                .select(['total']);

// total c - rectified qcn  
var rec_qcn = ee.ImageCollection('projects/mapbiomas-workspace/SEEG/2021/QCN/QCN_30m_rect')
                .mosaic();

// LCLU classes - qcn 
var cls_qcn = ee.ImageCollection('projects/mapbiomas-workspace/SEEG/2021/QCN/QCN_30m_c')
                .mosaic()
                .select(['qcnclass']);

// LCLU classes - mapbiomas    
var cls_mpb = ee.Image("projects/mapbiomas-workspace/public/collection6/mapbiomas_collection60_integration_v1");

// brazilian states
var br_stt = ee.FeatureCollection('projects/mapbiomas-workspace/AUXILIAR/estados-2017');
//var br_stt = br_stt.limit(3);

// biomes
var biomes = ee.Image('projects/mapbiomas-workspace/AUXILIAR/biomas-2019-raster');

// get color-ramp module
var vis = {
    'min': 0,
    'max': 49,
    'palette': require('users/mapbiomas/modules:Palettes.js').get('classification6')
};

// define empty recipe 
var recipe = ee.FeatureCollection([]);

// for each year
list_mapb_years.forEach(function(year_i) {
  // selected products for the year i
  var rec_qcn_i = rec_qcn.select(['total_' + year_i]);
  var cls_mpb_i = cls_mpb.select(['classification_' + year_i]);
  
  // reclassify mapbiomas
  var cls_mpb_reclass_i = cls_mpb_i.remap(raw_mapbiomas, reclass_vector);
  //Map.addLayer(cls_mpb_reclass_i, vis, 'rec');
  
  // for each biome 
  list_biomes.forEach(function(biome_j) {
    // clip for biome 
    var rec_qcn_ij = rec_qcn_i.updateMask(biomes.eq(biome_j));
    var raw_qcn_ij = raw_qcn.updateMask(biomes.eq(biome_j));
    var cls_mpb_reclass_ij = cls_mpb_reclass_i.updateMask(biomes.eq(biome_j));
    var cls_qcn_ij = cls_qcn.updateMask(biomes.eq(biome_j));
    //Map.addLayer(cls_qcn_ij, vis, 's')
    
    // for each qcn class
    list_qcn_classes.forEach(function(class_k) {
      // subset qcn class only to class k
      var cls_qcn_ijk = cls_qcn_ij.updateMask(cls_qcn_ij.eq(class_k));
      // subset raw qcn to qcn class k
      var raw_qcn_ijk = raw_qcn_ij.updateMask(cls_qcn_ijk);
      //Map.addLayer(raw_qcn_ijk, vis, 'MB_classe_reclass_cut_i_j' + class_k);
      
      // define function to compute raw mean
      var getRawMean = function (feature) {
        // compute mean
        var mean = raw_qcn_ijk.reduceRegion({
          reducer: ee.Reducer.mean(),
          geometry: feature.geometry(),
          scale: 30,
          bestEffort: true});
          
        // store value
        //var value = ee.Dictionary(mean);
        
        return feature.set('c_qcn', ee.Number(mean.get('total')));
      };
      
      // compute raw mean
      var temp_feature = br_stt.map(getRawMean);
      
      // mask mapbiomas for the interest class
      var cls_mpb_reclass_ijk = cls_mpb_reclass_ij.updateMask(cls_mpb_reclass_ij.eq(class_k));
      //Map.addLayer(cls_mpb_reclass_ijk, vis, 'class');
      
      // subset rect + unrect to mapbiomas class k
      var rec_qcn_ijk = rec_qcn_ij.updateMask(cls_mpb_reclass_ijk);

      // define function to compute rectified mean
      var getUn_RectMean = function (feature) {
        // compute mean
        var mean = rec_qcn_ijk.reduceRegion({
          reducer: ee.Reducer.mean(),
          geometry: feature.geometry(),
          scale: 30,
          bestEffort: true});
          
        // store value
        //var value = ee.Dictionary(mean);
        
        return feature.set('c_raw_mapb', ee.Number(mean.get('total_' + year_i)));
      };
      
      // compute rect mean
      temp_feature = temp_feature.map(getUn_RectMean);
      
      // subset concordance among QCN and mapbiomas
      var concordance_ijk = cls_mpb_reclass_ijk.updateMask(cls_qcn_ijk);
      //Map.addLayer(concordance_ijk, vis, 'concordance');
          Map.addLayer(concordance_ijk, vis, 'Agreement' + class_k)
          // select c total
          concordance_ijk = rec_qcn_ij.updateMask(concordance_ijk);

      // define function to compute agreement mean
      var getAgreementMean = function (feature) {
        // compute mean
        var mean = concordance_ijk.reduceRegion({
          reducer: ee.Reducer.mean(),
          geometry: feature.geometry(),
          scale: 30,
          bestEffort: true});
          
        // store value
        //var value = ee.Dictionary(mean);
        
        return feature.set('c_agreement', ee.Number(mean.get('total_' + year_i)));
      };
      
      // compute concordance mean
      temp_feature = temp_feature.map(getAgreementMean);
      
      // subset disagreement among QCN and mapbiomas
      var discordance_ijk = cls_mpb_reclass_ijk.updateMask(cls_qcn_ij.neq(class_k));
          Map.addLayer(discordance_ijk, vis, 'Disagreement' + class_k)
      // select c total
          discordance_ijk = rec_qcn_ij.updateMask(discordance_ijk);
          
Map.addLayer(concordance_ijk.blend(discordance_ijk), vis, 'PABLO');
      
      // define function to compute disagreement mean
      var getDisagreementMean = function (feature) {
        // compute mean
        var mean = discordance_ijk.reduceRegion({
          reducer: ee.Reducer.mean(),
          geometry: feature.geometry(),
          scale: 30,
          bestEffort: true});
          
        // store value
        //var value = ee.Dictionary(mean);
        
        return feature.set('c_disagreement', ee.Number(mean.get('total_' + year_i)));
      };
      
      // compute concordance mean
      temp_feature = temp_feature.map(getDisagreementMean);
      
      // define function to paste metadata
      var insertMetadata = function (feature) {
        return (feature.set('year', year_i)
                       .set('biome', biome_j)
                       .set('class', class_k)
                       .setGeometry(null)
                       );
      };
      
      // apply function to paste metadata
          temp_feature = temp_feature.map(insertMetadata);
          //print (temp_feature);
          
      // merge into recipe
      recipe = recipe.merge(temp_feature);

    });
    
  });
  
});

// filter recipe to exclude NAs
recipe = recipe.filter(ee.Filter.gte('c_qcn', 0.0001));

// check recipe
print (recipe);

// export to gdrive
Export.table.toDrive({
  collection: recipe,
  description: 'rect_stats',
  folder: 'EXPORT',
  fileFormat: 'CSV'
});
