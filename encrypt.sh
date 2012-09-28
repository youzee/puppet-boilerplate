#!/bin/sh -e
if [ "$#" -lt 2 ];then
    echo "Usage: $0 <environment> <file>"
    exit 1
fi

if [ ! -f "$2" ];then
    echo "File $2 not found."
    exit
fi

if [ ! -d "keyrings/$1" ];then
    echo "Environment $1 not found. Did you forget to run init_gpg.sh?"
    exit 1
fi
FILE=$2
BASENAME=${FILE%.*}

gpg --trust-model=always --homedir=keyrings/$1 --encrypt -o $BASENAME.gpg -r "Ops <ops@example.com>" "$FILE"
rm "$FILE"
