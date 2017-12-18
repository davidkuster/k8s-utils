# k8s-utils

This repo is a collection of small bash scripts oriented primarily to assist with Kubernetes production support, although they can certainly be used in non-prod environments as well.

These follow the naming convention suggested by the env-specific `k8s-*` aliases for `kubectl` as detailed in the [k8s-tips](https://github.com/davidkuster/k8s-tips) repo.

## Setup

### Add to PATH

Add the cloned copy of this repo directly to your PATH via `.bash_profile`, `.profile`, `.bashrc`, or equivalent.

    export PATH="$PATH:/path/to/k8s-utils"

> Note: currently these scripts have only been tested on OSX.

### Create script for your k8s envs

The `load-config.sh` script will look for a script at `~/.kube/k8s-utils-config.sh` which details config file and namespace setup specific to your env. An example might be:

    ```bash
    env=$1

    if [[ $env == "dev" ]]; then
        cfg="config.dev"
        namespace="dev"
    elif [[ $env == "qa" ]]; then
        cfg="config.dev"
        namespace="qa"
    elif [[ $env == "stage" ]]; then
        cfg="config.prod"
        namespace="stage"
    elif [[ $env == "production" ]]; then
        cfg="config.prod"
        namespace="production"

    elif [[ $env == "dev-default" ]]; then
        cfg="config.dev"
        namespace="default"
    elif [[ $env == "prod-default" ]]; then
        cfg="config.prod"
        namespace="default"

    elif [[ $env == "dev-sys" ]]; then
        cfg="config.dev"
        namespace="kube-system"
    elif [[ $env == "prod-sys" ]]; then
        cfg="config.prod"
        namespace="kube-system"
    fi
    ```

Remember that this file needs to be executable - `chmod 755 k8s-utils-config.sh`.

## Usage

### General note

A number of these scripts use a parameter named `pod_names_to_grep`. The convention here is that this will be passed to `kubectl get pods | grep $pod_names_to_grep`.

As such, it's important to be specific enough to not pick up pods you weren't expecting. Alternatively, you can also provide an actual pod name to narrow the scope down to a single pod.

Typically `pod_names_to_grep` will be the name of the service you're interested in.

### k8s-pods

Usage: `k8s-pods <env> <pod_names_to_grep>`

- This script is an alternative to using `kubectl get pods -w`. It uses the `watch` command and is useful to keep an eye on pods when doing a deploy, to see them move between Terminating, Pending, and Running statuses.

    - Note that `kubectl rollout status deployment/<deployment name> -w` can also be used to monitor a deploy, but the command is a bit more verbose and doesn't show the same level of detail. For instance, if you have multiple init containers this will let you see that the deploy is running into problems on container 2/4, for example.

- Example: `k8s-pods stage search-api`

- Example result:

    Every 2.0s: kubectl --namespace=stage get pods | grep search-api

    search-api-1568909879-476vm    1/1       Running   0          1d
    search-api-1568909879-f2pdb    1/1       Running   0          1d
    search-api-1568909879-gzd9n    1/1       Running   0          1d


- It can also be useful to quickly check the status of multiple pods across services, by using a less specific `pod_names_to_grep` value.

---

### k8s-tail

Usage: `k8s-tail <env> <pod_names_to_grep> <optional extra params>`

- Use this to tail the logs for a service in a given environment.  If there are multiple pods running, it merges all of the logs together into a single output -- useful, but verbose.

- Because all pod logs are merged into a single output stream, this is more useful for a quick look at a service as opposed to debugging specific issues.

- Example: `k8s-tail qa catalog-api`

- Example: `k8s-tail prod recommender-api --since=5m`

- It is also possible to pass a pod name for the grep value, which will be equivalent to doing `kubectl logs -f <pod_name>`.

---

### k8s-pod-errors

Usage: `k8s-pod-errors <env> <pod_names_to_grep>`

- This script will grep for case-insentitive "error" lines in the logs of the pods in the given service, but currently over only the last 5 minutes. If a service is alerting, this is useful to help determine if one pod is acting as an outlier or if all pods are reporting similar error levels and any problem is service-wide.

- Example: `k8s-pod-errors production recommender-api`

- Example result:

    pod = recommender-api-1966416721-dl4k3, error count =        178
    pod = recommender-api-1966416721-kdc3g, error count =        212
    pod = recommender-api-1966416721-wsjn4, error count =        153

- Example result of an outlier pod:

    pod = recommender-api-1966416721-0dyv3, error count =        8
    pod = recommender-api-1966416721-7li0w, error count =     9843
    pod = recommender-api-1966416721-mmgna, error count =        9
    pod = recommender-api-1966416721-q6us9, error count =        9
    pod = recommender-api-1966416721-vqz9h, error count =       11
    pod = recommender-api-1966416721-yyd5s, error count =        4

---

### k8s-pod-grep

Usage: `k8s-pod-grep <env> <pod_names_to_grep> <grep_string>`

- This script is similar to `k8s-pod-errors` but instead of doing a hard coded `grep -i error` this script allows the user to input the string param to grep. (But, still hard coded to only look over the last 5 minutes due to the prod debugging focus.) This can be useful to drill into specific errors or other behaviors when there's a concern it may not be consistently happening across all pods for the given service.

- Example: `k8s-pod-grep production customer-api "Read timed out"`

    pod = customer-api-1966416721-dl4k3, grep count =        0
    pod = customer-api-1966416721-kdc3g, grep count =        4
    pod = customer-api-1966416721-wsjn4, grep count =        5

---
