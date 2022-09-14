## create metadata for each tile
## edriano.souza@ipam.org.br or dhemerson.costa@ipam.org.br

library (filesstrings)

##  list pattern
pat <- c('cagb', 'cbgb', 'cdw', 'clitter', 'total', 'qcnclass')

## mv files
for (i in 1:length(pat)) {
  files <- list.files ('./to_up', pattern=paste0(pat[i], '.tif'), full.names=TRUE)
  for (j in 1:length(files)) {
    file.move(files[j], paste0('./to_up/', pat[i]))
  }
}
