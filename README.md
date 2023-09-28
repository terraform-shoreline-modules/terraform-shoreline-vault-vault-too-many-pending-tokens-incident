
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Vault too many pending tokens incident on kubernetes
---

The Vault too many pending tokens incident refers to an issue where the Vault server has too many pending tokens. This can happen when the number of tokens generated exceeds the limit of what the server can handle, causing a backlog of requests. As a result, users may experience difficulty accessing certain resources or functions that require token authentication. This incident type typically requires the attention of a system administrator or engineer to investigate and resolve the underlying cause, such as increasing the token limit or optimizing the token generation process.

### Parameters
```shell
export NAMESPACE="PLACEHOLDER"

export VAULT_POD_NAME="PLACEHOLDER"

export VAULT_CONTAINER_NAME="PLACEHOLDER"

export DEPLOYMENT_NAME="PLACEHOLDER"

export CASSANDRA_POD_NAME="PLACEHOLDER"

export VAULT_ADDRESS="PLACEHOLDER"

export MAX_CONNECTIONS="PLACEHOLDER"
```

## Debug

### Check the status of the Vault pod
```shell
kubectl get pods -n ${NAMESPACE}
```

### Check logs of Vault container
```shell
kubectl logs ${VAULT_POD_NAME} -n ${NAMESPACE} ${VAULT_CONTAINER_NAME}
```

### Check the current resource usage of the Vault pod
```shell
kubectl top pods ${VAULT_POD_NAME} -n ${NAMESPACE}
```

### Check the current resource usage of the Cassandra pod
```shell
kubectl top pods ${CASSANDRA_POD_NAME} -n ${NAMESPACE}
```

### Check the current resource limits and requests for the Vault and Cassandra pods
```shell
kubectl describe pods ${VAULT_POD_NAME} -n ${NAMESPACE}

kubectl describe pods ${CASSANDRA_POD_NAME} -n ${NAMESPACE}
```

### High number of concurrent requests to Vault API that leads to the generation of too many pending tokens.
```shell


#!/bin/bash



# Set variables

NAMESPACE=${NAMESPACE}

POD_NAME=${VAULT_POD_NAME}

CONTAINER_NAME=${VAULT_CONTAINER_NAME}

VAULT_ADDR=${VAULT_ADDRESS}

MAX_CONNECTIONS=${MAX_CONNECTIONS}



# Get the number of current connections

CURRENT_CONNECTIONS=$(kubectl exec $POD_NAME -n $NAMESPACE -c $CONTAINER_NAME -- sh -c "curl -s $VAULT_ADDR/v1/sys/stats | grep 'vault' | awk '{print $2}'")



# Check if the current connections exceeds the maximum allowed connections

if [ $CURRENT_CONNECTIONS -gt $MAX_CONNECTIONS ]

then

  echo "Too many concurrent connections to Vault API. Current connections: $CURRENT_CONNECTIONS"

else

  echo "Current connections to Vault API: $CURRENT_CONNECTIONS"

fi


```

## Repair

### Increase the token creation rate limit on Vault to reduce the number of pending tokens.
```shell


#!/bin/bash



# Set the namespace and deployment name

NAMESPACE=${NAMESPACE}

DEPLOYMENT=${DEPLOYMENT_NAME}



# Get the current token creation rate limit

RATE_LIMIT=$(kubectl get deployment -n $NAMESPACE $DEPLOYMENT -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="VAULT_TOKENS_RATE_LIMIT")].value}')



# Increase the rate limit by 10 tokens per second

NEW_RATE_LIMIT=$((RATE_LIMIT + 10))



# Update the deployment with the new rate limit

kubectl set env deployment -n $NAMESPACE $DEPLOYMENT VAULT_TOKENS_RATE_LIMIT=$NEW_RATE_LIMIT


```