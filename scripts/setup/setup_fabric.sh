#!/bin/bash

# Get the absolute path to the project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Exit on first error
set -e

# Create necessary directories
cd "${PROJECT_ROOT}"
mkdir -p bin config
mkdir -p organizations/ordererOrganizations
mkdir -p organizations/peerOrganizations
mkdir -p system-genesis-block
mkdir -p channel-artifacts
mkdir -p scripts/temp

# Download Fabric binaries and Docker images
curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.4.0 1.4.7

# Move binaries to the right location
mv bin/* "${PROJECT_ROOT}/bin/" || true
mv config/* "${PROJECT_ROOT}/config/" || true

echo "✅ Fabric setup completed!"
