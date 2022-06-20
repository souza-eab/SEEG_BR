// Rectify 'c_total' of QCN per native vegetation classe by using Mapbiomas Collection 6.0 LCLUC as reference  
// For any issue/bug, please write to <dhemerson.costa@ipam.org.br>, <> and/or <edriano.souza@ipam.org.br>
// SEEG/Observatório do Clima and IPAM
// Current version: 2.0

// @ UPDATE HISTORIC @ //
// 1:  Compute number of divergences by comparing qcn past vegetation and mapbiomas 6.0 (per year)
// 1.1 Perform 'c_total' correction for the Cerrado biome (1985) 
// 1.2 Perform 'c_total' correction for the Cerrado biome from 1985 to 2020 (cumulative and static)
// 2.0 Perform 'c_total' correction for all biomes from 1985 to 2020 

//* @ Set user parameters *//
var dir_output = 'projects/mapbiomas-workspace/SEEG/2022/QCN/QCN_30m_rect';
//var version = '1'; // Version test - 1985- 2020
var version = 'v1'; // Version QA (Weighted Average = Stk * %Area)

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
                       2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020
                       ];
                       
// define QCN classes to be rectified
var list_qcn_classes = [3,  // Forest formation
                        4,  // Savanna formation 
                        5,  // Mangrove
                        11, // Wetland
                        12, // Grassland
                        49, // Wooded Restinga
                        ];

// define mapbiomas colelction 6.0 reclassification matrix
var raw_mapbiomas  = [3, 4, 5, 9, 11, 12, 13, 15, 20, 21, 23, 24, 25, 29, 30, 31, 32, 33, 39, 40, 41, 46, 47, 48, 49];   
var reclass_vector = [3, 4, 5, 0, 11, 12,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 49];   

// import QCN data
var qcn = ee.ImageCollection('projects/mapbiomas-workspace/SEEG/2021/QCN/QCN_30m_c')
            .mosaic();
            
// import biomes raster
var biomes = ee.Image('projects/mapbiomas-workspace/AUXILIAR/biomas-2019-raster');

// import states raster
var states = ee.Image('projects/mapbiomas-workspace/AUXILIAR/estados-2016-raster');

// import Mapbiomas Collection 6.0
var colecao6 = ee.Image("projects/mapbiomas-workspace/public/collection6/mapbiomas_collection60_integration_v1");

///////////////////////////////////////
/* @. Don't change below this line *///
///////////////////////////////////////

// get color-ramp module
var vis = {
    'min': 0,
    'max': 49,
    'palette': require('users/mapbiomas/modules:Palettes.js').get('classification6')
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
    var mapbiomas_ij = colecao6.select(['classification_' + year_j])
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
        biome_name = 'amazonia';
        var tot_rect = biome_tot.where(discordance_ijk.eq(3), 162.89128848); //* 164.71443
            tot_rect = tot_rect.where(discordance_ijk.eq(4),  173.05); //* 165.49274
            tot_rect = tot_rect.where(discordance_ijk.eq(5),  38.52); //* 38.30
            tot_rect = tot_rect.where(discordance_ijk.eq(11), 58.20); //* X //* Include class 11 Wetland  
            tot_rect = tot_rect.where(discordance_ijk.eq(12), 49.8300); //*110.339 //*Grassland >2X 
      }
      
      // when biome equals to mata atlantica
      if (biome_i == 2) {
        biome_name = 'mata_atlantica';
        var tot_rect = biome_tot.where(discordance_ijk.eq(3), 127.8127795);  //* 121.78
            tot_rect = tot_rect.where(discordance_ijk.eq(4),  48.2497191);   //* 47.65
            tot_rect = tot_rect.where(discordance_ijk.eq(5),  127.8127795);  //* 83.06
            tot_rect = tot_rect.where(discordance_ijk.eq(11), 103.75);       //* 103.75 //* Include class 
            tot_rect = tot_rect.where(discordance_ijk.eq(12), 13.89369925);  //* 13.91
            tot_rect = tot_rect.where(discordance_ijk.eq(13), 83.06);        //* 83.06  //* Include class 
            tot_rect = tot_rect.where(discordance_ijk.eq(49), 13.89369925);  //* 104.70 //* Include class 

      }
      
      // when biome equals to pantanal
      if (biome_i == 3) {
        biome_name = 'pantanal';
        var tot_rect = biome_tot.where(discordance_ijk.eq(3), 98.10198434); //* 118.77 
            tot_rect = tot_rect.where(discordance_ijk.eq(4),  37.53344167); //* 39.84
            tot_rect = tot_rect.where(discordance_ijk.eq(11), 25.21);      //*25.21 //*Include class 
            tot_rect = tot_rect.where(discordance_ijk.eq(12), 24.01225878); //* 23.24
      }
      
      // when biome equals to cerrado
      if (biome_i == 4) {
        biome_name = 'cerrado';
        // when discordance equal to forest formation
        var //tot_rect = biome_tot.where(states.eq(11).and(discordance_ijk.eq(3)), 79.80779548);      // RO //*Exclude
            tot_rect = biome_tot.where(states.eq(15).and(discordance_ijk.eq(3)), 74.03587313);        // PA //*Include
            tot_rect = tot_rect.where(states.eq(17).and(discordance_ijk.eq(3)),  64.27657895);        // TO 67.34568565
            tot_rect = tot_rect.where(states.eq(21).and(discordance_ijk.eq(3)),  63.91879963);        // MA 62.68812168
            tot_rect = tot_rect.where(states.eq(22).and(discordance_ijk.eq(3)),  66.068241);          // PI 61.74337814
            tot_rect = tot_rect.where(states.eq(29).and(discordance_ijk.eq(3)),  67.18329178);        // BA 62.51979601
            tot_rect = tot_rect.where(states.eq(31).and(discordance_ijk.eq(3)),  70.08654663);        // MG 64.73412216
            tot_rect = tot_rect.where(states.eq(35).and(discordance_ijk.eq(3)),  84.98800092);        // SP 80.45093149
            tot_rect = tot_rect.where(states.eq(41).and(discordance_ijk.eq(3)),  74.98246537);        // PR 74.80437684
            tot_rect = tot_rect.where(states.eq(50).and(discordance_ijk.eq(3)),  99.27158356);        // MS 99.18537083
            tot_rect = tot_rect.where(states.eq(51).and(discordance_ijk.eq(3)),  93.55501847);        // MT 97.45652989
            tot_rect = tot_rect.where(states.eq(52).and(discordance_ijk.eq(3)),  70.01143121);        // GO 64.72447117
            tot_rect = tot_rect.where(states.eq(53).and(discordance_ijk.eq(3)),  66.8596976);         // DF 71.41565647
            
        // when discordance equal to other types of NV
            tot_rect = tot_rect.where(discordance_ijk.eq(4),  39.99);       //*41.32 
            tot_rect = tot_rect.where(discordance_ijk.eq(5),  38.26);       //*38.26 
            tot_rect = tot_rect.where(discordance_ijk.eq(11), 36.21);       //*36.21  Include Class
            tot_rect = tot_rect.where(discordance_ijk.eq(12), 24.75375483); //*24.94  
            tot_rect = tot_rect.where(discordance_ijk.eq(49), 34.76);       //*34.76 Include Class  
      }
      
      // when biome equal to caatinga
      if (biome_i == 5) {
        biome_name = 'caatinga';
        var tot_rect = biome_tot.where(discordance_ijk.eq(3), 101.8751897); //* 68.53
            tot_rect = tot_rect.where(discordance_ijk.eq(4),  19.87407942); //* 20.30
            tot_rect = biome_tot.where(discordance_ijk.eq(5), 170.54); //* 20.30 //* Include Class
            tot_rect = tot_rect.where(discordance_ijk.eq(12), 12.83059147); //* 15.46
            tot_rect = tot_rect.where(discordance_ijk.eq(49), 147.09); //* Include Class 
      }
      
      // when biome equal to pampa
      if (biome_i == 6) {
        biome_name = 'pampa';
        var tot_rect = biome_tot.where(discordance_ijk.eq(3), 115.0286131); //* 76.03
            tot_rect = tot_rect.where(discordance_ijk.eq(11),  11.74); //*Include Class
            tot_rect = tot_rect.where(discordance_ijk.eq(12), 4.560158311); //* 21.84
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
      if (class_k == 49) {
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
    var res = 30;
  }
  
  // insert properties into image
  image_static = image_static.set({biome: ee.String(biome_name)})
                             .set({version: version})
                             .set({resolution: res});
                             
  // plot results
  print (biome_name, image_static);
  Map.addLayer(image_static.select(['total_2020']), {min: 0, max: 168, palette: palt}, biome_name + ' rect 2020');
  
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


