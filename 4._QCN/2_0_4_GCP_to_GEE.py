## batch upload from GCP to GEE
## dhemerson.costa@ipam.org.br

## import libraries
import ee
import os
import pandas as pd
from google.cloud import storage

## api credentials
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "api_key.json"
ee.Initialize()

## start client
client = storage.Client()

## define bucket
bucket_name = 'qcn-tiles'
asset_name = 'projects/mapbiomas-workspace/SEEG/2021/QCN/QCN_30m'

## create empty recipies
gcp_file = []
basename = []
gee_file = []

## parse all files into recipe and store in the recipe object 
for blob in client.list_blobs(bucket_name):
    gcp_file = gcp_file + [('gs://' + bucket_name + '/' + str(blob).split(sep=', ')[1])]
    
## parse all complete recipe filenames and extract only the basename
for blob_i in gcp_file:
    basename = basename + [asset_name + '/' + blob_i.split(sep='/')[4]]    

## remove .tif extenstion from basename
for gee_file_i in basename:
    gee_file = gee_file + [gee_file_i.split(sep='.')[0]]
    
## perform batch upload
for i, item in enumerate(gcp_file):
    ## print progress
    print('ingesting file: ' + gcp_file[i])
    print('file ' + str(i) + ' of ' + str(len(gcp_file)) + ' (' + str(round((i/len(gcp_file) * 100))) + '%)')
    
    ## ingest file into GEE
    !earthengine upload image --asset_id={gee_file[i]} {gcp_file[i]}
    print('')
print ('done :-)')
