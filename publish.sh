#!/bin/bash

echo "pic demo url: "
echo " /attachments/201903/vm-docker/VM-LXC.png"
#if [ "$1" = "pic" ]; then
case "$1" in
  pic)
    qshell qupload qshellupload.conf
    echo "demo url:  http://files.17study.com.cn/201903/vm-docker/VM-LXC.png"
    ;;
  4432)
    rsync -avz --stats --progress -e 'ssh -p 443' ~/dev/jekyll/attachments/ 115.182.41.123:/vod/files/
    echo "demo url:  http://115.182.41.123/files/201903/vm-docker/VM-LXC.png"
    ;;
#else
  *)
    git add . 
    git commit -m "$1"
    git push
    ;;
esac
#fi

