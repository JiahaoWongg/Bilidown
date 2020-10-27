# load functions
source("./functions.R")

# accept parameters
options(repos=structure(c(CRAN="http://mirrors.aliyun.com/CRAN/")))
if (!requireNamespace("pacman", quietly = TRUE)){
            suppressMessages(install.packages("pacman", quiet = T))
}
pacman::p_load(pacman, optparse, XML, methods)

option_list = list(make_option("--url", type = "character", default = NULL, help = "video URL."),
                   make_option("--name", type = "character", default = NULL, help  = "Whether rename file."),
                   make_option("--outFolder", type = "character", default = NULL, help  = "Output folder."))
args <- parse_args(OptionParser(option_list=option_list))

# check parameters
if(is.null(args$url))
    stop("Parameter url must be provided!\n")

if(!is.null(args$outFolder))
	checKFolderExists(args$outFolder)

if(dir.exists("tmp"))
    unlink("tmp", recursive = TRUE)
dir.create("tmp")
setwd("tmp")

cmd = paste("you-get", args$url)
system(cmd, ignore.stderr = TRUE)

cat("Saving chat informations ...\n")
xml = list.files("./", ".xml")
file.rename(xml, "chat.xml")
text = xmlToDataFrame("chat.xml")$text[-c(1:7)]
write.table(text, "chat.txt", row.names = F, col.names = F, quote = F, fileEncoding = "UTF-8")

setwd("../")
if(!is.null(args$outFolder)){
	if(!is.null(args$name)){
		to = paste0(args$outFolder, "/", args$name, ".txt")
	} else{
		to = paste0(args$outFolder, "/")
	}
} else{
	if(!is.null(args$name)){
		to = paste0("./", args$name, ".txt")
	} else{
		to = "./"
	}
}

from = list.files("tmp", ".txt", full.names = TRUE)
file.copy(from, to)
unlink("tmp", recursive = TRUE)
cat("Done!\n")
