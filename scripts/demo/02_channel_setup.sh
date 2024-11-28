#!/bin/bash

# Source environment variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/env.sh"

echo "🔗 Setting up channel..."

# Create and join channel for YDSFMalang
echo "📝 Creating channel and joining YDSFMalang peer..."
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
  bash -c "
    peer channel create -o ${ORDERER_ADDRESS} -c ${CHANNEL_NAME} \
      -f channel-artifacts/${CHANNEL_NAME}.tx \
      --outputBlock channel-artifacts/${CHANNEL_NAME}.block \
      --tls --cafile /opt/fabric-zakat/organizations/ordererOrganizations/example.local/orderers/orderer.example.local/msp/tlscacerts/tlsca.example.local-cert.pem
    peer channel join -b channel-artifacts/${CHANNEL_NAME}.block
  "

# Join YDSFJatim peer to channel
echo "➕ Joining YDSFJatim peer to channel..."
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
  peer channel join -b channel-artifacts/${CHANNEL_NAME}.block

# Update anchor peers
echo "⚓ Updating anchor peers..."

# Update YDSFMalang anchor peer
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
  peer channel update -o ${ORDERER_ADDRESS} -c ${CHANNEL_NAME} \
    -f channel-artifacts/YDSFMalangMSPanchors.tx \
    --tls --cafile /opt/fabric-zakat/organizations/ordererOrganizations/example.local/orderers/orderer.example.local/msp/tlscacerts/tlsca.example.local-cert.pem

# Update YDSFJatim anchor peer
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
  peer channel update -o ${ORDERER_ADDRESS} -c ${CHANNEL_NAME} \
    -f channel-artifacts/YDSFJatimMSPanchors.tx \
    --tls --cafile /opt/fabric-zakat/organizations/ordererOrganizations/example.local/orderers/orderer.example.local/msp/tlscacerts/tlsca.example.local-cert.pem

echo "✅ Channel setup complete!"
