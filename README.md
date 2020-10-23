> 寒假又双叒叕延长了，闲来无事（其实是不想学习）又捯饬起了用命令行来下载视频
> 
> 希望这场瘟疫快点过去，再不让我去学校学习我就要疯啦！武汉加油！中国加油！

# 1 目的

*   下载指定URL的视频文件至创建的临时文件夹

*   如果该链接包含多P视频，可根据需要选择是否全P下载

*   如果下载的是FLV格式的视频的话，则先转码为MP4格式；

*   根据需要可以选择是否将MP4格式文件转码为MP3格式；

*   分别保存MP4文件和MP3文件至指定路径，并删除临时文件夹。

# 2 实现

## 2.1 工具

*   [R](https://mirrors.tuna.tsinghua.edu.cn/CRAN/bin/windows/base/)

*   [Python](https://www.python.org/downloads/)（用于pip安装you-get）

*   [you-get](https://github.com/soimort/you-get/wiki/%E4%B8%AD%E6%96%87%E8%AF%B4%E6%98%8E)（推荐使用pip命令安装，详见该文档）

*   [FFmpeg](https://ffmpeg.zeranoe.com/builds/win64/static/)

## 2.1 编写脚本

<pre spellcheck="false" class="md-fences md-end-block md-fences-with-lineno ty-contain-cm modeLoaded" lang="R" cid="n9" mdtype="fences" style="box-sizing: border-box; overflow: visible; font-family: var(--monospace); font-size: 0.9em; display: block; break-inside: avoid; text-align: left; white-space: normal; background-image: inherit; background-position: inherit; background-size: inherit; background-repeat: inherit; background-attachment: inherit; background-origin: inherit; background-clip: inherit; background-color: rgb(248, 248, 248); position: relative !important; border: 1px solid rgb(231, 234, 237); border-radius: 3px; padding: 8px 4px 6px 0px; margin-bottom: 15px; margin-top: 15px; width: inherit; color: rgb(51, 51, 51); font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-indent: 0px; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-style: initial; text-decoration-color: initial;"> # accept parameters
 options   = commandArgs(trailingOnly = TRUE)
 mp4Folder = options[1]
 mp3Folder = options[2]
 list      = options[3]
 URL       = options[4]
 ​
 # download video file(s)
 if(!dir.exists("tempFolder")){dir.create("tempFolder", recursive = TRUE)}
 setwd("tempFolder")
 if(list == "list"){
  system(paste("you-get -l --no-caption ", URL))
 }else{
  system(paste("you-get --no-caption ", URL))
 }
 ​
 # transcode flv file(s) to mp4 file(s) if necessary
 flvFile = gsub(" ", "_", list.files())
 file.rename(list.files(), flvFile)
 mp4File = gsub(".flv", ".mp4", flvFile)
 if(!flvFile == mp4File){
  for(i in 1:length(mp4File)){
  system(paste("ffmpeg -i", flvFile[i], mp4File[i]))
  }
 file.copy(mp4File, mp4Folder)
 ​
 # transcode mp4 file(s) to mp3 file(s) if necessary
 if(!mp3Folder == "no_mp3"){
  mp3File = gsub(".mp4", ".mp3", mp4File)
  for(i in 1:length(mp3File)){
  system(paste("ffmpeg -i", mp4File[i], "-vn", mp3File[i]))
  }
  file.copy(mp3File, mp3Folder)
 }
 ​
 # clear tempFolder
 setwd("../")
 unlink("tempFolder", recursive = TRUE, force = TRUE)</pre>

## 2.3 用法

Windows系统安装R后，将R下的bin文件夹`C:\Program Files\R\R-3.6.1\bin`添加到环境变量PATH中（忘了是不是默认添加的了，反正可以手动添加），之后打开命令提示符面板（快捷键`win + x + c`），输入以下格式的内容。

<pre spellcheck="false" class="md-fences md-end-block md-fences-with-lineno ty-contain-cm modeLoaded" lang="R" cid="n12" mdtype="fences" style="box-sizing: border-box; overflow: visible; font-family: var(--monospace); font-size: 0.9em; display: block; break-inside: avoid; text-align: left; white-space: normal; background-image: inherit; background-position: inherit; background-size: inherit; background-repeat: inherit; background-attachment: inherit; background-origin: inherit; background-clip: inherit; background-color: rgb(248, 248, 248); position: relative !important; border: 1px solid rgb(231, 234, 237); border-radius: 3px; padding: 8px 4px 6px 0px; margin-bottom: 15px; margin-top: 15px; width: inherit; color: rgb(51, 51, 51); font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-indent: 0px; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-style: initial; text-decoration-color: initial;"> Rscript bilidown.R mp4SaveFolder mp3SaveFolder list URL </pre>

一个一个地介绍上面的格式：

*   Rscript

    调用R的Rscript命令以运行R脚本

*   bilidown.R

    该脚本的命名，这个可以自定义

*   mp4SaveFolder  下载或转码的MP4文件存放路径，**必须使用绝对路径**。

*   mp3SaveFolder

    转码的MP3文件存放路径，**必须使用绝对路径**

    <u style="box-sizing: border-box;">若不需要转码为MP3格式</u>，**则必须使用`no_mp3`代替**

*   list

    选择是否下载所有分P视频，对于所有可分P网站都适用

    <u style="box-sizing: border-box;">若只需要下载单个视频</u>，**则必须使用`no_list`代替**

*   URL  视频链接，**注意**链接中不能含有字符`&`，否则会影响该命令行的运行，把URL中`？`和`&`后面的内容都删掉，只留下视频的原链接即可。

##### 注意

该脚本的四个参数**一个都不能少**，不要问为什么（因为我太菜了|\——/|）

# 3 示例

## 3.1 单个视频下载

为了便于展示，MP3和MP4文件保存路径我均设为`E:/badai/test`，即使这个链接本来就没有分P，但仍然要写`no_list`

![image](https://upload-images.jianshu.io/upload_images/5257017-0d83a9ca86ea5f84.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240) 

<pre spellcheck="false" class="md-fences md-end-block md-fences-with-lineno ty-contain-cm modeLoaded" lang="shell" cid="n39" mdtype="fences" style="box-sizing: border-box; overflow: visible; font-family: var(--monospace); font-size: 0.9em; display: block; break-inside: avoid; text-align: left; white-space: normal; background-image: inherit; background-position: inherit; background-size: inherit; background-repeat: inherit; background-attachment: inherit; background-origin: inherit; background-clip: inherit; background-color: rgb(248, 248, 248); position: relative !important; border: 1px solid rgb(231, 234, 237); border-radius: 3px; padding: 8px 4px 6px 0px; margin-bottom: 15px; margin-top: 15px; width: inherit; color: rgb(51, 51, 51); font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-indent: 0px; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-style: initial; text-decoration-color: initial;"> C:\Users\Jay Chou>Rscript E:/badai/bilidown.R E:/badai/test E:/badai/test no_list https://www.bilibili.com/video/av33508491
 site:                Bilibili
 title:               【鬼畜素材】汤家凤，你能睡得着觉，你有点出息没有！
 stream:
  - format:        dash-flv720
  container:     mp4
  quality:       高清 720P
  size:          1.3 MiB (1387328 bytes)
  # download-with: you-get --format=dash-flv720 [URL]
 ​
 Downloading 【鬼畜素材】汤家凤，你能睡得着觉，你有点出息没有！.mp4 ...
  100% (  1.3/  1.3MB) ├████████████████████████████████████████┤[2/2]  210 kB/s
 Merging video parts... Merged into 【鬼畜素材】汤家凤，你能睡得着觉，你有点出息没有！.mp4
 ​
 Skipping captions or danmaku.
 [1] 0
 [1] TRUE
 ffmpeg version 2.7 Copyright (c) 2000-2015 the FFmpeg developers
  built with gcc 4.9.2 (GCC)
  configuration: --enable-gpl --enable-version3 --disable-w32threads --enable-avisynth --enable-bzlib --enable-fontconfig --enable-frei0r --enable-gnutls --

  ###################################################################
  ############################此处省略一万字#########################
  ####################################################################

  major_brand     : isom
  minor_version   : 512
  compatible_brands: isomiso2avc1mp41
  description     : Packed by Bilibili XCoder v2.0.2
  TSSE            : Lavf56.36.100
  Stream #0:0(und): Audio: mp3 (libmp3lame), 44100 Hz, stereo, fltp (default)
  Metadata:
  handler_name    : SoundHandler
  encoder         : Lavc56.41.100 libmp3lame
 Stream mapping:
  Stream #0:1 -> #0:0 (aac (native) -> mp3 (libmp3lame))
 Press [q] to stop, [?] for help
 size=      10kB time=00:00:00.57 bitrate= 139.3kbits/s
 video:0kB audio:9kB subtitle:0kB other streams:0kB global headers:0kB muxing overhead: 4.285863%
 [1] TRUE
 ​
 C:\Users\Jay Chou></pre>

结果展示：

![image](https://upload-images.jianshu.io/upload_images/5257017-7a2f190af8208e2b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240) 

## 3.2 多P视频下载

![image](https://upload-images.jianshu.io/upload_images/5257017-6292ad841195d4c9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240) 

<pre spellcheck="false" class="md-fences md-end-block md-fences-with-lineno ty-contain-cm modeLoaded" lang="shell" cid="n96" mdtype="fences" style="box-sizing: border-box; overflow: visible; font-family: var(--monospace); font-size: 0.9em; display: block; break-inside: avoid; text-align: left; white-space: normal; background-image: inherit; background-position: inherit; background-size: inherit; background-repeat: inherit; background-attachment: inherit; background-origin: inherit; background-clip: inherit; background-color: rgb(248, 248, 248); position: relative !important; border: 1px solid rgb(231, 234, 237); border-radius: 3px; padding: 8px 4px 6px 0px; margin-bottom: 15px; margin-top: 15px; width: inherit; color: rgb(51, 51, 51); font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-indent: 0px; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-style: initial; text-decoration-color: initial;"> C:\Users\Jay Chou>Rscript E:/badai/bilidown.R E:/badai/test E:/badai/test list https://www.bilibili.com/bangumi/play/ep30134
 you-get: Extracting 1 of 13 videos ...
 site:                Bilibili
 title:               夏目友人帐：第1话 猫和友人帐
 stream:
  - format:        flv
  container:     flv
  quality:       高清 1080P
  size:          143.2 MiB (150119613 bytes)
  # download-with: you-get --format=flv [URL]
 ​
 Downloading 夏目友人帐：第1话 猫和友人帐.mp4 ...
  100% (143.2/143.2MB) ├████████████████████████████████████████┤[4/4]  234 kB/s
 Merging video parts... you-get: Extracting 2 of 13 videos ...
 Merged into 夏目友人帐：第1话 猫和友人帐.mp4
 ​
 Skipping captions or danmaku.
 site:                Bilibili
 title:               夏目友人帐：第2话 露神之祠
 stream:
  - format:        flv
  container:     flv
  quality:       高清 1080P
  size:          126.3 MiB (132417588 bytes)
  # download-with: you-get --format=flv [URL]
 ​
 Downloading 夏目友人帐：第2话 露神之祠.flv ...
  100% (126.3/126.3MB) ├████████████████████████████████████████┤[1/1]  301 kB/syou-get: Extracting 3 of 13 videos ...
 ​
 ​
 Skipping captions or danmaku.
 site:                Bilibili
 title:               夏目友人帐：第3话 八原的怪人
 stream:
  - format:        flv
  container:     flv
  quality:       高清 1080P
  size:          119.3 MiB (125074393 bytes)
  # download-with: you-get --format=flv [URL]
 ​
 Downloading 夏目友人帐：第3话 八原的怪人.flv ...
  100% (119.3/119.3MB) ├████████████████████████████████████████┤[1/1]    1 MB/syou-get: Extracting 4 of 13 videos ...
 you-get: 大会员专享限制
 you-get: [error] oops, something went wrong.
 you-get: don't panic, c'est la vie. please try the following steps:
 you-get:   (1) Rule out any network problem.
 you-get:   (2) Make sure you-get is up-to-date.
 you-get:   (3) Check if the issue is already known, on
 you-get:         https://github.com/soimort/you-get/wiki/Known-Bugs
 you-get:         https://github.com/soimort/you-get/issues
 you-get:   (4) Run the command with '--debug' option,
 you-get:       and report this issue with the full output.
 ​
 ​
 Skipping captions or danmaku.
 [1] 1
 [1] TRUE TRUE TRUE
 ffmpeg version 2.7 Copyright (c) 2000-2015 the FFmpeg developers
 ​
  ###################################################################
  ############################此处省略十万字#########################
  ####################################################################

 Output #0, mp3, to '澶忕洰鍙嬩汉甯愶細绗?璇漘鍏師鐨勬€汉.mp3':
  Metadata:
  major_brand     : isom
  minor_version   : 512
  compatible_brands: isomiso2avc1mp41
  TSSE            : Lavf56.36.100
  Stream #0:0(und): Audio: mp3 (libmp3lame), 44100 Hz, stereo, fltp (default)
  Metadata:
  handler_name    : SoundHandler
  encoder         : Lavc56.41.100 libmp3lame
 Stream mapping:
  Stream #0:1 -> #0:0 (aac (native) -> mp3 (libmp3lame))
 Press [q] to stop, [?] for help
 size=   22345kB time=00:23:50.02 bitrate= 128.0kbits/s
 video:0kB audio:22344kB subtitle:0kB other streams:0kB global headers:0kB muxing overhead: 0.001556%
 [1] TRUE TRUE TRUE
 ​
 C:\Users\Jay Chou></pre>

*   这一种，而且用以上方法只能下载免费试看的部分，B站是6分钟试看时间，所以对于那些视频本来就少于6分钟的来说，可以完全下载下来的；而时长大于6分钟就不行了

因此，想下载高清晰度的全长的VIP视频就要使用以下方法了：

> ## 加载cookie
> 
> 并非所有视频可供任何人观看。如果需要登录以观看 (例如, 私密视频), 可能必须将浏览器cookie通过`--cookies`/`-c` 加载入 `you-get`.
> 
> **注意:**
> 
> *   目前我们支持两种cookie格式：Mozilla `cookies.sqlite` 和 Netscape `cookies.txt`

以上是you-get的官方中文教程，至于到底怎么使用cookie，俺也没搞清楚，网上没有详细的教程。

不过可以确定的是，首先你要有一个对应网站的VIP账号才行。
