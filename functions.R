Helps <- function(){
    cat("\n------>>> Enter 'Rscript bilidown.R -h' for seeing details of parameters setting! <<<------\n")
}


checKFolderExists <- function(folder){
    if(!dir.exists(folder)) dir.create(folder)
}

download <- function(URL){
    system(paste("you-get --no-caption -o tmp", URL))
}

downList <- function(URL){
    system(paste("you-get -l --no-caption -o tmp", URL))
}

flvToMp4 <- function(flv, mp4){
    if(flv != mp4) system(paste("ffmpeg -i", flv, mp4))
}

mp4ToMp3 <- function(mp4, mp3){
    system(paste("ffmpeg -i", mp4, mp3))
}

countSpan <- function(start, end){
    extractClock <- function(time){
        clock = strsplit(time, ":")
        min = clock[[1]][2]
        sec = clock[[1]][3]
        min = as.integer(min)
        sec = as.integer(sec)
        return(list = c(min, sec))
    }
    
    min_ST = extractClock(start)[1]
    sec_ST = extractClock(start)[2]
    min_ED = extractClock(end)[1]
    sec_ED = extractClock(end)[2]
    
    if(sec_ED >= sec_ST){
        sec_span = sec_ED - sec_ST
        min_span = min_ED - min_ST
    } else{
        sec_span = sec_ED + 60 - sec_ST
        min_span = (min_ED - 1) - min_ST
    }
    
    checkTen <-function(n){
        if(n < 10){
            n = paste0("0", n)
        } else{
            n = as.character(n)
        }
        return(n)
    }
    
    sec_span = checkTen(sec_span)
    min_span = checkTen(min_span)
    span = paste0("00:", min_span, ":", sec_span)
    return(span)
}

cutMp3 <- function(input_mp3, start, end, out_mp3){
    
    span = countSpan(start, end)

    cmd = paste("ffmpeg -i", input_mp3, "-vn -acodec copy")
    cmd = paste(cmd, "-ss", start)
    cmd = paste(cmd, "-t", span, out_mp3)
    system(cmd)
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

saveRes <- function(args){

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
                file.copy(mp3File, args$mp4Folder)
            }
        }
    }

    # remove tmpFolder
    unlink("tmp", recursive = TRUE)
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
    
    cat("\nTranscoding flv file to mp4 file\n")
    oldFile = list.files("tmp", full.names = TRUE)
    flvFile = gsub(" ", "_", oldFile)
    file.rename(oldFile, flvFile)
    mp4File = gsub(".flv", ".mp4", flvFile)
    flvToMp4(flvFile, mp4File)

    if(!is.null(args$mp3)){
        cat("\nTranscoding mp4 file to mp3 filey\n")
        mp3File = gsub(".mp4", ".mp3", mp4File)
        mp4ToMp3(mp4File, mp3File)
    }
    
    if(!is.null(args$start)){
        cat("\nCutting mp3 file\n")
        mp3File_cut = gsub(".mp3", "_cut.mp3", mp3File)
        cutMp3(mp3File, args$start, args$end, mp3File_cut)

    }

    cat("\nCopying & rename files and remove tmpFolder\n")
    # saveRes(args)

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
    cat("\nDone!\n")
}
