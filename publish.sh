#!/bin/bash

if [ "$1" = "pic" ]; then
	qshell qupload 8 qshellupload.conf
	echo "demo url:  http://p1avd6u2z.bkt.clouddn.com/2018??/??/????.png"
else
	git add . 
	git commit -m "$1"
	git push
fi

