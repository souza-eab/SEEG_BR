
## Set assets

## SCRIPT TO GENERATE SUM AND EXPORT IN AREAS OF TRANSITION ANNUAL TO ACCORDING OF INTERESS REGION
## For any issue/bug, please write to <edriano.souza@ipam.org.br>; <dhemerson.costa@ipam.org.br>; <barbara.zimbres@ipam.org.br>
## Developed by: IPAM, SEEG and OC
## Citing: SEEG/Observatório do Clima and IPAM


## QUINTO PASSO PARA O METODO DE CALCULOS DO SEEG, SETOR MUT
## *.py -> OBS: ñ processa em Immage Collections, utilizar o passo 2_2_1_Transfer 
####OBS.:
### Para rodar esse script, basta abrir o prompt de comandos do computador e rodar o seguinte codigo:
### cd "NOME DA PASTA ONDE ESSE SCRIPT ESTA ARMAZENADO"
### python "NOME COM QUE ESSE SCRIPT ESTA SALVO".py



import ee
import os
from pprint import pprint
ee.Authenticate()
ee.Initialize()


def start(years):

    print(years)

    # Set your region of interest in raster, or all Biomes_BR (IBGE, 2020) 
    biomas = ee.Image(
        'projects/mapbiomas-workspace/AUXILIAR/biomas-2019-raster')

    # Set Cities_BR
    municipios = ee.Image(
        'projects/mapbiomas-workspace/AUXILIAR/municipios-2019-raster')

    #O valor do raster eh o geocodigo dos estados segundo o IBGE.
    #estados = ee.Image(
    #    'projects/mapbiomas-workspace/AUXILIAR/estados-2016-raster')

    # Set your Asset ImagemCollection SEEG_Transicoes_2021_c6_stacked
    transitions = ee.Image(
        'projects/mapbiomas-workspace/SEEG/2021/Col9/SEEG_Transicoes_2021_c6_stacked')
    
    # Here is the multi-band raster of protected areas (PA), where each band is the cumulative of PA areas and units in each year
    apMask = ee.Image(
        'projects/mapbiomas-workspace/AUXILIAR/areas-protegidas-por-ano-2019/ap' + years[0]).unmask()

    biomasMunicip = biomas.multiply(10000000).add(municipios)

    geometry = biomas.geometry().bounds()
    # Create a bounding box do Brasil
    geometry = ee.Geometry.Polygon(
        [[[-74.34040691705002, 5.9630086351511690],
                [-74.34040691705002, -34.09134700746099],
                [-33.64704754205002, -34.09134700746099],
                [-33.64704754205002, 5.9630086351511690]]])

    pixelArea = ee.Image.pixelArea().divide(1000000)

    # Region Calculation: This function sums the areas per region
    def getPropertiesAp0(item):

        item = ee.Dictionary(item)

        year = ee.Dictionary(ee.List(item.get('groups')).get(0)).get('YEAR')

        feature = ee.Feature(None) \
            .set("featureid", ee.String(item.get('featureid'))) \
            .set("YEAR", year) \
            .set("AP", 0) \
            .set("data", [])

        areasList = ee.List(ee.Dictionary(
            ee.List(item.get('groups')).get(0)).get('groups'))

        def temp(obj, feature):
            obj = ee.Dictionary(obj)

            class = ee.String(ee.Number(obj.get('TYPE')).toUint32())

            area = obj.get('sum')

            datalist = ee.List(ee.Feature(feature).get(
                'data')).add([class, area])

            return ee.Feature(feature).set('data', datalist)

        feature = areasList.iterate(
            temp, feature
        )

        return feature

    def getPropertiesAp1(item):

        item = ee.Dictionary(item)

        year = ee.Dictionary(ee.List(item.get('groups')).get(0)).get('YEAR')

        feature = ee.Feature(None) \
            .set("featureid", ee.String(item.get('featureid'))) \
            .set("YEAR", year) \
            .set("AP", 1) \
            .set("data", [])

        areasList = ee.List(ee.Dictionary(
            ee.List(item.get('groups')).get(0)).get('groups'))

        def temp(obj, feature):
            obj = ee.Dictionary(obj)

            class = ee.String(ee.Number(obj.get('TYPE')).toUint32())

            area = obj.get('sum')

            datalist = ee.List(ee.Feature(feature).get(
                'data')).add([class, area])

            return ee.Feature(feature).set('data', datalist)

        feature = areasList.iterate(
            temp, feature
        )

        return feature

    def calculateArea(image, regions, feature, ap, year1, year2, apClass):

        reducer = ee.Reducer.sum().group(1, 'TYPE').group(1, 'YEAR').group(1, 'featureid')

        areas = pixelArea.addBands(regions).addBands(ee.Image((year1 * 10000) + year2)).addBands(image) \
            .mask(ap.eq(apClass))\
            .reduceRegion(
                reducer=reducer,
                geometry=geometry,
                scale=30,
                maxPixels=1e12
        )

        if apClass:
            collection = ee.FeatureCollection(
                ee.List(areas.get('groups'))
                .map(getPropertiesAp1)
            )
        else:
            collection = ee.FeatureCollection(
                ee.List(areas.get('groups'))
                .map(getPropertiesAp0)
            )

        return collection

    areasAp0 = []
    areasAp1 = []

    image = transitions.select(['transicao_' + years[0] + '_' + years[1]])

    areasAp0.append(calculateArea(image, biomasMunicip, geometry,
                                  apMask, int(years[0]), int(years[1]), 0))
    areasAp1.append(calculateArea(image, biomasMunicip, geometry,
                                  apMask, int(years[0]), int(years[1]), 1))

    areasAp0 = ee.FeatureCollection(areasAp0).flatten()
    areasAp1 = ee.FeatureCollection(areasAp1).flatten()

    areas = areasAp0.merge(areasAp1)

    task = ee.batch.Export.table.toDrive(
        collection=areas,
        description=name,
        folder='SEEG_2021_GEE_v1', #Export to your Google Drive or other's path 
        fileNamePrefix=name,
        fileFormat="GeoJSON")           

    task.start()
periods = [
    ["1989", "1990"],
    ["1990", "1991"],
    ["1991", "1992"],
    ["1992", "1993"],
    ["1993", "1994"],
    ["1994", "1995"],
    ["1995", "1996"],
    ["1996", "1997"],
    ["1997", "1998"],
    ["1998", "1999"],
    ["1999", "2000"],
    ["2000", "2001"],
    ["2001", "2002"],
    ["2002", "2003"],
    ["2003", "2004"],
    ["2004", "2005"],
    ["2005", "2006"],
    ["2006", "2007"],
    ["2007", "2008"],
    ["2008", "2009"],
    ["2009", "2010"],
    ["2010", "2011"],
    ["2011", "2012"],
    ["2012", "2013"],
    ["2013", "2014"],
    ["2014", "2015"],
    ["2015", "2016"],
    ["2016", "2017"],
    ["2017","2018"],
    ["2018","2019"],
    ["2019","2020"]
]

for period in periods:
    start(period)
