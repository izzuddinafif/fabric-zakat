#!/bin/bash

# Get the project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Exit on first error
set -e

# Default to dev environment
ENVIRONMENT=${1:-dev}

# Validate environment parameter
if [ "$ENVIRONMENT" != "dev" ] && [ "$ENVIRONMENT" != "prod" ]; then
    echo "❌ Invalid environment. Use 'dev' or 'prod'"
    exit 1
fi

echo "🔧 Generating artifacts for $ENVIRONMENT environment..."

# Remove previous crypto material and artifacts
rm -rf organizations/ordererOrganizations organizations/peerOrganizations
rm -rf system-genesis-block/*
rm -rf channel-artifacts/*
rm -rf crypto-config/*

# Create necessary directories
mkdir -p organizations/ordererOrganizations organizations/peerOrganizations
mkdir -p system-genesis-block
mkdir -p channel-artifacts
mkdir -p crypto-config

# Set environment variables
export FABRIC_CFG_PATH=${PROJECT_ROOT}/config/${ENVIRONMENT}
export VERBOSE=false

# Generate crypto material
echo "📜 Generating crypto material..."
cryptogen generate --config=${FABRIC_CFG_PATH}/crypto-config.yaml --output=organizations
if [ "$?" -ne 0 ]; then
    echo "❌ Failed to generate crypto material..."
    exit 1
fi

# Generate genesis block
echo "🔨 Generating genesis block..."
configtxgen -profile TwoOrgsOrdererGenesis -channelID system-channel -outputBlock system-genesis-block/genesis.block
if [ "$?" -ne 0 ]; then
    echo "❌ Failed to generate genesis block..."
    exit 1
fi

# Generate channel creation transaction
echo "🔗 Generating channel creation transaction..."
configtxgen -profile TwoOrgsChannel -outputCreateChannelTx channel-artifacts/zakat-channel.tx -channelID zakat-channel
if [ "$?" -ne 0 ]; then
    echo "❌ Failed to generate channel creation transaction..."
    exit 1
fi

# Generate anchor peer transactions
echo "⚓ Generating anchor peer transactions..."

# For YDSFMalang
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate channel-artifacts/YDSFMalangMSPanchors.tx -channelID zakat-channel -asOrg YDSFMalangMSP
if [ "$?" -ne 0 ]; then
    echo "❌ Failed to generate anchor peer update for YDSFMalang..."
    exit 1
fi

# For YDSFJatim
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate channel-artifacts/YDSFJatimMSPanchors.tx -channelID zakat-channel -asOrg YDSFJatimMSP
if [ "$?" -ne 0 ]; then
    echo "❌ Failed to generate anchor peer update for YDSFJatim..."
    exit 1
fi

echo "✅ Generation completed successfully!"
