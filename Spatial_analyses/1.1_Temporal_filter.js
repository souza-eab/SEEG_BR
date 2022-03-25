////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////// GOALS: EXCLUDE ISOLATED PIXELS AND REDUCE NOISE MAPBIOMAS (eg. col 6.0) ///////////////////////////////////
//////////  Coordination: Barbara Zimbres, Julia Shimbo, and Ane Alencar /////////////////////////////////////////////////////
//////////  Developed by: IPAM, SEEG and Climate Observatory ////////////////////////////////////////////////////////////////
////////// Citing: Zimbres et al.,2022.  ///////////////////////////////////////////////////////////////////////////////////
/////////  Processing time <2h> in Google Earth Engine ////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// @. UPDATE HISTORIC //
// 1: 
// 1.1: 
// 1.1: 
// @. ~~~~~~~~~~~~~~ // 

/* @. Set user parameters */// eg.

// set directory for the output file
var dir_output = 'projects/ee-seeg-brazil/assets/collection_9/v1/';


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Function that transforms an image collection into a single image with multiple bands
var collection2multiband = function (collection) {

    var imageList = collection.toList(collection.size()).slice(1);

    var multiBand = imageList.iterate(
        function (band, image) {

            return ee.Image(image).addBands(ee.Image(band));
        },
        ee.Image(collection.first())
    );

    return ee.Image(multiBand);
};

// Create Function that applies the Majority Filter (square_Kernel)
var PostClassification = function(image) {

    this.init = function(image) {

        this.image = image;

    };

    this._majorityFilter = function(params) {

        // Generate a mask from the class value
        var classMask = this.image.eq(params.classValue);

        // Labeling the group of pixels until 100 pixels connected
        var labeled = classMask.mask(classMask).connectedPixelCount(100, true);

        // Select some groups of connected pixels
        var region = labeled.lt(params.maxSize);

        // Squared kernel with size shift 1
        var kernel = ee.Kernel.square(1);

        // Find neighborhood
        var neighs = this.image.neighborhoodToBands(kernel).mask(region);

        // Reduce to majority pixel in neighborhood
        var majority = neighs.reduce(ee.Reducer.mode());

        // Replace original values for new values
        var filtered = this.image.where(region, majority);

        return filtered.byte();

    };

    this.spatialFilter = function(filterParams) {

        for (var params in filterParams) {

            this.image = this._majorityFilter(filterParams[params]);

        }

        return this.image;

    };

    this.init(image);

};


//////////////////////////////////////////////////////////////////////////////////////////
// Now we apply the functions defined previously
//////////////////////////////////////////////////////////////////////////////////////////


// Feature of the region of interest, in this case, all biomes in Brazil
var Biomes = ee.FeatureCollection("projects/ee-seeg-brazil/assets/collection_9/v1/Biomes_BR"); 

// Specify spatial filter parameters
var filterParams = [
   {classValue: 1, maxSize: 5}, // the maximum size (pixel kernel) that mapbiomas is using is 5. therefore  value is default set (5 pixel kernel)
   {classValue: 0, maxSize: 5}
];


// From here on, we work from 1990, which is the initial period of official data presented by the National Inventory (QCN,2020) 
var years = ['1990','1991','1992','1993','1994','1995','1996','1997','1998','1999','2000','2001','2002','2003','2004','2005','2006','2007','2008','2009','2010','2011','2012','2013','2014','2015','2016','2017','2018','2019','2020'];

// Creat list years
var eeYears = ee.List(years);

///// Input the Asset 'REGENERATION' mask asset exported from step 1.0
var inputImage_regeneration = ee.Image('projects/ee-seeg-brazil/assets/collection_9/v1/1_0_Regeneration_masks'); // change to the asset you saved in the previous script

// Apply functions
var result_regeneration = eeYears.map(function(year){
  filterParams;
  PostClassification;
    var image = inputImage_regeneration.select(ee.String('regeneration').cat(ee.String(year)));
    var pc = new PostClassification(image);
    var filtered2 = pc.spatialFilter(filterParams); 
    return(filtered2.int8());
});

// Save the result as a multi-band (ImageCollection)
result_regeneration = collection2multiband(ee.ImageCollection.fromImages(result_regeneration));
print(result_regeneration);

// Export 
Export.image.toAsset({
    "image": result_regeneration.uint8(),
    "description": '2_0_Temporal_filter_regeneration',
    "assetId": dir_output + '2_0_Temporal_filter_regeneration', // Enter the address and name eg.' projects/ee-seeg-brazil/assets/collection_9/v1/' of the Asset to be exported
    "scale": 30,
    "pyramidingPolicy": {
        '.default': 'mode'
    },
    "maxPixels": 1e13,
    "region": Biomes.geometry().convexHull() // If desired, change here to the name of the desired region in Brazil
});

///// Input the Asset 'DESFORESTATION' mask asset exported from step 1.0  
var inputImage_deforestation = ee.Image('projects/ee-seeg-brazil/assets/collection_9/v1/1.0_Deforestation_masks'); // change to the asset saved by you in the previous script

// Apply function 
var result_deforestation = eeYears.map(function(year){
  filterParams;
  PostClassification;
    var image = inputImage_deforestation.select(ee.String('deforestation').cat(ee.String(year)));
    var pc = new PostClassification(image);
    var filtered2 = pc.spatialFilter(filterParams); 
    return(filtered2.int8());
});

// Save the result as a multi-band (ImageCollection)
result_deforestation = collection2multiband(ee.ImageCollection.fromImages(result_deforestation));
print(result_deforestation);

// Export
Export.image.toAsset({
    "image": result_deforestation.uint8(),
    "description": '2_0_Temporal_filter_deforestation',
    "assetId": dir_output + '2_0_Temporal_filter_deforestation', // Enter the address and name eg.' projects/ee-seeg-brazil/assets/collection_9/v1/' of the Asset to be exported
    "scale": 30,
    "pyramidingPolicy": {
        '.default': 'mode'
    },
    "maxPixels": 1e13,
    "region": Biomes.geometry().convexHull() //If desired, change here to the name of the desired region in Brazil
});