#
class puppet {
    # Required packages
    $puppet_client_version = '2.7.18'
    package { ['ruby1.8','rubygems','rsync','libaugeas-ruby','augeas-tools']:
        ensure => "installed",
    }
    package { 'puppet':
        ensure => $puppet_client_version,
        provider => gem,
    }
    package { 'facter':
        ensure => installed,
        provider => gem,
    }
    package { 'ruby-shadow':
        ensure => installed,
        provider => gem,
    }  
   
    # Files
    file {  '/var/lib/puppet':
        ensure => directory,
        owner => 'root',
    } 
      
    file { '/usr/local/bin/puppet':
        ensure => link,
        target => "/var/lib/gems/1.8/gems/puppet-${puppet_client_version}/bin/puppet",
        owner => 'root',
        group => 'root',
    }

    file { '/usr/local/bin/filebucket':
        ensure => link,
        target => "/var/lib/gems/1.8/gems/puppet-${puppet_client_version}/bin/filebucket",
        owner => 'root',
        group => 'root',
    }

    file { '/usr/local/bin/pi':
        ensure => link,
        target => "/var/lib/gems/1.8/gems/puppet-${puppet_client_version}/bin/pi",
        owner => 'root',
        group => 'root',
    }

    file { '/usr/local/bin/puppetca':
        ensure => link,
        target => "/var/lib/gems/1.8/gems/puppet-${puppet_client_version}/bin/puppetca",
        owner => 'root',
        group => 'root',
     }

    file { '/usr/local/bin/puppetd':
        ensure => link,
        target => "/var/lib/gems/1.8/gems/puppet-${puppet_client_version}/bin/puppetd",
        owner => 'root',
        group => 'root',
     }

    file { '/usr/local/bin/puppetmasterd':
        ensure => link,
        target => "/var/lib/gems/1.8/gems/puppet-${puppet_client_version}/bin/puppetmasterd",
        owner => 'root',
        group => 'root',
    }

    file { '/usr/local/bin/puppetqd':
        ensure => link,
        target => "/var/lib/gems/1.8/gems/puppet-${puppet_client_version}/bin/puppetqd",
        owner => 'root',
        group => 'root',
    }

    file { '/usr/local/bin/puppetrun':
        ensure => link,
        target => "/var/lib/gems/1.8/gems/puppet-${puppet_client_version}/bin/puppetrun",
        owner => 'root',
        group => 'root',
    }

    file { '/usr/local/bin/ralsh':
        ensure => link,
        target => "/var/lib/gems/1.8/gems/puppet-${puppet_client_version}/bin/ralsh",
        owner => 'root',
        group => 'root',
    }

    file { '/usr/local/bin/puppet-module':
        ensure => link,
        target => "/var/lib/gems/1.8/gems/puppet-module-0.3.4/bin/puppet-module",
        owner => 'root',
        group => 'root',
    }
    file { '/usr/local/bin/facter':
        ensure => link,
        target => "/var/lib/gems/1.8/gems/facter-1.6.8/bin/facter",
        owner => 'root',
        group => 'root',
    }

}
