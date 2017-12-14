---
layout:         post
title:          安装Homebrew
subtitle:       The missing package manager for macOS
card-image:     
date:           2017-12-08
tags:           mac
post-card-type: article
---
很多人问过我为什么选择苹果电脑，一个糙老爷们，又不是爱炫的小姑娘。

其实用苹果电脑的人，特别是在中国，“码农”占了很大一部分。能够使用庞大的开源社区资源比如GNU并从中汲取营养，是“码农”们重要的工作模式。<br>
而使用GNU资源，或者使用LINUX系统，或者，也就只有Mac电脑可选了。而且作为一个有大厂支持的操作系统，在选择商业软件、高水平工具的方面，比LINUX又有了不少优势。<br>
其实最近微软WINDOWS阵营也做了不少改变来应对这种情况，包括virsual studio系统支持Linux/Mac多种平台，Win10x64中支持内置的LINUX子系统，不过想达到Mac与生俱来的GNU亲和能力，恐怕还需要不短的时间。

Homebrew安装非常简单，请访问[Homebrew官方网站](https://brew.sh)查看最新的信息。<br>
一般情况下，打开Mac电脑的Terminal.app程序，可以在Launchpad中选择“终端”图标，或者使用屏幕右上角的spotlight(快捷键一般是COMMAND+空格)，然后输入Terminal，然后从搜索到的项目中选择Terminal.app执行。打开终端程序之后，在其中输入：
```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```
下面就按照提示操作就可以了。安装完成后，命令行键入brew<回车>可以得到使用帮助：
```bash
Example usage:
  brew search [TEXT|/REGEX/]
  brew (info|home|options) [FORMULA...]
  brew install FORMULA...
  brew update
  brew upgrade [FORMULA...]
  brew uninstall FORMULA...
  brew list [FORMULA...]

Troubleshooting:
  brew config
  brew doctor
  brew install -vd FORMULA

Developers:
  brew create [URL [--no-fetch]]
  brew edit [FORMULA...]
  https://docs.brew.sh/Formula-Cookbook.html

Further help:
  man brew
  brew help [COMMAND]
  brew home
```
比如使用Homebrew安装常用的curl工具，可以在命令行键入：
```bash
brew install curl
```

开源系统的日常维护<br>
我们都知道开源系统成千上万的开源包都分属不同的开发团队，因此如果你使用了较多的开源软件，你会发现几乎每天都有不少的开源包需要更新。一般在生产的机器上，这里生产一般是特指部署给最终用户使用的电脑，在这种机器上，一般不建议更新常规的更新包，只更新必须的安全更新。<br>
在个人使用的电脑上，通常还是建议尽量随时更新最新的软件包，以便你的开发过程能跟得上技术的最新进展。<br>
使用Homebrew更新软件包非常简单,只要三条命令：
```bash
brew update
brew upgrade 
brew cleanup
```
`brew update` :是更新Homebrew系统本身，以便更新自己的脚本及得到软件包的最新信息。<br>
`brew upgrade` :更新所有需要更新的软件包，在最新的Homebrew系统中，这一步中会自动先进行update操作，所以实际上上一条命令不需要了。<br>
`brew cleanup` :清理旧的软件包及安装文件，下载一半后放弃的软件包也会被清理。

