#!/bin/sh
if [ "$#" -lt 1 ];then
    echo "Useage: $0 <node fqdn>"
    exit 1
fi
puppet node clean $1
