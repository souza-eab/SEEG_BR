////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////// GOALS: Export Transition wall-to-wall mapping paired year from a MapBiomas collection (eg. col 6.0) //
//////////  Coordination: Barbara Zimbres, Julia Shimbo, and Ane Alencar /////////////////////////////////////////////////////
//////////  Developed by: IPAM, SEEG and Climate Observatory ////////////////////////////////////////////////////////////////
//////////  Citing: Zimbres et al.,2022.  //////////////////////////////////////////////////////////////////////////////////
/////////   Processing time <2h> in Google Earth Engine ///////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// @. UPDATE HISTORIC EXECUTABLE//
// 1: Generate and Export Transition wall-to-wall mapping paired year from a MapBiomas collection (eg. col 6.0)
// 1.1: Set Asset
// 1.2: Define data path
// 1.3: Define filenames prefix     
// 1.4: Exporting data
// @. ~~~~~~~~~~~~~~ // 


/* @. Set user parameters */// eg.

// set directory for the output file
var dir_output = 'projects/ee-seeg-brazil/assets/collection_9/v1/';

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////

// export parameters
var gfolder = 'TEMP';                // google drive folder 
var assetId = 'projects/mapbiomas-workspace/SEEG/2021/Col9'; // asset link

// define data path
var dir = 'projects/ee-seeg-brazil/assets/collection_9/v1/3_0_Transitions_maps';

// define filenames prefix
var prefix = 'SEEG_Transitions_';

// define years to be processed
var listYears = ['1989_1990', '1990_1991', '1991_1992', '1992_1993', '1993_1994', '1994_1995', '1995_1996', 
                 '1996_1997', '1997_1998', '1998_1999', '1999_2000', '2000_2001', '2001_2002', '2002_2003',
                 '2003_2004', '2004_2005', '2005_2006', '2006_2007', '2007_2008', '2008_2009', '2009_2010', 
                 '2010_2011', '2011_2012', '2012_2013', '2013_2014', '2014_2015', '2015_2016', '2016_2017',
                 '2017_2018', '2018_2019', '2019_2020'];

// create empty recipe to receive each image and stack as a new band
var recipe = ee.Image([]);

// for each year
listYears.forEach(function(stack_img){
  // read image for the year i
  var image_i = ee.Image(dir + '/' + prefix + stack_img);
  // stack into recipe
  recipe = recipe.addBands(image_i);
});

// print stacked data
print(recipe);

/*
// export as gdrive file
    Export.image.toDrive({
    image: recipe,
    description: prefix + 'stacked',
    folder: gfolder,
    scale: 30,
    fileFormat: 'GeoTIFF',
    region: recipe.geometry(),
    maxPixels: 1e13
    });
*/

// export as GEE asset 
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

