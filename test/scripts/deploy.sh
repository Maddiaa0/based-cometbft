#!/bin/bash

DEFAULT_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
RPC=http://localhost:8545

# Deployment script, just from this directory to make life easier
(cd ../../proposer_contract && forge script DeployProposer --broadcast --rpc-url $RPC --private-key $DEFAULT_KEY)