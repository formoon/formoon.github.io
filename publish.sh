#!/bin/bash

if [ "$1" = "pic" ]; then
	qshell qupload 8 qshellupload.conf
	echo "demo url:  http://files.17study.com.cn/201903/vm-docker/VM-LXC.png"
else
	git add . 
	git commit -m "$1"
	git push
fi

