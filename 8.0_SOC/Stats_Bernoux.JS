// BBOX
var geometry = ee.Geometry.Polygon(
        [[[-74.34040691705002, 5.9630086351511690],
                [-74.34040691705002, -34.09134700746099],
                [-33.64704754205002, -34.09134700746099],
                [-33.64704754205002, 5.9630086351511690]]]);

// Asset Static 

///AP
var areasProtegidas_porAno = ee.ImageCollection('projects/mapbiomas-workspace/AUXILIAR/areas-protegidas-por-ano-2019')
  .toBands();

var oldBands_ap = areasProtegidas_porAno.bandNames();
var newBands_ap = oldBands_ap.map(function(bandName){
  return ee.String(bandName).split('_').get(0);
});

areasProtegidas_porAno = areasProtegidas_porAno.select(oldBands_ap,newBands_ap);

///Transitions
var transitions = ee.Image('projects/mapbiomas-workspace/SEEG/2021/Col9/SEEG_Transicoes_2021_c6_stacked');

// band: transicao_1992_1993
print('transitions',transitions);

// variaveis estaticas:

var cos = ee.Image('projects/mapbiomas-workspace/SEEG/2022/SOC/Bernoux/Bernoux');
// var cos = ee.Image('projects/mapbiomas-workspace/SEEG/2022/SOC/Embrapa/Embrapa_BR_SOCstock_0_30cm_t_ha');

var municipios = ee.Image('projects/ee-seeg-brazil/assets/collection_9/v1/mun_BR')
  .multiply(10);
var biomes = ee.Image('projects/ee-seeg-brazil/assets/collection_9/v1/Biomes_BR_tif');

var territory = municipios.add(biomes);

// Map.addLayer(territory.randomVisualizer(),{},'territory');


/// Aplly functions to sum in areas of transition annual 

transitions.bandNames()
.evaluate(function(bandnames){
  
  bandnames.forEach(function(band){
    
    var split = band.split('_');
    
    var year_init = split[1];
    var year_end = split[2];
    
    var ap_year_init = areasProtegidas_porAno.select('ap' + year_init).multiply(10).unmask(10);
    var ap_year_end = areasProtegidas_porAno.select('ap' + year_end).unmask(0);
    
    var ap_years = ap_year_init.add(ap_year_end);
    
    // Map.addLayer(ap_year_init)
    
    var years_transition = band.replace('transicao_','');
    
    var transition = transitions.select(band);
    
    // print(band,transition);
    // Map.addLayer(transition.randomVisualizer(),{},band);
    
    var territory_year = territory.multiply(100)
      .add(ap_years);
    
    var reduce = ee.Image.pixelArea().divide(1e6)
      .multiply(cos)
      .addBands(transition)
      .addBands(territory_year)
      .reduceRegion({
        reducer:ee.Reducer.sum().group(1,'territory').group(1,'transition'),
        geometry:geometry,
        scale:30,
        // crs:,
        // crsTransform:,
        // bestEffort:,
        maxPixels:1e11,
        // tileScale:
      });
      
    reduce = ee.List(ee.Dictionary(reduce).get('groups'));
      
    // print('reduce',reduce);
      
    var features = reduce.map(function(obj_n0){
      obj_n0 = ee.Dictionary(obj_n0);
      
      var groups = ee.List(obj_n0.get('groups'));
      
      return ee.FeatureCollection(groups.map(function(obj_n1){
          
          obj_n1 = ee.Dictionary(obj_n1);

          var territory  = ee.Number(obj_n1.get('territory'));
          
          var ap_prev = territory.mod(100).mod(10);
          var ap_post = territory.mod(10);
          
          
          territory = territory.divide(100).int();
          var biome = territory.mod(10);
          var municipio = territory.divide(10).int();
          var transition = ee.Number(obj_n0.get('transition'));
          
          var transition_prev = transition.mod(10);
          var transition_post = transition.divide(10000).int();
          
          return ee.Feature(null)
            .set({
              'Estoque de Carbono T/km':obj_n1.get('sum'),
              'biome':biome,
              'municipio':municipio,
              'transition':transition,
              'transition_prev':transition_prev,
              'transition_post':transition_post,
              'years_transition':years_transition,
              'ap_prev':ap_prev,
              'ap_post':ap_post,
            });
      }));
      
    });
    
  
    var table = ee.FeatureCollection(features).flatten();
  
    print('table',table.limit(10));
  
    var description = 'transitions-stats-v1-'+years_transition;
  
    Export.table.toDrive({
      collection:table,
      description:description,
      folder:'seeg-stats-cos',
      fileNamePrefix:description,
      fileFormat:'CSV', 
    });
  
  });
});
