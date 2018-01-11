#!/bin/bash

if [ "$1" = "pic" ]; then
	qshell qupload 8 qshellupload.conf
else
	git add . 
	git commit -m "$1"
	git push
fi

