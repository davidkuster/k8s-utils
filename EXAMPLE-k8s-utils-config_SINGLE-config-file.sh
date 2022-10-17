# Sample config load for single config file with multiple clusters.
#
# This demonstrates use of 2 k8s clusters - dev & prod - each with 2 namespaces. In this example the "context" variable is used to indicate the context name used in the config file.
#
# In reality this can be as simple or complicated as your k8s setup requires.

env=$1

# single config file used for all.
cfg="config"

# sample dev cluster - custom namespaces
if [[ $env == "dev" ]]; then
    namespace="dev"
    context="dev-cluster"
elif [[ $env == "qa" ]]; then
    namespace="qa"
    context="dev-cluster"

# sample dev cluster - default and system namespaces
elif [[ $env == "dev-default" ]]; then
    namespace="default"
    context="dev-cluster"
elif [[ $env == "dev-sys" ]]; then
    namespace="kube-system"
    context="dev-cluster"

# sample prod cluster - custom namespaces
elif [[ $env == "stage" ]]; then
    namespace="stage"
    context="prod-cluster"
elif [[ $env == "prod" ]]; then
    namespace="prod"
    context="prod-cluster"

# sample prod cluster - default and system namespaces
elif [[ $env == "prod-default" ]]; then
    namespace="default"
    context="prod-cluster"
elif [[ $env == "prod-sys" ]]; then
    namespace="kube-system"
    context="prod-cluster"
fi
