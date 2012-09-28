#!/bin/sh
if [ "$#" -lt 1 ];then
    echo "Usage $0 <environment>"
    exit 1
fi

if [ ! -f ~/.gnupg/pubring.gpg ]; then
    "No public key found. Generate it with 'gpg --gen-key' and verify it with 'gpg --list-keys'"
    exit 1
fi

mkdir -p keyrings/$1
gpg --homedir=keyrings/$1 --import ~/.gnupg/pubring.gpg
