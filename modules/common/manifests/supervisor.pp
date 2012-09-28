#class supervisor

class common::supervisor {
    package {"supervisor": 
        ensure => present,
        provider => 'apt'
    }
    service { "supervisor":
        ensure => running,
        require => Package["supervisor"],
        hasrestart => false,
    }
}
