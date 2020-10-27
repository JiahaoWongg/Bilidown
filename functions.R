checkPackages <- function(packages){
    for(i in 1:length(packages)){
        package = packages[i]
        if (!requireNamespace(package, quietly = TRUE)){
            suppressMessages(install.packages(package, quiet = T))
        }
    }
}

getHelp <- function(){
    cat("\n------>>> Enter 'Rscript bilidown.R -h' to see details of parameters setting! <<<------\n\n")
}

checKFolderExists <- function(folders){
    for(i in 1:length(folders)){
        if(!dir.exists(folders[i])) dir.create(folders[i])
    }
}

download <- function(URL){
    system(paste("you-get --no-caption -o tmp", URL))
}

downList <- function(URL){
    system(paste("you-get -l --no-caption -o tmp", URL))
}

flvToMp4 <- function(flv, mp4){
    for(i in 1:length(flv)){
        if(flv[i] != mp4[i]) system(paste("ffmpeg -i", flv[i], mp4[i]), ignore.stderr = TRUE)
    }
}

mp4ToMp3 <- function(mp4, mp3){
    for(i in 1:length(mp4)){
        system(paste("ffmpeg -i", mp4[i], mp3[i]), ignore.stderr = TRUE)
    }
}

countSpan <- function(start, end){
    extractClock <- function(time){
        clock = strsplit(time, ":")[[1]]
        hor = as.integer(clock[1])
        min = as.integer(clock[2])
        sec = as.integer(clock[3])
        return(list = c(hor, min, sec))
    }

    timeM = sapply(c(start, end), extractClock)
 	hor_ST = timeM[1, 1]
 	min_ST = timeM[2, 1]
 	sec_ST = timeM[3, 1]
 	hor_ED = timeM[1, 2]
 	min_ED = timeM[2, 2]
 	sec_ED = timeM[3, 2]
    
    if(sec_ED >= sec_ST){
	    sec_span = sec_ED - sec_ST
        if(min_ED >= min_ST){
	        min_span = min_ED - min_ST
	        hor_span = hor_ED - hor_ST
        } else{
	        min_span = min_ED + 60 - min_ST
	        hor_span = (hor_ED - 1) - hor_ST
        }

	} else{
        sec_span = sec_ED + 60 - sec_ST
        if((min_ED - 1) >= min_ST){
	        min_span = (min_ED - 1) - min_ST
	        hor_span = hor_ED - hor_ST
        } else{
	        min_span = (min_ED - 1) + 60 - min_ST
	        hor_span = (hor_ED - 1) - hor_ST
        }
	}

    checkTen <-function(n){
        if(n < 10){
            n = paste0("0", n)
        } else{
            n = as.character(n)
        }
        return(n)
    }

    hor_span = checkTen(hor_span)
    min_span = checkTen(min_span)
    sec_span = checkTen(sec_span)
    span = paste0(hor_span, ":", min_span, ":", sec_span)
    return(span)
}

cutMp3 <- function(input_mp3, start, end, out_mp3){
    
    span = countSpan(start, end)

    cmd = paste("ffmpeg -i", input_mp3, "-vn -acodec copy")
    cmd = paste(cmd, "-ss", start)
    cmd = paste(cmd, "-t", span, out_mp3)
    system(cmd, , ignore.stderr = TRUE)
}

checkArgs <- function(string){
    if(!is.na(string))
        if(string != "no"){
            return(string)
        } else{
            return(NULL)
        }
}

getDownInfos <- function(line){
    infos = strsplit(line, " ")[[1]]
    args$url = checkArgs(infos[1])
    args$mp3 = checkArgs(infos[2])
    args$list = checkArgs(infos[3])
    args$name = checkArgs(infos[4])
    args$start = checkArgs(infos[5])
    args$end = checkArgs(infos[6])
    return(args)
}

runWorkflow <- function(args){

    if(dir.exists("tmp"))
        unlink("tmp", recursive = TRUE)
    dir.create("tmp")

    cat("\nDownloading video file ...\n")
    if(is.null(args$list)){
        download(args$url)
    } else{
        downList(args$url)
    }
    
    cat("Transcoding flv file to mp4 file\n")
    oldFile = list.files("tmp", full.names = TRUE)
    flvFile = gsub(" ", "_", oldFile)
    file.rename(oldFile, flvFile)
    mp4File = gsub(".flv", ".mp4", flvFile)
    flvToMp4(flvFile, mp4File)

    if(!is.null(args$mp3)){
        cat("Transcoding mp4 file to mp3 file\n")
        mp3File = gsub(".mp4", ".mp3", mp4File)
        mp4ToMp3(mp4File, mp3File)
    }
    
    if(!is.null(args$start)){
        cat("Cutting mp3 file\n")
        mp3File_cut = gsub(".mp3", "_cut.mp3", mp3File)
        cutMp3(mp3File, args$start, args$end, mp3File_cut)
    }

    cat("Copying & rename files and remove tmpFolder\n")
    if(!is.null(args$name)){
        mp4Out = paste0(args$mp4Folder, "/", args$name, ".mp4")
        file.copy(mp4File, mp4Out)
    
        if(!is.null(args$mp3)){
            mp3Out = paste0(args$mp3Folder, "/", args$name, ".mp3")
            if(!is.null(args$start)){
                file.copy(mp3File_cut, mp3Out)
            } else{
                file.copy(mp3File, mp3Out)
            }
        }
    } else{
        file.copy(mp4File, args$mp4Folder)

        if(!is.null(args$mp3)){
            if(!is.null(args$start)){
                file.copy(mp3File_cut, args$mp3Folder)
            } else{
                file.copy(mp3File, args$mp3Folder)
            }
        }
    }

    # remove tmpFolder
    unlink("tmp", recursive = TRUE)
    cat("Done!\n")
}
