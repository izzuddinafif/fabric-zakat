#!/bin/bash

# Source environment variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/env.sh"

echo "📦 Setting up chaincode..."

# Package and install chaincode on YDSFMalang
echo "📥 Packaging and installing chaincode on YDSFMalang..."
docker run --rm \
  -v "${PROJECT_ROOT}:/opt/fabric-zakat" \
  -w /opt/fabric-zakat \
  --network ${DOCKER_NETWORK} \
  -e CORE_PEER_TLS_ENABLED=true \
  -e CORE_PEER_LOCALMSPID="${MALANG_MSP}" \
  -e CORE_PEER_TLS_ROOTCERT_FILE="/opt/fabric-zakat/organizations/peerOrganizations/ydsfmalang.example.local/peers/peer0.ydsfmalang.example.local/tls/ca.crt" \
  -e CORE_PEER_MSPCONFIGPATH="/opt/fabric-zakat/organizations/peerOrganizations/ydsfmalang.example.local/users/Admin@ydsfmalang.example.local/msp" \
  -e CORE_PEER_ADDRESS=${MALANG_PEER_ADDRESS} \
  -e GOPATH=/opt/fabric-zakat/chaincode \
  -e GO111MODULE=${GO111MODULE} \
  -e GOFLAGS="${GOFLAGS}" \
  ${FABRIC_TOOLS_IMAGE} \
  bash -c '
    cd /opt/fabric-zakat/chaincode/zakat && go mod vendor
    cd /opt/fabric-zakat
    
    peer lifecycle chaincode package scripts/temp/zakat.tar.gz --path chaincode/zakat --lang golang --label zakat_1.0
    peer lifecycle chaincode install scripts/temp/zakat.tar.gz
    
    # Get package ID and save it
    PACKAGE_ID=$(peer lifecycle chaincode queryinstalled | grep "zakat_1.0" | cut -d" " -f3 | cut -d"," -f1)
    echo "$PACKAGE_ID" > scripts/temp/package_id.txt
  '

# Install chaincode on YDSFJatim
echo "📥 Installing chaincode on YDSFJatim..."
docker run --rm \
  -v "${PROJECT_ROOT}:/opt/fabric-zakat" \
  -w /opt/fabric-zakat \
  --network ${DOCKER_NETWORK} \
  -e CORE_PEER_TLS_ENABLED=true \
  -e CORE_PEER_LOCALMSPID="${JATIM_MSP}" \
  -e CORE_PEER_TLS_ROOTCERT_FILE="/opt/fabric-zakat/organizations/peerOrganizations/ydsfjatim.example.local/peers/peer0.ydsfjatim.example.local/tls/ca.crt" \
  -e CORE_PEER_MSPCONFIGPATH="/opt/fabric-zakat/organizations/peerOrganizations/ydsfjatim.example.local/users/Admin@ydsfjatim.example.local/msp" \
  -e CORE_PEER_ADDRESS=${JATIM_PEER_ADDRESS} \
  ${FABRIC_TOOLS_IMAGE} \
  peer lifecycle chaincode install scripts/temp/zakat.tar.gz

# Get package ID
PACKAGE_ID=$(cat ${PROJECT_ROOT}/scripts/temp/package_id.txt)

# Approve chaincode for YDSFMalang
echo "✍️  Approving chaincode for YDSFMalang..."
docker run --rm \
  -v "${PROJECT_ROOT}:/opt/fabric-zakat" \
  -w /opt/fabric-zakat \
  --network ${DOCKER_NETWORK} \
  -e CORE_PEER_TLS_ENABLED=true \
  -e CORE_PEER_LOCALMSPID="${MALANG_MSP}" \
  -e CORE_PEER_TLS_ROOTCERT_FILE="/opt/fabric-zakat/organizations/peerOrganizations/ydsfmalang.example.local/peers/peer0.ydsfmalang.example.local/tls/ca.crt" \
  -e CORE_PEER_MSPCONFIGPATH="/opt/fabric-zakat/organizations/peerOrganizations/ydsfmalang.example.local/users/Admin@ydsfmalang.example.local/msp" \
  -e CORE_PEER_ADDRESS=${MALANG_PEER_ADDRESS} \
  ${FABRIC_TOOLS_IMAGE} \
  peer lifecycle chaincode approveformyorg -o ${ORDERER_ADDRESS} \
    --channelID ${CHANNEL_NAME} --name zakat --version 1.0 --package-id ${PACKAGE_ID} \
    --sequence 1 --tls --cafile /opt/fabric-zakat/organizations/ordererOrganizations/example.local/orderers/orderer.example.local/msp/tlscacerts/tlsca.example.local-cert.pem

# Approve chaincode for YDSFJatim
echo "✍️  Approving chaincode for YDSFJatim..."
docker run --rm \
  -v "${PROJECT_ROOT}:/opt/fabric-zakat" \
  -w /opt/fabric-zakat \
  --network ${DOCKER_NETWORK} \
  -e CORE_PEER_TLS_ENABLED=true \
  -e CORE_PEER_LOCALMSPID="${JATIM_MSP}" \
  -e CORE_PEER_TLS_ROOTCERT_FILE="/opt/fabric-zakat/organizations/peerOrganizations/ydsfjatim.example.local/peers/peer0.ydsfjatim.example.local/tls/ca.crt" \
  -e CORE_PEER_MSPCONFIGPATH="/opt/fabric-zakat/organizations/peerOrganizations/ydsfjatim.example.local/users/Admin@ydsfjatim.example.local/msp" \
  -e CORE_PEER_ADDRESS=${JATIM_PEER_ADDRESS} \
  ${FABRIC_TOOLS_IMAGE} \
  peer lifecycle chaincode approveformyorg -o ${ORDERER_ADDRESS} \
    --channelID ${CHANNEL_NAME} --name zakat --version 1.0 --package-id ${PACKAGE_ID} \
    --sequence 1 --tls --cafile /opt/fabric-zakat/organizations/ordererOrganizations/example.local/orderers/orderer.example.local/msp/tlscacerts/tlsca.example.local-cert.pem

# Commit chaincode definition
echo "✅ Committing chaincode definition..."
docker run --rm \
  -v "${PROJECT_ROOT}:/opt/fabric-zakat" \
  -w /opt/fabric-zakat \
  --network ${DOCKER_NETWORK} \
  -e CORE_PEER_TLS_ENABLED=true \
  -e CORE_PEER_LOCALMSPID="${MALANG_MSP}" \
  -e CORE_PEER_TLS_ROOTCERT_FILE="/opt/fabric-zakat/organizations/peerOrganizations/ydsfmalang.example.local/peers/peer0.ydsfmalang.example.local/tls/ca.crt" \
  -e CORE_PEER_MSPCONFIGPATH="/opt/fabric-zakat/organizations/peerOrganizations/ydsfmalang.example.local/users/Admin@ydsfmalang.example.local/msp" \
  -e CORE_PEER_ADDRESS=${MALANG_PEER_ADDRESS} \
  ${FABRIC_TOOLS_IMAGE} \
  peer lifecycle chaincode commit -o ${ORDERER_ADDRESS} \
    --channelID ${CHANNEL_NAME} --name zakat --version 1.0 \
    --sequence 1 --tls --cafile /opt/fabric-zakat/organizations/ordererOrganizations/example.local/orderers/orderer.example.local/msp/tlscacerts/tlsca.example.local-cert.pem \
    --peerAddresses ${MALANG_PEER_ADDRESS} --tlsRootCertFiles /opt/fabric-zakat/organizations/peerOrganizations/ydsfmalang.example.local/peers/peer0.ydsfmalang.example.local/tls/ca.crt \
    --peerAddresses ${JATIM_PEER_ADDRESS} --tlsRootCertFiles /opt/fabric-zakat/organizations/peerOrganizations/ydsfjatim.example.local/peers/peer0.ydsfjatim.example.local/tls/ca.crt

echo "⏳ Waiting for chaincode to be fully initialized..."
sleep 3

echo "✅ Chaincode setup complete!"
