

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