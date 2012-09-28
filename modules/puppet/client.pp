#
class puppet::client {
    include common::supervisor
    include puppet

    file {"/etc/puppet":
        ensure => directory,
        owner => root,
        group => root
    }

    file {"/etc/puppet/client":
        ensure => directory,
        owner => root,
        group => root,
        require => File["/etc/puppet"]
    }

    file {"/etc/puppet/client/auth.conf":
        ensure => present,
        owner => root,
        group => root,
        source => "puppet:///modules/puppet/client/auth.conf",
        require => File["/etc/puppet","/etc/puppet/client"]
    }

}

