// bounds
var geometry = ee.Geometry.Polygon(
        [[[-74.34040691705002, 5.9630086351511690],
                [-74.34040691705002, -34.09134700746099],
                [-33.64704754205002, -34.09134700746099],
                [-33.64704754205002, 5.9630086351511690]]]);


Map.addLayer(geometry, {}, 'Image_AMZ_', false)

//var image = ee.ImageCollection("projects/ee-seeg-brazil/assets/collection_9/v1/Biomes_BR_tif").filterMetadata('first', 'equals', '1').mosaic();
//Map.addLayer(image, {}, 'Image_AMZ_', false)

// Add Asset Biomes_BR (Source: IBGE && INCRA, 2019) 
var BiomesBR = ee.FeatureCollection('projects/ee-seeg-brazil/assets/collection_9/v1/Biomes_BR')
//.filter('CD_LEGENDA == "AMAZONIA"')
var geom = BiomesBR.geometry().bounds();
Map.addLayer(geom, {}, 'Image_AMZ_', false)

// variaveis dinamicas
var areasProtegidas_porAno = ee.ImageCollection('projects/ee-seeg-brazil/assets/collection_10/v1/areas-protegidas-por-ano-2021')
  .toBands();

var oldBands_ap = areasProtegidas_porAno.bandNames();
var newBands_ap = oldBands_ap.map(function(bandName){
  return ee.String(bandName).split('_').get(0);
});

areasProtegidas_porAno = areasProtegidas_porAno.select(oldBands_ap,newBands_ap);

// var transitions = ee.Image('projects/ee-seeg-brazil/assets/collection_10/v1/3_1_SEEG_Transitions_stacked');

// Version Mapbiomas (Runnig on server 'dev' .EE) // Next > commet rows 
var transitions = ee.Image('projects/mapbiomas-workspace/SEEG/2023/c10/3_1_SEEG_Transitions_stacked');

// band: transicao_1992_1993
//print('transitions',transitions);

var municipios = ee.Image('projects/ee-seeg-brazil/assets/collection_9/v1/mun_BR')
  .multiply(10);
var biomes = ee.Image('projects/ee-seeg-brazil/assets/collection_9/v1/Biomes_BR_tif');

var palette = ['#ffffcc', '#c7e9b4', '#7fcdbb', '#41b6c4', '#2c7fb8','#253494'];
var doyVis = {min:1, max:6, palette: palette}

Map.addLayer(biomes, doyVis, 'Biomas_SEEG')

var territory = municipios.add(biomes);

// Map.addLayer(territory.randomVisualizer(),{},'territory');

transitions.bandNames()
.evaluate(function(bandnames){
  
  //print(bandnames);
  
  bandnames.forEach(function(band){
    
    var split = band.split('_');
    
    var year_end = split[2];
    
    var ap_year_post = areasProtegidas_porAno.select('ap' + year_end).unmask(0);
    
    var years_transition = band.replace('transicao_','');
    
    var transition = transitions.select(band)
      .multiply(1000)
      //.add(emiss_removal_years);
    
    // print(band,transition);
    // Map.addLayer(transition.randomVisualizer(),{},band);
    
    var territory_year = territory.multiply(10)
      .add(ap_year_post);
    
    var reduce = ee.Image.pixelArea().divide(10000)//.reproject({crs:'EPSG:4326',scale:30})
      .addBands(transition)
      .addBands(territory_year)
      .reduceRegion({
        reducer:ee.Reducer.sum().group(1,'territory').group(1,'transition'),
        geometry:geometry,
        scale:30,
        // crs:,
        // crsTransform:,
        // bestEffort:,
        maxPixels:1e13,
        // tileScale:
      });
      
    reduce = ee.List(ee.Dictionary(reduce).get('groups'));
      
    //print('reduce',reduce);
      
    var features = reduce.map(function(obj_n0){
      obj_n0 = ee.Dictionary(obj_n0);
      
      var groups = ee.List(obj_n0.get('groups'));
      
      return ee.FeatureCollection(groups.map(function(obj_n1){
          
          obj_n1 = ee.Dictionary(obj_n1);

          var territory  = ee.Number(obj_n1.get('territory'));
          
          var ap_post = territory.mod(10);
          

          territory = territory.divide(10).int();
          var biome = territory.mod(10);
          //print(biome)
          var municipio = territory.divide(10).int();
          
          var transition = ee.Number(obj_n0.get('transition'));
          
            
          transition = transition.divide(1000).int();
          
          var transition_prev = transition.divide(10000).int();
          var transition_post = transition.mod(10000);
          
          var area = obj_n1.getNumber('sum');
          
          return ee.Feature(null)
            .set({
              'Area_ha':area,
              'Area_km2':area.divide(100),
              'biome':biome,
              'municipio':municipio,
              'transition':transition,
              'transition_prev':transition_prev,
              'transition_post':transition_post,
              'years_transition':years_transition,
              'ap':ap_post,
            });
      }));
      
    });
    
  
    var table = ee.FeatureCollection(features).flatten();
  
    //print('table',table.limit(10));
  
    var description = 'SEEG_Emissions-stats-c10_MB_v0_49_'+years_transition;
  
    Export.table.toDrive({
      collection:table,
      description:description,
      folder:'SEEG_Emissions-stats-c10_MB_v0_49_'+ 'attempt_v1',
      fileNamePrefix:description,
      fileFormat:'CSV', 
    });
  
  });
});
