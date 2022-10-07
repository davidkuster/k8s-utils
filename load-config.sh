#!/bin/bash

# Central location to determine config files and k8s namespaces based on known params, so this isn't repeated among scripts.

# Note that all scripts using this must have a "usage" var defined.


# In an effort to not have real config in a Git repo, this script will first check for a script at ~/.kube/k8s-utils-config.sh.
# If it exists it will delegate loading of the "cfg" and "namespace" vars to that script.
# Remember that it needs to be executable:
#   chmod 755 ~/.kube/k8s-utils-config.sh

config_script="${HOME}/.kube/k8s-utils-config.sh"

env=$1

# if params or config isn't right, remind user of required input
fail() {
    echo -e "\nERROR: $1\n"
    echo "Usage: $usage"
    if [ -n "$notes" ]; then
        echo "Note:  $notes"
    fi
    echo ""
    exit 1
}

# load "$cfg" & "$namespace" vars from config script
if [ -f "$config_script" ]; then
    . "$config_script" "$env"
else
    fail "$config_script does not exist, cannot run script"
fi

# verify env param
if [ -z $cfg ] || [ -z $namespace ]; then
    echo "Configured env values are:"
    grep "^[^#;]" $config_script \
    | grep '==' | \
    cut -f 3 -d '=' \
    | cut -f 1 -d ']' \
    | sed 's/"//g' \
    | sort
    fail "No configuration found for env: $env"
fi

# verify sufficient number of args have been passed to the script
all_args_count=$(echo "$usage" | wc -w)
if [ "$#" -lt $(($all_args_count - 1)) ]; then
    fail "Not enough arguments"
fi

# set the KUBECONFIG var here to DRY out the various scripts
export KUBECONFIG=${HOME}/.kube/$cfg
