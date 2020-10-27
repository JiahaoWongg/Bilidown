# load functions
source("./functions.R")

# accept parameters
options(repos=structure(c(CRAN="http://mirrors.aliyun.com/CRAN/")))
if (!requireNamespace("optparse", quietly = TRUE))
  suppressMessages(install.packages("optparse", quiet = T))
suppressWarnings(library("optparse"))

option_list = list(make_option("--url", type = "character", default = NULL, help = "video URL."),
                   make_option("--list", type = "character", default = NULL, help  = "Whether download playlist."),                  
                   make_option("--mp3", type = "character", default = NULL, help = "Whether tranfer to mp3."),
                   make_option("--file", type = "character", default = NULL, help = "Whether get URL(s) from file."),
                   make_option("--mp3Folder", type = "character", default = NULL, help = "Mp3 output folder."),   
                   make_option("--mp4Folder", type = "character", default = NULL, help = "Mp4 output folder."),      
                   make_option("--name", type = "character", default = NULL, help = "Rename output file."),
                   make_option("--start", type = "character", default = NULL, help = "Start point of mp3 cut"),     
                   make_option("--end", type = "character", default = NULL, help = "end point of mp3 cut"))
args <- parse_args(OptionParser(option_list=option_list))

# check parameters
if(is.null(args$url) & is.null(args$file)){ # neither exists
    getHelp()
    stop("One of the variables url and file must be provided!\n")
}
if(!(is.null(args$url) | is.null(args$file))){ # both exist
    getHelp()
    stop("Only one of the variables url and file needs to be provided!\n")
}
if(is.null(args$mp4Folder)){
    getHelp()
    stop("Argument mp4Folder must be given!\n")
}
# check whether output folder exists
checKFolderExists(args$mp4Folder)
if(!is.null(args$mp3))
  checKFolderExists(args$mp3Folder)

# download video from cmd URL
if(!is.null(args$url))
  runWorkflow(args)

# download video from URL file
if(!is.null(args$file)){
  text = readLines(args$file, encoding = "UTF-8")
  Ns = length(text)

  for(i in 1:Ns){
    cat("\nProcessing serial number", paste0(i, ","), "Remian", Ns - i, "\n")
    args = getDownInfos(text[i])
    runWorkflow(args)
  }
}
