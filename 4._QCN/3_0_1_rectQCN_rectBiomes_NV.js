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
var dir_output = 'projects/mapbiomas-workspace/SEEG/2022/QCN/QCN_30m_BR_v2_0_2_Rect';
var version = '2';

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
var list_mapb_years = [1985, 1986, 1987, 1988, 1989, 1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997,
                       1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010,
                       2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022
                       ];
                       
// define QCN classes to be rectified
var list_qcn_classes = [3,  // Forest formation
                        4,  // Savanna formation 
                        5,  // Mangrove
                        6,  // Floodable Forest (beta)
                        11, // Wetland
                        12, // Grassland 
                        49, // Wooded Restinga
                        50]; // Shrubby Restinga //*BZ

// define mapbiomas colelction 7.0 reclassification matrix
// var raw_mapbiomas  = [3, 4, 5, 6,  9, 11, 12, 13, 15, 20, 21, 23, 24, 25, 29, 30, 31, 32, 33, 36, 39, 40, 41, 46, 47, 48, 49, 50, 62];   //*BZ
// var reclass_vector = [3, 4, 5, 6,  0, 11, 12,  13,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 0,  0,  0,  0,  0,  0, 49, 50, 0];   //*B
var raw_mapbiomas  = [3, 4, 5, 6,  9, 11, 12, 13, 15, 20, 21, 23, 24, 25, 29, 30, 31, 32, 33, 36, 39, 40, 41, 46, 47, 48, 49, 50, 62];   //*Edriano
var reclass_vector = [3, 4, 5, 6,  0, 11, 12,  13,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 0,  0,  0,  0,  0,  0, 49, 50, 0];   //*Edriano


// import QCN data
var qcn = ee.ImageCollection('projects/mapbiomas-workspace/SEEG/2022/QCN/QCN_30m_BR_v2_0_1')
            .mosaic();
            
// import biomes raster
var biomes = ee.Image('projects/mapbiomas-workspace/AUXILIAR/biomas-2019-raster'); //* ok

// import states raster
var states = ee.Image('projects/mapbiomas-workspace/AUXILIAR/estados-2016-raster'); //* ok

// import Mapbiomas Collection 7.0
//var colecao7 = ee.Image("projects/mapbiomas-workspace/public/collection7/mapbiomas_collection70_integration_v2"); //* ok
// import Mapbiomas Collection 8.0
var colecao8 = ee.Image("projects/mapbiomas-workspace/public/collection8/mapbiomas_collection80_integration_v1"); //* ok


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
var qcn_class = qcn.select(['MB_C8']);
var qcn_total = qcn.select(['total']);

// plot inspects
Map.addLayer(qcn_class, vis, 'QCN_Class_MB_C8');
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
    var mapbiomas_ij = colecao8.select(['classification_' + year_j])
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
        var tot_rect = biome_tot.where(discordance_ijk.eq(3), 164.7144336);   // to 162.89128848 from 164,7144336
            tot_rect = tot_rect.where(discordance_ijk.eq(4),  165.49274450);  // to 173.05       from 165,49274450
            tot_rect = tot_rect.where(discordance_ijk.eq(5),  38.30);         // to 38.52        from 38,3
            tot_rect = tot_rect.where(discordance_ijk.eq(6),  164.7144336);                                          /// Version 8 - Collection
            tot_rect = tot_rect.where(discordance_ijk.eq(11),  58.20);        // Include Wetland v2;
            tot_rect = tot_rect.where(discordance_ijk.eq(12), 110.338709 );   // to 49.8300      from 110,338709
      }
      
      // when biome equals to mata atlantica
      if (biome_i == 2) {
        biome_name = 'mata_atlantica';    // Diff Version                    // V1                 // V2
        var tot_rect = biome_tot.where(discordance_ijk.eq(3), 121.781719);   // to 127.8127795   from 121,781719
            tot_rect = tot_rect.where(discordance_ijk.eq(4), 47.651060);     // to 48.2497191    from 47,651060
            tot_rect = tot_rect.where(discordance_ijk.eq(5),  83.06);        // to 127.812779    from 83,06
            tot_rect = tot_rect.where(discordance_ijk.eq(6),  121.781719);                                               /// Version 8 - Collection
            tot_rect = tot_rect.where(discordance_ijk.eq(11), 103.75);       // Include Wetland v2;
            tot_rect = tot_rect.where(discordance_ijk.eq(12), 13.89369925);  // to  13.89369925  from 13,91
            tot_rect = tot_rect.where(discordance_ijk.eq(13), 83.06);       //*BZ
            tot_rect = tot_rect.where(discordance_ijk.eq(49), 104.7000000);  // Wooded Restinga v2;
            tot_rect = tot_rect.where(discordance_ijk.eq(50), 104.7000000);  //*BZ
      }
      
      // when biome equals to pantanal
      if (biome_i == 3) {
        biome_name = 'pantanal';    // Diff Version                          // V1                 // V2
        var tot_rect = biome_tot.where(discordance_ijk.eq(3), 118.769014);   // to  98.10198434   from 118,769014
            tot_rect = tot_rect.where(discordance_ijk.eq(4),  39.84);        // to  37.53344167   from 39,84
            tot_rect = tot_rect.where(discordance_ijk.eq(6),  118.769014);                                                /// Version 8 - Collection
            tot_rect = tot_rect.where(discordance_ijk.eq(11), 23.240789);    // Include Wetland v2;
            tot_rect = tot_rect.where(discordance_ijk.eq(12), 25.2083135);
            tot_rect = tot_rect.where(discordance_ijk.eq(13), 25.2083135); //*BZ
      }
      
      // when biome equals to cerrado
      if (biome_i == 4) {
        biome_name = 'cerrado';   
        // when discordance equal to forest formation           // Diff Version                            // V1                 // V2
        var tot_rect = biome_tot.where(states.eq(11).and(discordance_ijk.eq(3)), 76.3);//*BZ        // RO // to  79.80779548    from 76.3
            tot_rect = tot_rect.where(states.eq(17).and(discordance_ijk.eq(3)),  67.34568565);      // TO // to  64.27657895    from 67,34568565
            tot_rect = tot_rect.where(states.eq(21).and(discordance_ijk.eq(3)),  62.68812168);      // MA // to  63.91879963    from 62,68812168
            tot_rect = tot_rect.where(states.eq(22).and(discordance_ijk.eq(3)),  61.74337814);      // PI // to  66.068241      from 61,74337814
            tot_rect = tot_rect.where(states.eq(29).and(discordance_ijk.eq(3)),  62.51979601);      // BA // to  67.18329178    from 62,51979601
            tot_rect = tot_rect.where(states.eq(31).and(discordance_ijk.eq(3)),  64.73412216);      // MG // to  70.08654663    from 64,73412216
            tot_rect = tot_rect.where(states.eq(35).and(discordance_ijk.eq(3)),  80.45093149);      // SP // to  84.98800092    from 80,45093149
            tot_rect = tot_rect.where(states.eq(41).and(discordance_ijk.eq(3)),  74.80437684);      // PR // to  74.98246537    from 74,80437684
            tot_rect = tot_rect.where(states.eq(50).and(discordance_ijk.eq(3)),  99.18537083);      // MS // to  99.27158356    from 99,18537083
            tot_rect = tot_rect.where(states.eq(51).and(discordance_ijk.eq(3)),  97.45652989);      // MT // to  93.55501847    from 97,45652989
            tot_rect = tot_rect.where(states.eq(52).and(discordance_ijk.eq(3)),  64.72447117);      // GO // to  70.01143121    from 64,72447117
            tot_rect = tot_rect.where(states.eq(53).and(discordance_ijk.eq(3)),  71.41565647);      // DF // to  66.8596976     from 71,41565647
            
        // when discordance equal to other types of NV   // Diff Version                                // V1                 // V2
            tot_rect = tot_rect.where(discordance_ijk.eq(4),  41.319679);                               // to  39.99          from 71,41565647    
            tot_rect = tot_rect.where(discordance_ijk.eq(5),  38.260000);                               // to  38.26          from 38,260000
            tot_rect = tot_rect.where(discordance_ijk.eq(11),  36.210000);                              // Include Wetland v2;
            tot_rect = tot_rect.where(discordance_ijk.eq(12), 24.941889);                               // to  24.75375483    from 24,941889
            tot_rect = tot_rect.where(discordance_ijk.eq(49), 34.760000);                               // Include Wooded Restinga v2; 
            tot_rect = tot_rect.where(discordance_ijk.eq(50), 34.760000); //*BZ
      }
      
      // when biome equal to caatinga
      if (biome_i == 5) {
        biome_name = 'caatinga';     // Diff Version                         // V1                 // V2
        var tot_rect = biome_tot.where(discordance_ijk.eq(3), 68.52608570);  // to  101.8751897    from 68,52608570
            tot_rect = tot_rect.where(discordance_ijk.eq(4),  20.29966574);  // to  19.87407942    from 20,29966574
            tot_rect = tot_rect.where(discordance_ijk.eq(5),  170.5400000);  // Include Wetland v2;
            tot_rect = tot_rect.where(discordance_ijk.eq(6),  68.52608570));                                              /// Version 8 - Collection
            tot_rect = tot_rect.where(discordance_ijk.eq(11), 36.21);
            tot_rect = tot_rect.where(discordance_ijk.eq(12), 15.45568408);  // to  12.83059147    from 15,45568408
            tot_rect = tot_rect.where(discordance_ijk.eq(13), 83.06);
            tot_rect = tot_rect.where(discordance_ijk.eq(49), 147.09000000); // Include Wooded Restinga v2; 
            tot_rect = tot_rect.where(discordance_ijk.eq(50), 147.09000000); //*BZ
      }
      
      // when biome equal to pampa
      if (biome_i == 6) {
        biome_name = 'pampa';
        var tot_rect = biome_tot.where(discordance_ijk.eq(3), 76.02510);   // to  115.0286131    from 76,02510
            // tot_rect = tot_rect.where(discordance_ijk.eq(5),  12.77);   // Exclude v2
            tot_rect = tot_rect.where(discordance_ijk.eq(6), 76.02510);                                                   /// Version 8 - Collection
            tot_rect = tot_rect.where(discordance_ijk.eq(11), 11.744348);  // Include Wetland v2;
            tot_rect = tot_rect.where(discordance_ijk.eq(12), 22.832296);  // to  4.560158311    from 22,83
            tot_rect = tot_rect.where(discordance_ijk.eq(49), 12.77); // Include Wooded Restinga v2; 
            tot_rect = tot_rect.where(discordance_ijk.eq(50), 12.77); //*BZ
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
      }
      if (class_k == 6) {
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
