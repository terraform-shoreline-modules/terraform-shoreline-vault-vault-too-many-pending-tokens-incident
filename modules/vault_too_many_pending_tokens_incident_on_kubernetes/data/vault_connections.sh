

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