node adminnode inherits basenode{
    include admin::server
}


node "admin1.example.com" inherits adminnode {
    class {"puppet::server":
        config => "production"
    }

}
