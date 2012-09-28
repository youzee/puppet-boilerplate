#!/bin/bash 
# TODO: Rewrite this script from scratch, it started as a POC and now sucks.

if [ "$#" -lt 1 ]
then
    echo "Usage: $0 <hostname>" 
    exit 1
fi

export RUBYOPT=rubygems
echo "Syncing files with puppet server"
rsync -a --delete --exclude='*.swp' modules/ /etc/puppet/modules/
rsync -a --delete --exclude='*.swp' manifests/ /etc/puppet/manifests/
rsync -a --delete --exclude='*.swp' hiera/ /etc/puppet/hiera/

echo "Cleanin local certificates for $1"
puppet cert clean $1

echo "Initializing host $1"
echo "Removing old puppet config"
ssh root@$1 "mkdir -p /etc/puppet;rm -rf /etc/puppet/client/*"

echo "Installing dependencies..."
ssh root@$1 "apt-get update;apt-get install ruby rubygems augeas-tools libaugeas-ruby";

echo "Installing puppet,facter gems..."
ssh root@$1 "gem install --no-ri --no-rdoc puppet facter ruby-shadow"


echo "Initializing puppet agent..."
ssh root@$1 "/var/lib/gems/1.8/bin/puppet agent --confdir=/etc/puppet/client  -t -v  --pluginsync"

echo "Signing certificate..."
puppet cert sign $1

echo "Running puppet agent..."
ssh root@$1 "/var/lib/gems/1.8/bin/puppet agent --confdir=/etc/puppet/client -t -v --report  --pluginsync"

