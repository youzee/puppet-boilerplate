#Class site

# Production nodes
import "production/admin"
import "production/webservers"

# Development nodes
import "development/admin"
import "development/webservers"

# Base node for all environments
node basenode {
    # include somemodule::someclass
    class{"puppet::client":}
}

node "basenode-dev" inherits basenode {
    # include somedevmodule::someclass
}

node "basenode-prod" inherits basenode {
    # include someprodmodule::someclass
}
