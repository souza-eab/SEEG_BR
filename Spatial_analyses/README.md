# 1.0 Deforestation_and_Regeneretaion.js

The first step for the calculations of SEEG Land Use Change Sector is to classify yearly transitions as ‘deforestation’ or ‘regeneration’ of the natural vegetation. Building these masks involves, first, the reclassification of all land cover classes from the MapBiomas time series into two classes: natural vegetation and anthropic land use. Based on the MapBiomas collection 6.0 [legend](https://mapbiomas-br-site.s3.amazonaws.com/downloads/Colecction%206/Cod_Class_legenda_Col6_MapBiomas_BR.pdf), these two classes include:

**Natural Vegetation:** Forest Formation (3), Savanna Formation (4), Mangrove (5), Wetland (11), Grassland Formation (12), Other non Forest Formation (13), and Wooded Restinga (49).

**Anthropic Land Use:** Forest Plantation (9), Pasture (15), Sugar Cane (20), Mosaic of Agriculture and Pasture (21), Urban Infrastructure (24), Other non Vegetated Areas (25), Mining (30), Aquaculture (31), Perennial Crop (36), Soybean (39), and Other Temporary Crops (41).

```javascript
var Def = ee.Image('projects/ee-seeg-brazil/assets/collection_9/v1/1_0_Deforestation_masks');
Map.addLayer(Def.select('deforestation2020').selfMask(), {'min': 0,'max': 1, 'palette': '#FFFFFF,#FF0000'},"Deforestation_2020");

var Reg = ee.Image('projects/ee-seeg-brazil/assets/collection_9/v1/1_0_Regeneration_masks');
Map.addLayer(Reg.select('regeneration2020').selfMask(), {'min': 0,'max': 1, 'palette': '#FFFFFF,#00FF00'},"Regeneration_2020") 
```
[Link to script](https://code.earthengine.google.com/4051918e07c956ad8524957dff747d83)


# 1.1 Temporal_filter.js

For the calculations of SEEG Land Use Change Sector is to classify yearly transitions as ‘deforestation’ or ‘regeneration’ of the natural vegetation. With the generation of these spatial masks, spurious transitions, resulting from errors of classification, are removed. 


```javascript
var Def_filter = ee.Image('projects/ee-seeg-brazil/assets/collection_9/v1/1_1_Temporal_filter_deforestation');
Map.addLayer(Def.select('deforestation2020').selfMask(), {'min': 0,'max': 1, 'palette': '#FFFFFF,#FF0000'},"Deforestation_2020");

var Reg = ee.Image('projects/ee-seeg-brazil/assets/collection_9/v1/1_0_Regeneration_masks');
Map.addLayer(Reg.select('regeneration2020').selfMask(), {'min': 0,'max': 1, 'palette': '#FFFFFF,#00FF00'},"Regeneration_2020") 
```
[Link to script](https://code.earthengine.google.com/4051918e07c956ad8524957dff747d83)


