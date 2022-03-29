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

For the calculations of SEEG Land Use Change Sector is to classify yearly transitions as ‘deforestation’ or ‘regeneration’ of the natural vegetation. With the generation of these spatial masks, spurious transitions, resulting from errors of classification, are removed. 

# 1.1 Temporal_filter.js

The second step is the application of a temporal filter in every pixel, of at least six years (three years before the transition, the year of transition, and two years after the transition). This filtering identifies pixels with a classification over time consistent with the expected transition. For instance, a pixel is identified as deforestation only when the transition from natural vegetation to anthropic land use is preceded by three years of classification as stable natural vegetation, followed by three years (including the transition year) as anthropic land use. To minimize the uncertainty associated with the years at the beginning and the end of the time series, the filtering rules consider more years before or after the given year, depending on the availability of maps in the time series. By making these criteria more flexible at both ends of the time series, this approach allows us to generate estimates for the period of 1986 to 2019. 

<div>
    <img src='aux/Zimbres_et_al_2022_SEEG_BR_Figures.jpg' height='auto' width='160' align='center'>
  <h1> Temporal rules for the generation of the deforestation mask (natural vegetation loss) and the regeneration mask (natural vegetation gain) for each year of the MapBiomas time series. </h1>
</div>


```javascript
var Def_filter = ee.Image('projects/ee-seeg-brazil/assets/collection_9/v1/1_0_Deforestation_masks');
Map.addLayer(Def_filter.select('deforestation2020').selfMask(), {'min': 0,'max': 1, 'palette': '#FFFFFF,#FF0000'},"Deforestation_2020");

var Reg_filter = ee.Image('projects/ee-seeg-brazil/assets/collection_9/v1/1_0_Regeneration_masks');
Map.addLayer(Reg_filter.select('regeneration2020').selfMask(), {'min': 0,'max': 1, 'palette': '#FFFFFF,#00FF00'},"Regeneration_2020") 
```
[Link to script](https://code.earthengine.google.com/2168f9616bebe4834b4dd9fe7f328c43)


# 2.0 Masks_stable.js

Masks stable annual coverage basemaps from a MapBiomas collection (eg. col 6.0)

```javascript
// Acessing Asset
var Mask_stable = ee.ImageCollection('projects/ee-seeg-brazil/assets/collection_9/v1/2_1_Mask_stable')
  .toBands()
  .aside(print);
  
// Palettes
var palettes = require('users/mapbiomas/modules:Palettes.js');
var vis = {
    'min': 0,
    'max': 49,
    'palette': palettes.get('classification6')
    };

//Map Add Layer   
Map.addLayer(Mask_stable.select(['SEEG_c9_v1_2020_classification_2020']).clip(roi), vis, '2_1_Mask_stable_ROI');
Map.addLayer(Mask_stable.select(['SEEG_c9_v1_2020_classification_2020']).clip(BiomesBR), vis, '2_1_Mask_stable_Biomes_BR',false);
  
```
[Link to script](https://code.earthengine.google.com/d08ff95922dfe6689e1bc221b0c7f0c5)


