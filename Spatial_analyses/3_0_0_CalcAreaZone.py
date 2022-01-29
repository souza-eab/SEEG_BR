///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

## SCRIPT TO GENERATE DEFORESTATION MASKS FROM A COLLECTION OF MAPBIOMAS (eg. col 6.0) 
## For any issue/bug, please write to <edriano.souza@ipam.org.br>; <dhemerson.costa@ipam.org.br>; <barbara.zimbres@ipam.org.br> 
## Developed by: IPAM, SEEG and OC
## Citing: SEEG/Observatório do Clima and IPAM


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

    #Aqui voce precisa chamar as regioes de interesse, em raster. Tem que estar como Asset no GEE tambem.
    #O valor do raster eh o geocodigo do bioma segundo o IBGE.
    biomas = ee.Image(
        'projects/mapbiomas-workspace/AUXILIAR/biomas-2019-raster')

    #O valor do raster eh o geocodigo dos municipios segundo o IBGE.
    municipios = ee.Image(
        'projects/mapbiomas-workspace/AUXILIAR/municipios-2019-raster')

    #O valor do raster eh o geocodigo dos estados segundo o IBGE.
    #estados = ee.Image(
    #    'projects/mapbiomas-workspace/AUXILIAR/estados-2016-raster')

    # Aqui eh o raster multi-banda das transicoes
    transitions = ee.Image(
        'projects/mapbiomas-workspace/SEEG/2021/Col9/SEEG_Transicoes_2021_c6_stacked')
    
    # Aqui eh o raster multi-banda de areas protegidas, em que cada banda e o cumulativo das AP em cada ano
    apMask = ee.Image(
        'projects/mapbiomas-workspace/AUXILIAR/areas-protegidas-por-ano-2019/ap' + years[0]).unmask()

    biomasMunicip = biomas.multiply(10000000).add(municipios)

    geometry = biomas.geometry().bounds()
    # a geometria aqui eh uma bounding box do Brasil. Criem uma bounding box do RS e insiram as coordenadas aqui.
    geometry = ee.Geometry.Polygon(
        [[[-74.34040691705002, 5.9630086351511690],
                [-74.34040691705002, -34.09134700746099],
                [-33.64704754205002, -34.09134700746099],
                [-33.64704754205002, 5.9630086351511690]]])

    pixelArea = ee.Image.pixelArea().divide(1000000)

    #Essa funcao faz a soma das areas por regiao (zonal)
    def getPropertiesAp0(item):

        item = ee.Dictionary(item)

        year = ee.Dictionary(ee.List(item.get('groups')).get(0)).get('ANO')

        feature = ee.Feature(None) \
            .set("featureid", ee.String(item.get('featureid'))) \
            .set("ANO", year) \
            .set("AP", 0) \
            .set("data", [])

        areasList = ee.List(ee.Dictionary(
            ee.List(item.get('groups')).get(0)).get('groups'))

        def temp(obj, feature):
            obj = ee.Dictionary(obj)

            classe = ee.String(ee.Number(obj.get('CLASSE')).toUint32())

            area = obj.get('sum')

            datalist = ee.List(ee.Feature(feature).get(
                'data')).add([classe, area])

            return ee.Feature(feature).set('data', datalist)

        feature = areasList.iterate(
            temp, feature
        )

        return feature

    def getPropertiesAp1(item):

        item = ee.Dictionary(item)

        year = ee.Dictionary(ee.List(item.get('groups')).get(0)).get('ANO')

        feature = ee.Feature(None) \
            .set("featureid", ee.String(item.get('featureid'))) \
            .set("ANO", year) \
            .set("AP", 1) \
            .set("data", [])

        areasList = ee.List(ee.Dictionary(
            ee.List(item.get('groups')).get(0)).get('groups'))

        def temp(obj, feature):
            obj = ee.Dictionary(obj)

            classe = ee.String(ee.Number(obj.get('CLASSE')).toUint32())

            area = obj.get('sum')

            datalist = ee.List(ee.Feature(feature).get(
                'data')).add([classe, area])

            return ee.Feature(feature).set('data', datalist)

        feature = areasList.iterate(
            temp, feature
        )

        return feature

    def calculateArea(image, regions, feature, ap, year1, year2, apClass):

        reducer = ee.Reducer.sum().group(1, 'CLASSE').group(1, 'ANO').group(1, 'featureid')

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

    #Export
    name = "seeg-collection-6-transicao-biomas-municipios-" + \
        years[0] + '-' + years[1]

    #completeName = os.path.join('SEEG', file_name)
    #file = open(completeName +'.GeoJSON', 'w')
    #file.write(str(areas))
    #file.close()

    task = ee.batch.Export.table.toDrive(
        collection=areas,
        description=name,
        folder='SEEG_2021_GEE_v1', #Pasta no Google Drive para exportar a tabela
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
    ["2019","2020","2021"]
]

for period in periods:
    start(period)
