## create metadata for each tile
## dhemerson.costa@ipam.org.br

## read files
filename <- tools::file_path_sans_ext(basename(list.files('./output/')))

## parse info
tile_n <- sapply(strsplit(filename, split='_', fixed=TRUE), function(x) (x[2]))
product <- sapply(strsplit(filename, split='_', fixed=TRUE), function(x) (x[3]))

## build 
metadata <- cbind(filename, tile_n, product)

## export
write.csv(metadata, './metadata.csv', row.names=FALSE)
