class admin::server {
    # Mysql server required by puppet Master
    class {"mysql::server":
        config => "admin",
        root_password => hiera("admin_mysql_root_password"),
    }

}
