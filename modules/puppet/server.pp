# Class: server
class puppet::server($config) {
    include common::supervisor
    include puppet
    package { ['puppet-module','hiera','hiera-gpg','hiera-puppet',"mysql"]:
        ensure => installed,
        provider => gem,
        require => [Package["libmysqlclient-dev"],Package["libssl-dev"]]
    }


    package {"rails":
        ensure => "3.0.10",
        provider => gem,
    }

    package{ ["libmysql-ruby","libmysqlclient-dev","libssl-dev"]:
        ensure => installed,
    }    

    file {'/etc/puppet/hiera.yaml':
        ensure => present,
        owner => root,
        group => root,
        source => "puppet:///modules/puppet/server/${config}/hiera.yaml"
    }

   
    file { '/etc/puppet/puppet.conf':
        ensure => present,
        source => "puppet:///modules/puppet/server/${config}/puppet.conf",
        owner => puppet,
        group => puppet,
        require => Mysql::Database["puppet"],
        notify => Service["supervisor"],
    }

    file {'/etc/puppet/tagmail.conf':
        ensure => present,
        source => "puppet:///modules/puppet/server/${config}/tagmail.conf",
        owner => puppet,
        group => puppet,
        notify => Service["supervisor"],
    }

    file { '/etc/puppet/fileserver.conf':
        ensure => present,
        source => "puppet:///modules/puppet/server/${config}/fileserver.conf",
        owner => puppet,
        group => puppet,
        notify => Service["supervisor"],
    }

    file {'/etc/supervisor/conf.d/puppet-server.conf':
        ensure => present,
        source => "puppet:///modules/puppet/server/${config}/supervisor.conf",
        owner => 'root',
        group => 'root',
        notify => Service["supervisor"],
        require => Package["supervisor"]
    }

    file {'/usr/local/bin/hiera':
        ensure => link,
        owner => root,
        group => root,
        target => '/var/lib/gems/1.8/gems/hiera-0.3.0/bin/hiera'
    }

    mysql::database { "puppet":
        user => "puppet",
        password => hiera("admin_mysql_puppet_password"),
        root_password => hiera("admin_mysql_root_password"),
    }    

    Class["mysql::server"] -> Class["puppet::server"]
 }
