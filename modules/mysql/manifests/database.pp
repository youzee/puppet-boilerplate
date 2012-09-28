# type mysql::database
define mysql::database ($db=$title, $user, $password , $root_password ) {
    include mysql::service

    exec { "create-${db}-db":
      unless => "/usr/bin/mysql -u${user} -p${password} ${db}",
      command => "/usr/bin/mysql -uroot -p${root_password} -e \"create database ${db};grant all on ${db}.* to ${user}@localhost identified by '$password';\"",
      require => Service["mysql"],
      logoutput => on_failure
    }
}

