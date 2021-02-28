#!/bin/bash
source ../credentials.sh
source aks-sql_variables.sh

az group list --query "[?starts_with(name,'$RGNAME')].[name]" --output tsv | xargs -L1 bash -c 'az group delete --name $0 --no-wait --yes'