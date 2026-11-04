mkdir -p R_LIBS
R --slave -e "install.packages(c('igraph', 'optparse'), lib='./R_LIBS', repos='https://cloud.r-project.org')"