////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////// GOALS: Export pairwise transition maps from a MapBiomas collection ////////////////////////////////////////////////
//////////  Created by: Felipe Lenti, Barbara Zimbres, Edriano Souza /////////////////////////////////////////////////////////
//////////  Developed by: IPAM, SEEG and Climate Observatory ////////////////////////////////////////////////////////////////
//////////  Citing: Zimbres et al.,2022.  //////////////////////////////////////////////////////////////////////////////////
/////////   Processing time <2h> in Google Earth Engine ///////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// @. UPDATE HISTORIC EXECUTABLE//
// 1: Export pairwise transition maps from a MapBiomas collection
// 1.1: Load asset
// 1.2: Define the data path
// 1.3: Define filename prefix     
// 1.4: Export the pairwise data
// @. ~~~~~~~~~~~~~~ // 


/* @. Set user parameters */// eg.

// Set directory for the output file
var dir_output = 'projects/mapbiomas-workspace/SEEG/2022/public/';

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////

// Export parameters
//var gfolder = 'TEMP';                // google drive folder 
//var assetId = 'projects/mapbiomas-workspace/SEEG/2022/Col10'; // asset link

// Define the data path
var dir = 'projects/mapbiomas-workspace/SEEG/2022/public/3_0_Transition_maps'; //* Path anterior da ImgC
           
// Define filename prefix
var prefix = 'SEEG_Transitions_';

// Define pairs of years to be processed //*
var listYears = ['1985_1986','1986_1987', '1987_1988', '1988_1989', '1989_1990', '1990_1991', '1991_1992',
                 '1992_1993', '1993_1994', '1994_1995', '1995_1996', 
                 '1996_1997', '1997_1998', '1998_1999', '1999_2000', '2000_2001', '2001_2002', '2002_2003',
                 '2003_2004', '2004_2005', '2005_2006', '2006_2007', '2007_2008', '2008_2009', '2009_2010', 
                 '2010_2011', '2011_2012', '2012_2013', '2013_2014', '2014_2015', '2015_2016', '2016_2017',
                 '2017_2018', '2018_2019', '2019_2020','2020_2021'];

// Create an empty image to store each image and stack it as a new band
var trans = ee.Image([]);

// Iteration for each year
listYears.forEach(function(stack_img){
  // Read image for the year i
  var image_i = ee.Image(dir + '/' + prefix + stack_img);
  // Stack into trans
  trans = trans.addBands(image_i);
});

// Print stacked data
print(trans);

/*
// Export as a gdrive file
    Export.image.toDrive({
    image: trans,
    description: prefix + 'stacked',
    folder: gfolder,
    scale: 30,
    fileFormat: 'GeoTIFF',
    region: trans.geometry(),
    maxPixels: 1e13
    });
*/

// Export as a GEE asset 
  Export.image.toAsset({
    'image': trans,
    'description': '3_1_'+ prefix + 'stacked',
    'assetId':  dir_output + '3_1_'+ prefix + 'stacked',
    'pyramidingPolicy': {
        '.default': 'mode'
    },
    'region': trans.geometry(),
    'scale': 30,
    'maxPixels': 1e13
});
