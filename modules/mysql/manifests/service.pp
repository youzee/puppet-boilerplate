#class mysql::service
class mysql::service {
  package { "mysql-server": ensure => installed }

  service { "mysql":
    enable => true,
    ensure => running,
    require => Package["mysql-server"]
  }
}

