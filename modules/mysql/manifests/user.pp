#custom type mysql::user

define mysql::user($username=$title,$hostname="localhost",$password,$grants,$on,$root_password){
    exec{"create_mysql_user_${username}":
        unless => "echo 'status;'|mysql -u$username -p$password",
        path => ["/bin", "/usr/bin"],
        command => "echo \"GRANT ${grants} on ${on} to \'${username}\'@\'${hostname}\' IDENTIFIED BY \'${password}\'\" | mysql -uroot -p${root_password}",
        require => Service["mysql"],
        logoutput => on_failure,
    }
}
