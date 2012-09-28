#!/bin/sh
if [ $# -lt 1 ];then
    echo "Usage: $0 file"
    exit 1
fi

gpg --decrypt $1
