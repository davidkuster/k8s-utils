# Sample config load for separate config file per cluster.
#
# This demonstrates use of 2 k8s clusters - dev & prod - each with 2 namespaces.
#
# In reality this can be as simple or complicated as your k8s setup requires.

env=$1

# sample dev cluster - custom namespaces
if [[ $env == "dev" ]]; then
    cfg="config.dev"
    namespace="dev"
elif [[ $env == "qa" ]]; then
    cfg="config.dev"
    namespace="qa"

# sample dev cluster - default and system namespaces
elif [[ $env == "dev-default" ]]; then
    cfg="config.dev"
    namespace="default"
elif [[ $env == "dev-sys" ]]; then
    cfg="config.dev"
    namespace="kube-system"

# sample prod cluster - custom namespaces
elif [[ $env == "stage" ]]; then
    cfg="config.prod"
    namespace="stage"
elif [[ $env == "prod" ]]; then
    cfg="config.prod"
    namespace="prod"

# sample prod cluster - default and system namespaces
elif [[ $env == "prod-default" ]]; then
    cfg="config.prod"
    namespace="default"
elif [[ $env == "prod-sys" ]]; then
    cfg="config.prod"
    namespace="kube-system"
fi
