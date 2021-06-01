include <- function(pkg){
  if(!suppressMessages(require(pkg, character.only = TRUE)))
    install.packages(pkg, character.only = TRUE)
  suppressMessages(library(pkg, pkg, character.only = TRUE))
}

include("docopt")
include("here")
include("R.utils")
include("stringr")
include("dplyr")
include("MEDIPS")
suppressMessages(library(stringr))
suppressMessages(library(dplyr))
