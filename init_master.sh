#!/bin/sh
#TODO: Add error handling
echo "Installing required debian packages"
apt-get update
apt-get install rubygems rsync libmysql-ruby

echo "Creating directory tree structure..."
mkdir -p /etc/puppet/modules/
mkdir -p /etc/puppet/manifests/
mkdir -p /etc/puppet/hiera/
   
echo "Copy initial puppet configuration and modules..."
rsync -a --delete --exclude='*.swp' modules/ /etc/puppet/modules/
rsync -a --delete --exclude='*.swp' manifests/ /etc/puppet/manifests/
rsync -a --delete --exclude='*.swp' hiera/ /etc/puppet/hiera/

echo """
---
:backends: - yaml
           - gpg

:logger: console

:hierarchy: - %{domain}
            - common
:yaml:
   :datadir: /etc/puppet/hiera

:gpg:
   :datadir: /etc/puppet/hiera
""" > /etc/puppet/hiera.yaml

#echo """
#[master]
#    confdir = /etc/puppet
#    certname = puppet.master
#    user = root
#    group = root
#""" > /etc/puppet/puppet.conf


echo "Installing required gems..."
gem install --no-rdoc --no-ri -v 3.0.10 rails
gem install --no-rdoc --no-ri puppet hiera hiera-gpg hiera-puppet
ln -fs /var/lib/gems/1.8/bin/puppet /usr/local/bin/puppet
echo "Starting puppet master daemon..."
export RUBYOPT=rubygems
useradd --system puppet
groupadd --system puppet
puppet master --mkusers --confdir=/etc/puppet --certname=puppet.master --user=root --group=root
