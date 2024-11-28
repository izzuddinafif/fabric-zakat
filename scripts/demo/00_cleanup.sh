#!/bin/bash

# Source environment variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/env.sh"

cleanup() {
    echo "🧹 Cleaning up previous network..."
    docker-compose -f ${CONFIG_PATH}/docker-compose-test.yaml down --volumes --remove-orphans
    
    # Clean up generated files in project root
    rm -rf ${PROJECT_ROOT}/organizations
    rm -rf ${PROJECT_ROOT}/system-genesis-block/*
    rm -rf ${PROJECT_ROOT}/channel-artifacts/*
    rm -rf ${PROJECT_ROOT}/crypto-config/*
    rm -f ${PROJECT_ROOT}/zakat.tar.gz
    
    # Clean up temp files in scripts directory
    rm -rf ${PROJECT_ROOT}/scripts/temp/*
    mkdir -p ${PROJECT_ROOT}/scripts/temp
    
    # Clean up Docker resources
    docker volume prune -f
    docker network prune -f
}

# Execute cleanup
cleanup
