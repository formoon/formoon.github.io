#!/bin/bash

git add . 
git commit -m "$1"
git push
if [ "$2" = "upload" ]; then
	qshell qupload 8 qshellupload.conf
fi

