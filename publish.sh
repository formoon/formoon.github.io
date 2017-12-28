#!/bin/bash

git add . 
git commit -m "$1"
git push
qshell qupload 8 qshellupload.conf

