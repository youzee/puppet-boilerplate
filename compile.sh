#!/bin/sh

sync_server() {
    echo "Syncing files with puppet server"
    rsync -a --delete --exclude='*.swp' modules/ /etc/puppet/modules/
    rsync -a --delete --exclude='*.swp' manifests/ /etc/puppet/manifests/
    rsync -a --delete --exclude='*.swp' hiera/ /etc/puppet/hiera/

}


if [ "$#" -lt 1 ];then
    echo "Usage: $0 <node name>"
    exit1
fi

sync_server

puppet master --verbose --compile $1

