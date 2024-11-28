#!/bin/bash

# Get the absolute path to the project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Source environment variables
source "${PROJECT_ROOT}/scripts/demo/env.sh"

# Exit on first error
set -e

# Set environment variables
export PATH=${PROJECT_ROOT}/bin:$PATH
export FABRIC_CFG_PATH=${CONFIG_PATH}

# Cleanup function to be called on script exit
cleanup() {
    echo "Cleaning up..."
    docker-compose -f ${CONFIG_PATH}/docker-compose-test.yaml down --volumes --remove-orphans
    rm -rf ${PROJECT_ROOT}/organizations
    rm -rf ${PROJECT_ROOT}/system-genesis-block
    rm -rf ${PROJECT_ROOT}/channel-artifacts
    rm -rf ${PROJECT_ROOT}/crypto-config
    rm -rf ${PROJECT_ROOT}/scripts/temp/*
    docker volume prune -f
    docker network prune -f
}

# Function to perform cleanup only on failure
cleanup_on_failure() {
  echo "Cleaning up due to failure..."
  cleanup
}

# Register cleanup function to be called on script failure
trap 'cleanup_on_failure' ERR

# Create network and generate crypto materials
echo "Creating network and generating crypto materials..."
cd ${PROJECT_ROOT}
./generate.sh

# Start the network
echo "Starting the network..."
docker-compose -f ${CONFIG_PATH}/docker-compose-test.yaml up -d

# Wait for network to start
echo "Waiting for network to start..."
sleep 3

# Ensure channel-artifacts directory exists
mkdir -p ./channel-artifacts

# Create and join channel
if [ -d "./channel-artifacts" ]; then
  echo "Creating and joining channel..."
  docker run --rm \
    -v ${PROJECT_ROOT}:/opt/fabric-zakat \
    -w /opt/fabric-zakat \
    --network fabric_test \
    -e CORE_PEER_TLS_ENABLED=true \
    -e CORE_PEER_LOCALMSPID="${MALANG_MSP}" \
    -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/fabric-zakat/organizations/peerOrganizations/ydsfmalang.example.local/peers/peer0.ydsfmalang.example.local/tls/ca.crt \
    -e CORE_PEER_MSPCONFIGPATH=/opt/fabric-zakat/organizations/peerOrganizations/ydsfmalang.example.local/users/Admin@ydsfmalang.example.local/msp \
    -e CORE_PEER_ADDRESS=peer0.ydsfmalang.example.local:7051 \
    ${FABRIC_TOOLS_IMAGE} \
    bash -c "
      peer channel create -o orderer.example.local:7050 -c zakat-channel \
        -f channel-artifacts/zakat-channel.tx \
        --outputBlock channel-artifacts/zakat-channel.block \
        --tls --cafile /opt/fabric-zakat/organizations/ordererOrganizations/example.local/orderers/orderer.example.local/msp/tlscacerts/tlsca.example.local-cert.pem
      peer channel join -b channel-artifacts/zakat-channel.block
    "
else
  echo "Error: channel-artifacts directory does not exist."
  exit 1
fi

# Check if the block file was created
if [ -f "./channel-artifacts/zakat-channel.block" ]; then
  echo "zakat-channel.block created successfully."
else
  echo "Error: zakat-channel.block was not created."
  exit 1
fi

# Join YDSFJatim peer to channel
echo "Joining YDSFJatim peer to channel..."
docker run --rm \
  -v ${PROJECT_ROOT}:/opt/fabric-zakat \
  -w /opt/fabric-zakat \
  --network fabric_test \
  -e CORE_PEER_TLS_ENABLED=true \
  -e CORE_PEER_LOCALMSPID="${JATIM_MSP}" \
  -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/fabric-zakat/organizations/peerOrganizations/ydsfjatim.example.local/peers/peer0.ydsfjatim.example.local/tls/ca.crt \
  -e CORE_PEER_MSPCONFIGPATH=/opt/fabric-zakat/organizations/peerOrganizations/ydsfjatim.example.local/users/Admin@ydsfjatim.example.local/msp \
  -e CORE_PEER_ADDRESS=peer0.ydsfjatim.example.local:8051 \
  ${FABRIC_TOOLS_IMAGE} \
  peer channel join -b ./channel-artifacts/zakat-channel.block

# Package and install chaincode
echo "Packaging and installing chaincode..."
docker run --rm \
  -v ${PROJECT_ROOT}:/opt/fabric-zakat \
  -w /opt/fabric-zakat \
  --network fabric_test \
  -e CORE_PEER_TLS_ENABLED=true \
  -e CORE_PEER_LOCALMSPID="${MALANG_MSP}" \
  -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/fabric-zakat/organizations/peerOrganizations/ydsfmalang.example.local/peers/peer0.ydsfmalang.example.local/tls/ca.crt \
  -e CORE_PEER_MSPCONFIGPATH=/opt/fabric-zakat/organizations/peerOrganizations/ydsfmalang.example.local/users/Admin@ydsfmalang.example.local/msp \
  -e CORE_PEER_ADDRESS=peer0.ydsfmalang.example.local:7051 \
  -e GOPATH=/opt/fabric-zakat/chaincode \
  -e GO111MODULE=on \
  -e GOFLAGS=-buildvcs=false \
  ${FABRIC_TOOLS_IMAGE} \
  bash -c '
    cd /opt/fabric-zakat/chaincode/zakat && go mod vendor
    cd /opt/fabric-zakat
    peer lifecycle chaincode package scripts/temp/zakat.tar.gz --path chaincode/zakat --lang golang --label zakat_1.0
    peer lifecycle chaincode install scripts/temp/zakat.tar.gz
    PACKAGE_ID=$(peer lifecycle chaincode queryinstalled | grep "zakat_1.0" | cut -d" " -f3 | cut -d"," -f1)
    echo "$PACKAGE_ID" > scripts/temp/package_id.txt
  '

# Install chaincode on YDSFJatim
echo "Installing chaincode on YDSFJatim..."
docker run --rm \
  -v ${PROJECT_ROOT}:/opt/fabric-zakat \
  -w /opt/fabric-zakat \
  --network fabric_test \
  -e CORE_PEER_TLS_ENABLED=true \
  -e CORE_PEER_LOCALMSPID="${JATIM_MSP}" \
  -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/fabric-zakat/organizations/peerOrganizations/ydsfjatim.example.local/peers/peer0.ydsfjatim.example.local/tls/ca.crt \
  -e CORE_PEER_MSPCONFIGPATH=/opt/fabric-zakat/organizations/peerOrganizations/ydsfjatim.example.local/users/Admin@ydsfjatim.example.local/msp \
  -e CORE_PEER_ADDRESS=peer0.ydsfjatim.example.local:8051 \
  ${FABRIC_TOOLS_IMAGE} \
  peer lifecycle chaincode install scripts/temp/zakat.tar.gz

# Get package ID
PACKAGE_ID=$(cat ${PROJECT_ROOT}/scripts/temp/package_id.txt)

# Approve chaincode for YDSFMalang
echo "Approving chaincode for YDSFMalang..."
docker run --rm \
  -v ${PROJECT_ROOT}:/opt/fabric-zakat \
  -w /opt/fabric-zakat \
  --network fabric_test \
  -e CORE_PEER_TLS_ENABLED=true \
  -e CORE_PEER_LOCALMSPID="${MALANG_MSP}" \
  -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/fabric-zakat/organizations/peerOrganizations/ydsfmalang.example.local/peers/peer0.ydsfmalang.example.local/tls/ca.crt \
  -e CORE_PEER_MSPCONFIGPATH=/opt/fabric-zakat/organizations/peerOrganizations/ydsfmalang.example.local/users/Admin@ydsfmalang.example.local/msp \
  -e CORE_PEER_ADDRESS=peer0.ydsfmalang.example.local:7051 \
  ${FABRIC_TOOLS_IMAGE} \
  peer lifecycle chaincode approveformyorg -o orderer.example.local:7050 \
    --channelID zakat-channel --name zakat --version 1.0 --package-id ${PACKAGE_ID} \
    --sequence 1 --tls --cafile /opt/fabric-zakat/organizations/ordererOrganizations/example.local/orderers/orderer.example.local/msp/tlscacerts/tlsca.example.local-cert.pem

# Approve chaincode for YDSFJatim
echo "Approving chaincode for YDSFJatim..."
docker run --rm \
  -v ${PROJECT_ROOT}:/opt/fabric-zakat \
  -w /opt/fabric-zakat \
  --network fabric_test \
  -e CORE_PEER_TLS_ENABLED=true \
  -e CORE_PEER_LOCALMSPID="${JATIM_MSP}" \
  -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/fabric-zakat/organizations/peerOrganizations/ydsfjatim.example.local/peers/peer0.ydsfjatim.example.local/tls/ca.crt \
  -e CORE_PEER_MSPCONFIGPATH=/opt/fabric-zakat/organizations/peerOrganizations/ydsfjatim.example.local/users/Admin@ydsfjatim.example.local/msp \
  -e CORE_PEER_ADDRESS=peer0.ydsfjatim.example.local:8051 \
  ${FABRIC_TOOLS_IMAGE} \
  peer lifecycle chaincode approveformyorg -o orderer.example.local:7050 \
    --channelID zakat-channel --name zakat --version 1.0 --package-id ${PACKAGE_ID} \
    --sequence 1 --tls --cafile /opt/fabric-zakat/organizations/ordererOrganizations/example.local/orderers/orderer.example.local/msp/tlscacerts/tlsca.example.local-cert.pem

# Commit chaincode definition
echo "Committing chaincode definition..."
docker run --rm \
  -v ${PROJECT_ROOT}:/opt/fabric-zakat \
  -w /opt/fabric-zakat \
  --network fabric_test \
  -e CORE_PEER_TLS_ENABLED=true \
  -e CORE_PEER_LOCALMSPID="${MALANG_MSP}" \
  -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/fabric-zakat/organizations/peerOrganizations/ydsfmalang.example.local/peers/peer0.ydsfmalang.example.local/tls/ca.crt \
  -e CORE_PEER_MSPCONFIGPATH=/opt/fabric-zakat/organizations/peerOrganizations/ydsfmalang.example.local/users/Admin@ydsfmalang.example.local/msp \
  -e CORE_PEER_ADDRESS=peer0.ydsfmalang.example.local:7051 \
  ${FABRIC_TOOLS_IMAGE} \
  peer lifecycle chaincode commit -o orderer.example.local:7050 \
    --channelID zakat-channel --name zakat --version 1.0 \
    --sequence 1 --tls --cafile /opt/fabric-zakat/organizations/ordererOrganizations/example.local/orderers/orderer.example.local/msp/tlscacerts/tlsca.example.local-cert.pem \
    --peerAddresses peer0.ydsfmalang.example.local:7051 --tlsRootCertFiles /opt/fabric-zakat/organizations/peerOrganizations/ydsfmalang.example.local/peers/peer0.ydsfmalang.example.local/tls/ca.crt \
    --peerAddresses peer0.ydsfjatim.example.local:8051 --tlsRootCertFiles /opt/fabric-zakat/organizations/peerOrganizations/ydsfjatim.example.local/peers/peer0.ydsfjatim.example.local/tls/ca.crt

echo "Network is ready and chaincode is deployed!"

# Wait for chaincode to be fully initialized
echo "Waiting for chaincode to be fully initialized..."
sleep 5

# Function to check peer connectivity
check_peer_connectivity() {
    # Check YDSFMalang peer
    docker run --rm \
      -v ${PROJECT_ROOT}:/opt/fabric-zakat \
      -w /opt/fabric-zakat \
      --network fabric_test \
      -e CORE_PEER_TLS_ENABLED=true \
      -e CORE_PEER_LOCALMSPID="${MALANG_MSP}" \
      -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/fabric-zakat/organizations/peerOrganizations/ydsfmalang.example.local/peers/peer0.ydsfmalang.example.local/tls/ca.crt \
      -e CORE_PEER_MSPCONFIGPATH=/opt/fabric-zakat/organizations/peerOrganizations/ydsfmalang.example.local/users/Admin@ydsfmalang.example.local/msp \
      -e CORE_PEER_ADDRESS=peer0.ydsfmalang.example.local:7051 \
      ${FABRIC_TOOLS_IMAGE} \
      peer channel getinfo -c zakat-channel
}

echo "Testing peer connectivity..."
check_peer_connectivity

echo "Local test network is ready!"
echo "If you need to clean up the development environment, run the cleanup.sh script in the dev directory."
