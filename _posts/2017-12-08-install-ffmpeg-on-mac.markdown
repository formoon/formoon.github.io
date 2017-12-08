---
layout:         post
title:          在Mac上安装ffmpeg
subtitle:       遇见可遇不可求的美好
card-image:     
date:           2017-12-08
tags:           video&audio
post-card-type: article
---
[ffmpeg](https://www.ffmpeg.org)是目前开源社区最牛逼的视、音频处理工具，没有之一。<br>
ffmpeg的使用文档、开发文档浩如烟海，那不是简单能说清的，到官方网站啃文档无论如何你也躲不过去，真需要的话，还是早点开始吧。<br>

这里只说在Mac电脑的安装,假设你已经安装好了Homebrew,打开终端在命令行执行：
```bash
brew install ffmpeg
```
这就完成了最基本的安装，应当能应对大多数人的需求。

进阶安装：
```bash
brew install ffmpeg --with-chromaprint --with-fdk-aac --with-fontconfig --with-freetype --with-frei0r --with-game-music-emu --with-libass --with-libbluray --with-libbs2b --with-libcaca --with-libebur128 --with-libgsm --with-libmodplug --with-libsoxr --with-libssh --with-libvidstab --with-libvorbis --with-libvpx --with-opencore-amr --with-openh264 --with-openjpeg --with-openssl --with-opus --with-rtmpdump --with-rubberband --with-schroedinger --with-sdl2 --with-snappy --with-speex --with-tesseract --with-theora --with-tools --with-two-lame --with-wavpack --with-webp --with-x265 --with-xz --with-zeromq --with-zimg
```
这条命令安装了常用的、大多数ffmpeg插件，比如ffplay,比如x265编码器，这些插件都是干啥用的，你得查阅ffmpeg相关文档，简短说不清楚，建议每个模块你都是真的需要再安装。<br>
随着ffmpeg本身的升级，有些原本的插件，有可能会包含在了软件包本身，这时候上面这一长条命令中的某些参数可能就不需要了，这种情况可以参考brew安装过程中给出的提示，如果不需要某个参数了，可以删掉。好在为了保持兼容性，大多数不需要的参数，brew只会给出一个错误提示，但不影响继续进行安装。<br>
我查阅了文档，没有找到一条综合的参数可以一次性安装所有这些插件，所以手工在命令行加上这些参数仍然是必要的，好在你只需要拷贝、粘贴就可以执行了。

如果你需要了解ffmpeg软件包还有那些安装选项，可以使用命令：
```bash
brew info ffmpeg
```
这会列出所有可使用的参数，比如当前我这里执行会显示：
```bash
ffmpeg: stable 3.4 (bottled), HEAD
Play, record, convert, and stream audio and video
https://ffmpeg.org/
/usr/local/Cellar/ffmpeg/3.4 (284 files, 56MB) *
  Built from source on 2017-11-30 at 22:33:43 with: --with-chromaprint --with-fdk-aac --with-libass --with-libsoxr --with-libssh --with-tesseract --with-libvidstab --with-opencore-amr --with-openh264 --with-openjpeg --with-openssl --with-rtmpdump --with-rubberband --with-sdl2 --with-snappy --with-tools --with-webp --with-x265 --with-xz --with-zeromq --with-zimg --with-fontconfig --with-freetype --with-frei0r --with-game-music-emu --with-libbluray --with-libbs2b --with-libcaca --with-libgsm --with-libmodplug --with-libvorbis --with-libvpx --with-opus --with-speex --with-theora --with-two-lame --with-wavpack
From: https://github.com/Homebrew/homebrew-core/blob/master/Formula/ffmpeg.rb
==> Dependencies
Build: nasm ✔, pkg-config ✔, texi2html ✔
Recommended: lame ✔, x264 ✔, xvid ✔
Optional: chromaprint ✔, fdk-aac ✔, fontconfig ✔, freetype ✔, frei0r ✔, game-music-emu ✔, libass ✔, libbluray ✔, libbs2b ✔, libcaca ✔, libgsm ✔, libmodplug ✔, libsoxr ✔, libssh ✔, libvidstab ✔, libvorbis ✔, libvpx ✔, opencore-amr ✔, openh264 ✔, openjpeg ✔, openssl ✔, opus ✔, rtmpdump ✔, rubberband ✔, sdl2 ✔, snappy ✔, speex ✔, tesseract ✔, theora ✔, two-lame ✔, wavpack ✔, webp ✔, x265 ✔, xz ✔, zeromq ✔, zimg ✔
==> Options
--with-chromaprint
	Enable the Chromaprint audio fingerprinting library
--with-fdk-aac
	Enable the Fraunhofer FDK AAC library
--with-fontconfig
	Build with fontconfig support
--with-freetype
	Build with freetype support
--with-frei0r
	Build with frei0r support
--with-game-music-emu
	Build with game-music-emu support
--with-libass
	Enable ASS/SSA subtitle format
--with-libbluray
	Build with libbluray support
--with-libbs2b
	Build with libbs2b support
--with-libcaca
	Build with libcaca support
--with-libgsm
	Build with libgsm support
--with-libmodplug
	Build with libmodplug support
--with-libsoxr
	Enable the soxr resample library
--with-libssh
	Enable SFTP protocol via libssh
--with-libvidstab
	Enable vid.stab support for video stabilization
--with-libvorbis
	Build with libvorbis support
--with-libvpx
	Build with libvpx support
--with-opencore-amr
	Enable Opencore AMR NR/WB audio format
--with-openh264
	Enable OpenH264 library
--with-openjpeg
	Enable JPEG 2000 image format
--with-openssl
	Enable SSL support
--with-opus
	Build with opus support
--with-rtmpdump
	Enable RTMP protocol
--with-rubberband
	Enable rubberband library
--with-sdl2
	Enable FFplay media player
--with-snappy
	Enable Snappy library
--with-speex
	Build with speex support
--with-tesseract
	Enable the tesseract OCR engine
--with-theora
	Build with theora support
--with-tools
	Enable additional FFmpeg tools
--with-two-lame
	Build with two-lame support
--with-wavpack
	Build with wavpack support
--with-webp
	Enable using libwebp to encode WEBP images
--with-x265
	Enable x265 encoder
--with-xz
	Enable decoding of LZMA-compressed TIFF files
--with-zeromq
	Enable using libzeromq to receive commands sent through a libzeromq client
--with-zimg
	Enable z.lib zimg library
--without-gpl
	Disable building GPL licensed parts of FFmpeg
--without-lame
	Disable MP3 encoder
--without-qtkit
	Disable deprecated QuickTime framework
--without-securetransport
	Disable use of SecureTransport
--without-x264
	Disable H.264 encoder
--without-xvid
	Disable Xvid MPEG-4 video encoder
--HEAD
	Install HEAD version
```
可能你注意到了，作为一个优秀的开源软件，ffmpeg中也使用了很多其他开发团队的成果，比如刚才我提到了的x265编码器。<br>
这也导致了一个问题，当你日常进行开源软件包维护的时候，可能升级了某个软件包，导致ffmpeg/ffplay等软件无法使用了，这时候你需要重新安装ffmpeg,注意这个时候重新安装ffmpeg的命令，跟你原来安装ffmpeg时候的命令应当是对应的，比如：
```bash
brew reinstall ffmpeg
```
或者：
```bash
brew reinstall ffmpeg --with-chromaprint --with-fdk-aac --with-fontconfig --with-freetype --with-frei0r --with-game-music-emu --with-libass --with-libbluray --with-libbs2b --with-libcaca --with-libebur128 --with-libgsm --with-libmodplug --with-libsoxr --with-libssh --with-libvidstab --with-libvorbis --with-libvpx --with-opencore-amr --with-openh264 --with-openjpeg --with-openssl --with-opus --with-rtmpdump --with-rubberband --with-schroedinger --with-sdl2 --with-snappy --with-speex --with-tesseract --with-theora --with-tools --with-two-lame --with-wavpack --with-webp --with-x265 --with-xz --with-zeromq --with-zimg
```

一个注意事项：<br>
使用基本安装ffmpeg很容易，但进阶的完整安装，则会自动重新编译ffmpeg软件包，这就需要系统提前安装好了苹果电脑的开发工具Xcode。<br>
此外如果操作系统本身升级或者关键软件比如Xcode的升级，都可能导致ffmpeg/ffplay不能使用，这时候需要使用上面说过的重新安装方法重新安装ffmpeg软件包。




