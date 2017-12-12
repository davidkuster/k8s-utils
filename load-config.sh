#!/bin/bash

# Central location to determine config files and k8s namespaces based on known params, so this isn't repeated among scripts.

# Note that all scripts using this must have a "usage" var defined.


# In an effort to not have real config in a Git repo, this script will first check for a script at ~/.kube/k8s-utils-config.sh.
# If it exists it will delegate loading of the "cfg" and "namespace" vars to that script.
# Remember that it needs to be executable:
#   chmod 755 ~/.kube/k8s-utils-config.sh

config_script="${HOME}/.kube/k8s-utils-config.sh"


# if params or config isn't right, remind user of required input
fail() {
    echo "$1"
    echo "Usage: $usage"
    if [ -n "$notes" ]; then
        echo "Note:  $notes"
    fi
    exit 1
}

# verify sufficient number of args have been passed to the script
all_args_count=$(echo "$usage" | wc -w)
if [ "$#" -lt $(($all_args_count - 1)) ]; then
    fail "Not enough arguments"
fi


env=$1

# if custom config script exists, get cfg & namespace from that
if [ -f "$config_script" ]; then
    . "$config_script" "$env"

# Sample config load
# This demonstrates use of 2 k8s clusters - dev & prod - each with 2 custom namespaces.
# In reality this can be as simple or complicated as your k8s setup requires.

# sample dev cluster - custom namespaces
elif [[ $env == "dev" ]]; then
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


if [ -z $cfg ] || [ -z $namespace ]; then
    fail "No configuration found for env: $env"
fi


# set the KUBECONFIG var here to DRY out the various scripts
export KUBECONFIG=${HOME}/.kube/$cfg
