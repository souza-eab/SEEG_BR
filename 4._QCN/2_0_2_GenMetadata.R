## create metadata for each tile
## edriano.souza@ipam.org.br or dhemerson.costa@ipam.org.br

## read files
filename <- tools::file_path_sans_ext(basename(list.files('C:/Users/edriano.souza/GitHub/2022_2_QCN_rectify_v2/data/shp/biomes_v0/output')))

## parse info
tile_n <- sapply(strsplit(filename, split='_', fixed=TRUE), function(x) (x[2]))
product <- sapply(strsplit(filename, split='_', fixed=TRUE), function(x) (x[3]))

## build 
metadata <- cbind(filename, tile_n, product)

## export
write.csv(metadata, 'C:/Users/edriano.souza/GitHub/2022_2_QCN_rectify_v2/data/shp/biomes_v0/output/metadata.csv', row.names=FALSE)
