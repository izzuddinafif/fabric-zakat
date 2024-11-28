#!/bin/bash

# Source environment variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/env.sh"

# Set environment variables
export PATH=${PROJECT_ROOT}/fabric-samples/bin:$PATH
export FABRIC_CFG_PATH=${CONFIG_PATH}

echo "🌐 Setting up the network..."

# Generate crypto materials
echo "📜 Generating crypto materials..."
cd ${PROJECT_ROOT}
bash generate.sh dev

# Start the network
echo "🚀 Starting the network..."
docker-compose -f ${CONFIG_PATH}/docker-compose-test.yaml up -d

# Wait for network to start
echo "⏳ Waiting for network to start..."
sleep 3

echo "✅ Network setup complete!"
