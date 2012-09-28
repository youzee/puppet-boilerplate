#!/bin/bash 
LOCKFILE="/tmp/puppet.lock"

sync_server() {
    echo "Syncing files with puppet server"
    rsync -a --delete --exclude='*.swp' modules/ /etc/puppet/modules/
    rsync -a --delete --exclude='*.swp' manifests/ /etc/puppet/manifests/
    rsync -a --delete --exclude='*.swp' hiera/ /etc/puppet/hiera/

}

# $1: hostname
sync_host() {
    echo "Applying changes to $1..."
    ssh root@$1 "RUBYOPT=rubygems puppet agent --confdir=/etc/puppet/client  -t -v --report --pluginsync"
    case $? in
        127)
            echo "Looks like puppet agent is missing on host $1";;
        2|0) 
            echo "Changes applied to $1" ;;
        *)
            clear_lock
            exit $? ;;
    esac
}

clear_lock(){
    rm -f $LOCKFILE
}

main() {
    if [ -f $LOCKFILE ];then
        echo "Looks like somebody else is already running changes ($LOCKFILE is present). Execution aborted"
        echo "Lock info: `cat $LOCKFILE`"
        exit 1
    else
        echo "`date` - $USER ($SUDO_USER)" > $LOCKFILE
    fi
    export RUBYOPT=rubygems
    HOST_FILES=$*
    
    sync_server

    for hostfile in $HOST_FILES; do
        host=`basename $hostfile`
        sync_host $host
    done
}
main $*

clear_lock
