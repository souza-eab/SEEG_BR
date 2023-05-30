// Rectify 'c_total' of QCN per native vegetation classe by using Mapbiomas Collection 7.0 LCLUC as reference  
// For any issue/bug, please write to <edriano.souza@ipam.org.br> and/or <dhemerson.costa@ipam.org.br>
// SEEG/Observatório do Clima and IPAM
// Current version: 2.0

// @ UPDATE HISTORIC @ //
// 1:  Compute number of divergences by comparing qcn past vegetation and mapbiomas 7.0 (per year)
// 1.1 Perform 'c_total' correction for the Cerrado biome (1985) 
// 1.2 Perform 'c_total' correction for the Cerrado biome from 1985 to 2020 (cumulative and static)
// 2.0 Perform 'c_total' correction for all biomes from 1985 to 2021 (Static)

//* @ Set user parameters *//
//var dir_output = 'projects/mapbiomas-workspace/SEEG/2022/QCN/QCN_30m_BR_v2_0_2_Rect';
//var dir_output = 'projects/mapbiomas-workspace/SEEG/2022/QCN/QCN_30m_BR_v2_0_3_Mean_reduceNeighborhood' // Reducer_Mean
var dir_output = 'projects/mapbiomas-workspace/SEEG/2022/QCN/QCN_30m_BR_v2_0_3_Mode_reduceNeighborhood' // Reducer_Mean
var version = '1';

// define biomes to be processed
// to process a single biome, comment lines 
var list_biomes = [1, // amazonia
                   2, // mata atlantica
                   3, // pantanal
                   4, // cerrado
                   5, // caatinga
                   6 // pampa
                   ];

// define years to be processed 
var list_mapb_years = [1985,1986, 1987, 1988, 1989, 1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997,
                       1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010,
                       2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021
                       ];
                       
// define QCN classes to be rectified
var list_qcn_classes = [3,  // Forest formation
                        4,  // Savanna formation 
                        5,  // Mangrove
                        11, // Wetland
                        12, // Grassland 
                        49, // Wooded Restinga
                        50]; // Shrubby Restinga //*BZ

// define mapbiomas colelction 7.0 reclassification matrix
var raw_mapbiomas  = [3, 4, 5, 9, 11, 12, 13, 15, 20, 21, 23, 24, 25, 29, 30, 31, 32, 33, 36, 39, 40, 41, 46, 47, 48, 49, 50, 62];   //*BZ
var reclass_vector = [3, 4, 5, 0, 11, 12,  13,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 0,  0,  0,  0,  0,  0, 49, 50, 0];   //*BZ

// import QCN data
var qcn = ee.ImageCollection('projects/mapbiomas-workspace/SEEG/2022/QCN/QCN_30m_BR_v2_0_1')
            .mosaic();
            
// import biomes raster
var biomes = ee.Image('projects/mapbiomas-workspace/AUXILIAR/biomas-2019-raster'); //* ok

// import states raster
var states = ee.Image('projects/mapbiomas-workspace/AUXILIAR/estados-2016-raster'); //* ok

// import Mapbiomas Collection 7.0
var colecao7 = ee.Image("projects/mapbiomas-workspace/public/collection7/mapbiomas_collection70_integration_v2"); //* ok

///////////////////////////////////////
/* @. Don't change below this line *///
///////////////////////////////////////

// get color-ramp module
var vis = {
    'min': 0,
    'max': 62,  //*BZ
    'palette': require('users/mapbiomas/modules:Palettes.js').get('classification7')  //*ok
};

// pre-definied palletes
var palt = require('users/gena/packages:palettes').matplotlib.viridis[7];
var pala = require('users/gena/packages:palettes').kovesi.rainbow_bgyr_35_85_c72[7];

// read products
var qcn_class = qcn.select(['qcnclass']);
var qcn_total = qcn.select(['total']);

// plot inspects
Map.addLayer(qcn_class, vis, 'QCN_Class');
Map.addLayer(qcn_total, {min: 0, max: 168, palette: palt}, 'QCN_Total');

// for each biome
list_biomes.forEach(function(biome_i) {
  // define raw 'c_total' for the biome [i]
  var biome_tot = qcn_total.updateMask(biomes.eq(biome_i));
  // subset 'qcnclass' for the biome [i]
  var qcn_class_i = qcn_class.updateMask(biomes.eq(biome_i));
  //Map.addLayer(biome_tot, {min: 0, max: 168, palette: palt}, 'tot' + ' '+ biome_i );
  //Map.addLayer(qcn_class_i, vis , 'class biome' + ' '+ biome_i );
  
  // create empty recipes
  var image_static = ee.Image([]);
  var temp = ee.Image([]);
  var biome_name;
  
  // for each year
  list_mapb_years.forEach(function(year_j) {
    // subset mapbiomas collection 6.0 for the biome [i] and year [j]
    var mapbiomas_ij = colecao7.select(['classification_' + year_j])
                               .updateMask(biomes.eq(biome_i));
    
    // reclassify mapbiomas by using the obj 'reclass_vector' as general rule
    var mapbiomas_reclass_ij = mapbiomas_ij.remap(raw_mapbiomas, reclass_vector);
    //Map.addLayer(mapbiomas_reclass_ij, vis, biome_i + ' ' + year_j + ' ' + 'reclass');
    
    // for each QCN class
    list_qcn_classes.forEach(function(class_k) {
      //print (biome_i + ' ' + year_j + ' ' + class_k);
      // subset qcn classesonly to class [k]
      var qcn_class_ik = qcn_class_i.updateMask(qcn_class_i.eq(class_k));
      //Map.addLayer(qcn_class_ik, vis, 'qcn' + ' ' + class_k);
      
      // mask mapbiomas for biome [i] and year [j] for the qcn class [k]
      var mapbiomas_reclass_ijk= mapbiomas_reclass_ij.updateMask(qcn_class_ik);
      //Map.addLayer(mapbiomas_reclass_ijk, vis, 'mapbiomas' + ' when qcn == ' + class_k);
      
      // compute discordances between qcn and mapbiomas
      var discordance_ijk = mapbiomas_reclass_ijk.updateMask(mapbiomas_reclass_ijk.neq(class_k));
      //Map.addLayer(discordance_ijk, vis, 'discordance' + ' when qcn == ' + class_k);
      
      // perform the correction of 'c_total' for the biome [i], year [j] and class [k]
      // when biome equals amazonia
      if (biome_i == 1) {
        biome_name = 'amazonia';           // Diff Version                    // V1                // V2
        
        // Definir o kernel para a operação do vizinho mais próximo ou focal
        // Kernel 4pixel 
        var kernel1 = ee.Kernel.fixed(2, 2, [[1, 1], [1, 1]], -1, -1);

        // Calcular o modo (valor mais frequente) no vizinho mais próximo ou focal
        var mode1 = discordance_ijk.reduceNeighborhood({
          reducer: ee.Reducer.mode(),
          kernel: kernel1
        });

        // Criar uma máscara para cada classe discordante
        var mask_3 = discordance_ijk.eq(3);
        var mask_4 = discordance_ijk.eq(4);
        var mask_5 = discordance_ijk.eq(5);
        var mask_11 = discordance_ijk.eq(11);
        var mask_12 = discordance_ijk.eq(12);

  // Substituir os valores discordantes pela moda das respectivas classes
        var tot_rect = biome_tot
          .where(mask_3, mode1.updateMask(mask_3))
          .where(mask_4, mode1.updateMask(mask_4))
          .where(mask_5, mode1.updateMask(mask_5))
          .where(mask_11, mode1.updateMask(mask_11))
          .where(mask_12, mode1.updateMask(mask_12));
      }     
       // when biome equals amazonia
      if (biome_i == 2) {
        biome_name = 'mata_atlantica';           
        
        // Definir o kernel para a operação do vizinho mais próximo ou focal
        var kernel2 = ee.Kernel.fixed(2, 2, [[1, 1], [1, 1]], -1, -1);

        // Calcular o modo (valor mais frequente) no vizinho mais próximo ou focal
        var mode2 = discordance_ijk.reduceNeighborhood({
          reducer: ee.Reducer.mode(),
          kernel: kernel2
        });

        // Criar uma máscara para cada classe discordante
        var ma_mask_3 = discordance_ijk.eq(3);
        var ma_mask_4 = discordance_ijk.eq(4);
        var ma_mask_5 = discordance_ijk.eq(5);
        var ma_mask_11 = discordance_ijk.eq(11);
        var ma_mask_12 = discordance_ijk.eq(12);
        var ma_mask_13 = discordance_ijk.eq(13);
        var ma_mask_49 = discordance_ijk.eq(49);
        var ma_mask_50 = discordance_ijk.eq(50);

  // Substituir os valores discordantes pela moda das respectivas classes
        var tot_rect = biome_tot
          .where(ma_mask_3, mode2.updateMask(ma_mask_3))
          .where(ma_mask_4, mode2.updateMask(ma_mask_4))
          .where(ma_mask_5, mode2.updateMask(ma_mask_5))
          .where(ma_mask_11, mode2.updateMask(ma_mask_11))
          .where(ma_mask_12, mode2.updateMask(ma_mask_12))
          .where(ma_mask_13, mode2.updateMask(ma_mask_13))
          .where(ma_mask_49, mode2.updateMask(ma_mask_49))
          .where(ma_mask_50, mode2.updateMask(ma_mask_50));
      } 
        
      // when biome equals to pantanal
      if (biome_i == 3) {
        biome_name = 'pantanal';    // Diff Version                          // V1                 // V2
        
        // Definir o kernel para a operação do vizinho mais próximo ou focal
        var kernel3 = ee.Kernel.fixed(2, 2, [[1, 1], [1, 1]], -1, -1);

        // Calcular o modo (valor mais frequente) no vizinho mais próximo ou focal
        var mode3 = discordance_ijk.reduceNeighborhood({
          reducer: ee.Reducer.mode(),
          kernel: kernel3
        });

        // Criar uma máscara para cada classe discordante
        var pan_mask_3 = discordance_ijk.eq(3);
        var pan_mask_4 = discordance_ijk.eq(4);
        //var pan_mask_5 = discordance_ijk.eq(5);
        var pan_mask_11 = discordance_ijk.eq(11);
        var pan_mask_12 = discordance_ijk.eq(12);
        var pan_mask_13 = discordance_ijk.eq(13);

  // Substituir os valores discordantes pela moda das respectivas classes
        var tot_rect = biome_tot
          .where(pan_mask_3, mode3.updateMask(pan_mask_3))
          .where(pan_mask_4, mode3.updateMask(pan_mask_4))
          //.where(pan_mask_5, mode3.updateMask(pan_mask_5))
          .where(pan_mask_11, mode3.updateMask(pan_mask_11))
          .where(pan_mask_12, mode3.updateMask(pan_mask_12))
          .where(pan_mask_13, mode3.updateMask(pan_mask_13));
      } 
      
      // when biome equals to cerrado
      if (biome_i == 4) {
        biome_name = 'cerrado';   
        
        // Definir o kernel para a operação do vizinho mais próximo ou focal
       var kernel4 = ee.Kernel.fixed(2, 2, [[1, 1], [1, 1]], -1, -1);
       
       var mode4 = discordance_ijk.reduceNeighborhood({
         reducer: ee.Reducer.mode(),
         kernel: kernel4
       });
       
        // Criar uma máscara para cada classe discordante
        var cer_mask_3 = discordance_ijk.eq(3);
        var cer_mask_4 = discordance_ijk.eq(4);
        var cer_mask_5 = discordance_ijk.eq(5);
        var cer_mask_11 = discordance_ijk.eq(11);
        var cer_mask_12 = discordance_ijk.eq(12);
        var cer_mask_49 = discordance_ijk.eq(49);
        var cer_mask_50 = discordance_ijk.eq(50);
        
        
  // Substituir os valores discordantes pela moda das respectivas classes
        var tot_rect = biome_tot
          .where(cer_mask_3, mode4.updateMask(cer_mask_3))
          .where(cer_mask_4, mode4.updateMask(cer_mask_4))
          .where(cer_mask_5, mode4.updateMask(cer_mask_5))
          .where(cer_mask_11, mode4.updateMask(cer_mask_11))
          .where(cer_mask_12, mode4.updateMask(cer_mask_12))
          .where(cer_mask_49, mode4.updateMask(cer_mask_49))
          .where(cer_mask_50, mode4.updateMask(cer_mask_50));
      } 
      
      // when biome equal to caatinga
      if (biome_i == 5) {
        biome_name = 'caatinga';     // Diff Version                         // V1                 // V2
        
        var kernel5 =  ee.Kernel.fixed(2, 2, [[1, 1], [1, 1]], -1, -1);
        // Calcular o modo (valor mais frequente) no vizinho mais próximo ou focal
       var mode5 = discordance_ijk.reduceNeighborhood({
         reducer: ee.Reducer.mode(),
         kernel: kernel5
         });
      // Criar uma máscara para cada classe discordante
        var caa_mask_3 = discordance_ijk.eq(3);
        var caa_mask_4 = discordance_ijk.eq(4);
        var caa_mask_5 = discordance_ijk.eq(5);
        var caa_mask_11 = discordance_ijk.eq(11);
        var caa_mask_12 = discordance_ijk.eq(12);
        var caa_mask_13 = discordance_ijk.eq(13);
        var caa_mask_49 = discordance_ijk.eq(49);
        var caa_mask_50 = discordance_ijk.eq(50);
        
        
  // Substituir os valores discordantes pela moda das respectivas classes
        var tot_rect = biome_tot
          .where(caa_mask_3, mode5.updateMask(caa_mask_3))
          .where(caa_mask_4, mode5.updateMask(caa_mask_4))
          .where(caa_mask_5, mode5.updateMask(caa_mask_5))
          .where(caa_mask_11, mode5.updateMask(caa_mask_11))
          .where(caa_mask_12, mode5.updateMask(caa_mask_12))
          .where(caa_mask_13, mode5.updateMask(caa_mask_13))
          .where(caa_mask_49, mode5.updateMask(caa_mask_49))
          .where(caa_mask_50, mode5.updateMask(caa_mask_50));
      } 
      
      // when biome equal to pampa
      if (biome_i == 6) {
        biome_name = 'pampa';
        
        var kernel6 =  ee.Kernel.fixed(2, 2, [[1, 1], [1, 1]], -1, -1);
        // Calcular o modo (valor mais frequente) no vizinho mais próximo ou focal
       var mode6 = discordance_ijk.reduceNeighborhood({
         reducer: ee.Reducer.mode(),
         kernel: kernel6
         });
      // Criar uma máscara para cada classe discordante
        var pam_mask_3 = discordance_ijk.eq(3);
        //var pam_mask_4 = discordance_ijk.eq(4);
        //var pam_mask_5 = discordance_ijk.eq(5);
        var pam_mask_11 = discordance_ijk.eq(11);
        var pam_mask_12 = discordance_ijk.eq(12);
        var pam_mask_49 = discordance_ijk.eq(49);
        var pam_mask_50 = discordance_ijk.eq(50);
        
        
  // Substituir os valores discordantes pela moda das respectivas classes
        var tot_rect = biome_tot
          .where(pam_mask_3, mode6.updateMask(pam_mask_3))
          //.where(pam_mask_4, mode6.updateMask(pam_mask_4))
          //.where(pam_mask_5, mode6.updateMask(pam_mask_5))
          .where(pam_mask_11, mode6.updateMask(pam_mask_11))
          .where(pam_mask_12, mode6.updateMask(pam_mask_12))
          //.where(pam_mask_13, mode6.updateMask(pam_mask_13))
          .where(pam_mask_49, mode6.updateMask(pam_mask_49))
          .where(pam_mask_50, mode6.updateMask(pam_mask_50));
      } 
      

      // bind corrections of each class into a unique 'temp' obj 
      if (class_k == 3) {
        temp = tot_rect;
      }
      if (class_k == 4) {
        temp = temp.blend(tot_rect.updateMask(qcn_class_i.eq(class_k)));
      }
      if (class_k == 5) {
        temp = temp.blend(tot_rect.updateMask(qcn_class_i.eq(class_k)));
      }
      if (class_k == 11) {
        temp = temp.blend(tot_rect.updateMask(qcn_class_i.eq(class_k)));
      }
      if (class_k == 12) {
        temp = temp.blend(tot_rect.updateMask(qcn_class_i.eq(class_k)));
      }
      if (class_k == 13) {
        temp = temp.blend(tot_rect.updateMask(qcn_class_i.eq(class_k)));
      }
      if (class_k == 49) {
        temp = temp.blend(tot_rect.updateMask(qcn_class_i.eq(class_k)));
      }
      if (class_k == 50) {
        temp = temp.blend(tot_rect.updateMask(qcn_class_i.eq(class_k)));
      
          
      // rename band
      temp = temp.rename('total_' + year_j);

      // insert into recipe
      image_static = image_static.addBands(temp);
      }
      
    }); // end of class [k]

  }); // end of year [j]
  
  // retrieve resolution propertie
  if (biome_name == 'amazonia') {
    var res = 250;
  } else {
     res = 30;
  }
  
  // insert properties into image
  image_static = image_static.set({biome: ee.String(biome_name)})
                             .set({version: version})
                             .set({resolution: res});
                             
  // plot results
  print (biome_name, image_static);
  Map.addLayer(image_static.select(['total_1985']), {min: 0, max: 168, palette: palt}, biome_name + ' rect 1985');
  
  // export results as GEE asset
  // when biome equal to amazonia, export with 250 x 250 m//pixel
  if (biome_name == 'amazonia') {
    Export.image.toAsset({
      "image": image_static,
      "description": biome_name,
      "assetId": dir_output + '/' + biome_name + '_rect_total_v' + version,
      "scale": 250,
      "pyramidingPolicy": {
          '.default': 'mode'
      },
      "maxPixels": 1e13,
      "region": image_static.geometry()
  });  
  // when biome is different of amazonia, export with 30 x 30 m pixel
  } else {
    Export.image.toAsset({
      "image": image_static,
      "description": biome_name,
      "assetId": dir_output + '/' + biome_name + '_rect_total_v' + version,
      "scale": 30,
      "pyramidingPolicy": {
          '.default': 'mode'
      },
      "maxPixels": 1e13,
      "region": image_static.geometry()
  });  
  }

}); // end of biome [i]
