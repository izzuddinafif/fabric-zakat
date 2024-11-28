#!/bin/bash

# Get the absolute path to the project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Source environment variables
source "${PROJECT_ROOT}/scripts/demo/env.sh"

# Exit on first error
set -e

# Stop and remove Docker containers, networks, and volumes
cleanup() {
    echo "Stopping and removing Docker containers..."
    docker-compose -f ${CONFIG_PATH}/docker-compose-test.yaml down --volumes --remove-orphans

    echo "Removing generated artifacts..."
    rm -rf ${PROJECT_ROOT}/organizations
    rm -rf ${PROJECT_ROOT}/system-genesis-block
    rm -rf ${PROJECT_ROOT}/channel-artifacts
    rm -rf ${PROJECT_ROOT}/crypto-config
    rm -rf ${PROJECT_ROOT}/scripts/temp/*

    echo "Pruning Docker volumes and networks..."
    docker volume prune -f
    docker network prune -f
}

cleanup
