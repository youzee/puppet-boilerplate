#class mysql::server

class mysql::server($config,$root_password){
  include mysql::service

  file {"/etc/mysql":
    ensure => directory,
    owner => root,
    group => root,
    source => "puppet:///modules/mysql/mysql/${config}",
    recurse => true,
    notify => Service["mysql"]
  }

  file{"/etc/mysql/my.cnf":
    owner => root,
    group => root,
    mode => "o-rw",
    require => File["/etc/mysql"]
  }

  exec { "set-mysql-password":
    unless => "echo 'status;'|mysql -uroot -p$root_password",
    path => ["/bin", "/usr/bin"],
    command => "mysqladmin -uroot password $root_password",
    require => Service["mysql"],
    logoutput => on_failure
  }
}
