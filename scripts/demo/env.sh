#!/bin/bash

# Get the absolute path to the project root
export PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Chaincode paths
export CHAINCODE_PATH="${PROJECT_ROOT}/chaincode"
export CHAINCODE_ZAKAT_PATH="${CHAINCODE_PATH}/zakat"

# Config paths
export CONFIG_PATH="${PROJECT_ROOT}/config"
export CONFIG_DEV_PATH="${CONFIG_PATH}/dev"
export CONFIG_PROD_PATH="${CONFIG_PATH}/prod"

# Artifact paths
export CHANNEL_ARTIFACTS="${PROJECT_ROOT}/channel-artifacts"
export SYSTEM_GENESIS_BLOCK="${PROJECT_ROOT}/system-genesis-block"
export ORGANIZATIONS="${PROJECT_ROOT}/organizations"

# Docker network name
export DOCKER_NETWORK="fabric_test"

# Channel name
export CHANNEL_NAME="zakat-channel"

# Organization MSPs
export MALANG_MSP="YDSFMalangMSP"
export JATIM_MSP="YDSFJatimMSP"

# Peer addresses
export MALANG_PEER_ADDRESS="peer0.ydsfmalang.example.local:7051"
export JATIM_PEER_ADDRESS="peer0.ydsfjatim.example.local:8051"
export ORDERER_ADDRESS="orderer.example.local:7050"

# TLS certificates
export MALANG_TLS_ROOTCERT="${ORGANIZATIONS}/peerOrganizations/ydsfmalang.example.local/peers/peer0.ydsfmalang.example.local/tls/ca.crt"
export JATIM_TLS_ROOTCERT="${ORGANIZATIONS}/peerOrganizations/ydsfjatim.example.local/peers/peer0.ydsfjatim.example.local/tls/ca.crt"
export ORDERER_TLS_ROOTCERT="${ORGANIZATIONS}/ordererOrganizations/example.local/orderers/orderer.example.local/msp/tlscacerts/tlsca.example.local-cert.pem"

# MSP paths
export MALANG_MSP_PATH="${ORGANIZATIONS}/peerOrganizations/ydsfmalang.example.local/users/Admin@ydsfmalang.example.local/msp"
export JATIM_MSP_PATH="${ORGANIZATIONS}/peerOrganizations/ydsfjatim.example.local/users/Admin@ydsfjatim.example.local/msp"

# Docker image
export FABRIC_TOOLS_IMAGE="hyperledger/fabric-tools:2.4"

# Go environment
export GOPATH="${CHAINCODE_PATH}"
export GO111MODULE="on"
export GOFLAGS="-buildvcs=false"
