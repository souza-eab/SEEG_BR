# About

The generation of annual transitions, upon which equations and emission factors are applied, are the basis of the SEEG Land Use Change Sector. From SEEG collection 8 onwards, the methodology for the quantification of these transitions became spatially explicit, taking advantage of the land use and land cover time series available from the MapBiomas Project. In the current approach, the annual land cover maps are stabilized and filtered to consolidate the main transitions taking place in each year, and then the calculations based on stocks and increments presented in the Fourth National Communication are applied (MCTI, 2020). In SEEG 9, launched in 2021, maps from the MapBiomas collection 6 were used, covering the period from 1985 to 2020, which resulted in a period of 1990-2020 for the SEEG results, to match the beginning of the time series covered by the Fourth National Communication.

Click on the title of each section to be redirected to an executable script.

# 1.0 [Deforestation and Regeneration masks.js](https://github.com/souza-eab/SEEG_BR/blob/main/1._Spatial_analyses/1.0_Deforestation_and_regeneration_masks.js)

The first step for the calculations of SEEG Land Use Change Sector is to classify yearly transitions as ‘deforestation’ or ‘regeneration’ of the natural vegetation. With the generation of these spatial masks, spurious transitions, resulting from errors of classification, are removed. Building these masks involves, first, the reclassification of all land cover classes from the MapBiomas time series into two classes: **Natural vegetation and Anthropic land use**. Based on the MapBiomas collection 6.0 [legend](https://mapbiomas-br-site.s3.amazonaws.com/downloads/Colecction%206/Cod_Class_legenda_Col6_MapBiomas_BR.pdf), these two classes include:

**Natural Vegetation:** Forest Formation (3), Savanna Formation (4), Mangrove (5), Wetland (11), Grassland Formation (12), Other non Forest Formation (13), and Wooded Restinga (49).

**Anthropic Land Use:** Forest Plantation (9), Pasture (15), Sugar Cane (20), Mosaic of Agriculture and Pasture (21), Urban Infrastructure (24), Other non Vegetated Areas (25), Mining (30), Aquaculture (31), Perennial Crop (36), Soybean (39), and Other Temporary Crops (41).

```javascript
var Def = ee.Image('projects/ee-seeg-brazil/assets/collection_9/v1/1_0_Deforestation_masks');
Map.addLayer(Def.select('deforestation2020').selfMask(), {'min': 0,'max': 1, 'palette': '#FFFFFF,#FF0000'},"Deforestation_2020");

var Reg = ee.Image('projects/ee-seeg-brazil/assets/collection_9/v1/1_0_Regeneration_masks');
Map.addLayer(Reg.select('regeneration2020').selfMask(), {'min': 0,'max': 1, 'palette': '#FFFFFF,#00FF00'},"Regeneration_2020") 
```
[Link to script](https://code.earthengine.google.com/4051918e07c956ad8524957dff747d83)

# 1.1 [Spatial_filter.js](https://github.com/souza-eab/SEEG_BR/blob/main/1._Spatial_analyses/1.1_Spatial_filter.js)

The second step is the application of a temporal filter in every pixel, of at least six years (three years before the transition, the year of transition, and two years after the transition). This filtering identifies pixels with a classification over time consistent with the expected transition. For instance, a pixel is identified as deforestation only when the transition from natural vegetation to anthropic land use is preceded by three years of classification as stable natural vegetation, followed by three years (including the transition year) as anthropic land use. To minimize the uncertainty associated with the years at the beginning and the end of the time series, the filtering rules consider more years before or after the given year, depending on the availability of maps in the time series.

<div align = 'center'>
<img src='https://github.com/souza-eab/SEEG_BR/blob/0a5d6297fd921315be95dc781be77c4e9848cc09/aux/Zimbres_et_al_2022_SEEG_BR_Figures.jpg' height='auto' width='1380'/>
</div>

```javascript
// Temporal rules for the generation of the deforestation mask (natural vegetation loss) and the regeneration mask (natural vegetation gain) for each year of the MapBiomas time series. 

var Def_filter = ee.Image('projects/ee-seeg-brazil/assets/collection_9/v1/1_0_Deforestation_masks');
Map.addLayer(Def_filter.select('deforestation2020').selfMask(), {'min': 0,'max': 1, 'palette': '#FFFFFF,#FF0000'},"Deforestation_filter_2020");

var Reg_filter = ee.Image('projects/ee-seeg-brazil/assets/collection_9/v1/1_0_Regeneration_masks');
Map.addLayer(Reg_filter.select('regeneration2020').selfMask(), {'min': 0,'max': 1, 'palette': '#FFFFFF,#00FF00'},"Regeneration_filter_2020") 
```
[Link to script](https://code.earthengine.google.com/2168f9616bebe4834b4dd9fe7f328c43)


# 2.0 [Stabilized_cover.js](https://github.com/souza-eab/SEEG_BR/blob/main/1._Spatial_analyses/2.0_Stabilized%20cover.js)

This script stabilizes the base maps from a MapBiomas collection (currently, col 6.0), for the generation of consistent transitions of land use and cover observed throughout the analyzed period within the deforestation and regeneration masks. This stabilizing analysis, applied to all years of the time series, includes the following steps <>:
(1) At the pixel level, frequency maps are generated, which count the number of years in which each pixel is classified as each given class;
(2) A stable natural vegetation layer is created, where only the pixels that were classified as natural vegetation (or waterbodies) for over 95% of the time series are kept, and the most frequent class is allocated to the whole time series; 
(3) An anthropic land use layer is created, where only the pixels that were classified as anthropic land use during 100% of the time series are kept, and the most frequent class is allocated to the whole time series; 
(4) Outside of these stabilized land cover layers, the areas where transition is possible have their original MapBiomas classes returned, but only within the deforestation and regeneration masks; 
(5) In these areas where transition within the masks is possible, the more frequent classes before and after the transition are allocated; 
(6) In the areas within the regeneration mask, natural class codes are multiplied by 100, in order to indicate secondary vegetation from primary vegetation; 
(7) Empty (unallocated) pixels after the previous step are indicative of an inconsistent and highly uncertain trajectory, and are left out of the final stabilized land cover maps.


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


# 3.0 [Annual Transition maps.js](https://github.com/souza-eab/SEEG_BR/blob/main/1._Spatial_analyses/3.0_Transitions_maps.js)

From the stabilized land cover maps, yearly transitions are generated by applying the following equation per pixel and pair of years:

Transition = t1 * 10000 + t2

This way, we end up with pairwise transition maps, in which the information of the classes in the first year (t1) and the second year (t2) are kept in a single code.


```javascript

// Add Asset  3.0 Transitions_maps
var listImages = ee.data.listAssets('projects/ee-seeg-brazil/assets/collection_9/v1/3_0_Transitions_maps').assets;

var image = ee.Image().select();

listImages.forEach(function(obj){
  image = image.addBands(obj.id);
});

print(image)

var palettes = require('users/mapbiomas/modules:Palettes.js');
var vis = {
    'min': 0,
    'max': 49,
    'palette': palettes.get('classification6'),
    bands:['transicao_2019_2020']
    };


Map.addLayer(image,vis,'original',false);

var image_2 = image.divide(10000).int();
var image_3 = image.divide(100).int().mod(100);
var image_4 = image.mod(100);

Map.addLayer(image_2.clip(roi),vis,'img-2 .divide(10000).int()-ROI2',false);
Map.addLayer(image_3.clip(BiomesBR),vis,'img-3 .divide(100).int().mod(100)-ROI3',false);
Map.addLayer(image_4.clip(roi),vis,'img-4 .mod(100)-Roi4',false);
```
[Link to script](https://code.earthengine.google.com/a49a06b9bcc0723a198d536970fbc64b)



# 3.1 [Exporting Annual Transition maps.js](https://github.com/souza-eab/SEEG_BR/blob/main/1._Spatial_analyses/3.1_Export_to_Asset.js)

This step exports transition maps of each pair of years covering the time period analyzed.

```javascript

/* @. Set user parameters */// eg.

// In the previous step 3.0, we generated an ImageCollection, and now we are going to stack it into a single image.

// Set directory for the output file
var dir_output = 'projects/ee-seeg-brazil/assets/collection_9/v1/';

// Export parameters
var gfolder = 'TEMP';                // google drive folder 
var assetId = 'projects/mapbiomas-workspace/SEEG/2021/Col9'; // asset link

// Define data path
var dir = 'projects/ee-seeg-brazil/assets/collection_9/v1/3_0_Transitions_maps';

// Define filename prefix
var prefix = 'SEEG_Transitions_';

// Define years to be processed
var listYears = ['1989_1990', '1990_1991', '1991_1992', '1992_1993', '1993_1994', '1994_1995', '1995_1996', 
                 '1996_1997', '1997_1998', '1998_1999', '1999_2000', '2000_2001', '2001_2002', '2002_2003',
                 '2003_2004', '2004_2005', '2005_2006', '2006_2007', '2007_2008', '2008_2009', '2009_2010', 
                 '2010_2011', '2011_2012', '2012_2013', '2013_2014', '2014_2015', '2015_2016', '2016_2017',
                 '2017_2018', '2018_2019', '2019_2020'];

// Create empty image to receive each calculated transition and stack it as a new band
var recipe = ee.Image([]);

// For each year
listYears.forEach(function(stack_img){
  // Read image for the year i
  var image_i = ee.Image(dir + '/' + prefix + stack_img);
  // Stack into recipe
  recipe = recipe.addBands(image_i);
});

// Print stacked data
print(recipe);


// Export as a GEE asset 
  Export.image.toAsset({
    'image': recipe,
    'description': prefix + 'stacked',
    'assetId': assetId + prefix + 'stacked',
    'pyramidingPolicy': {
        '.default': 'mode'
    },
    'region': recipe.geometry(),
    'scale': 30,
    'maxPixels': 1e13
});
```
[Link to script](https://code.earthengine.google.com/deefc5a08bfdc246263c999ba97b12ab)


# 4.0 [CalcAreaZone.ipynb](https://github.com/souza-eab/SEEG_BR/blob/main/1._Spatial_analyses/4.0_CalcAreaZone.ipynb)

Create and export the areas of each transition annually, according to a BoundingBox and/or region of interest (eg. municipalities in Brazil).


[Link to script_in_Google_Collab](https://colab.research.google.com/drive/17HOAjssZNNneiIms1rDRRl2wypeOMqQd?usp=sharing) or 

[Link to script_in_Python (Local)](https://github.com/souza-eab/SEEG_BR/blob/main/1._Spatial_analyses/4.1_CalcAreaZone.py)



# Scheme
## Under Development {
<img src='/aux/SEEG_v1_0.0.1.png' height='auto' width='auto' align='right'>

