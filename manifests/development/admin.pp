node adminnode inherits basenode-dev{
    include admin::server
}


node "admin1.example.com" inherits adminnode {
    class {"puppet::server":
        config => "development"
    }

}
