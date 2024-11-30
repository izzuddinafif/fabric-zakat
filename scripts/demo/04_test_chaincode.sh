#!/bin/bash

# Set the base path for the project
FABRIC_ZAKAT_PATH="/home/afif/fabric-zakat"

# Function to format JSON output
format_json() {
  if [[ $1 == {* ]] || [[ $1 == \[* ]]; then
    echo "$1" | jq '.'
  else
    echo "$1"
  fi
}

# Test 1: Adding a new zakat transaction
echo "Test 1: Adding a new zakat transaction..."
echo " Invoking chaincode on YDSFMalang..."
echo " Command to be executed:"
echo " peer chaincode invoke -C zakat-channel -n zakat -c '{\"function\":\"AddZakat\",\"Args\":[\"ZKT-YDSF-MLG-202401-0001\", \"afif\", \"2500000\", \"maal\", \"YDSF Malang\", \"2024-01-26T12:00:00Z\"]}'"
echo
RESULT=$(docker run --rm \
  -v ${FABRIC_ZAKAT_PATH}:/opt/fabric-zakat \
  -w /opt/fabric-zakat/scripts \
  --network fabric_test \
  -e CORE_PEER_TLS_ENABLED=true \
  -e CORE_PEER_LOCALMSPID="YDSFMalangMSP" \
  -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/fabric-zakat/organizations/peerOrganizations/ydsfmalang.example.local/peers/peer0.ydsfmalang.example.local/tls/ca.crt \
  -e CORE_PEER_MSPCONFIGPATH=/opt/fabric-zakat/organizations/peerOrganizations/ydsfmalang.example.local/users/Admin@ydsfmalang.example.local/msp \
  -e CORE_PEER_ADDRESS=peer0.ydsfmalang.example.local:7051 \
  hyperledger/fabric-tools:2.4 \
  peer chaincode invoke -o orderer.example.local:7050 --tls --cafile /opt/fabric-zakat/organizations/ordererOrganizations/example.local/orderers/orderer.example.local/msp/tlscacerts/tlsca.example.local-cert.pem -C zakat-channel -n zakat -c '{"function":"AddZakat","Args":["ZKT-YDSF-MLG-202401-0001", "afif", "2500000", "maal", "YDSF Malang", "2024-01-26T12:00:00Z"]}')
format_json "$RESULT"

# Wait for transaction to be committed
sleep 5

# Test 2: Querying zakat details
echo -e "\nTest 2: Querying zakat details..."
echo " Querying chaincode on YDSFMalang..."
echo " Command to be executed:"
echo " peer chaincode query -C zakat-channel -n zakat -c '{\"function\":\"QueryZakat\",\"Args\":[\"ZKT-YDSF-MLG-202401-0001\"]}'"
echo
RESULT=$(docker run --rm \
  -v ${FABRIC_ZAKAT_PATH}:/opt/fabric-zakat \
  -w /opt/fabric-zakat/scripts \
  --network fabric_test \
  -e CORE_PEER_TLS_ENABLED=true \
  -e CORE_PEER_LOCALMSPID="YDSFMalangMSP" \
  -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/fabric-zakat/organizations/peerOrganizations/ydsfmalang.example.local/peers/peer0.ydsfmalang.example.local/tls/ca.crt \
  -e CORE_PEER_MSPCONFIGPATH=/opt/fabric-zakat/organizations/peerOrganizations/ydsfmalang.example.local/users/Admin@ydsfmalang.example.local/msp \
  -e CORE_PEER_ADDRESS=peer0.ydsfmalang.example.local:7051 \
  hyperledger/fabric-tools:2.4 \
  peer chaincode query -C zakat-channel -n zakat -c '{"function":"QueryZakat","Args":["ZKT-YDSF-MLG-202401-0001"]}')
format_json "$RESULT"

# Wait for query to complete
sleep 2

# Test 3: Distributing zakat
echo -e "\nTest 3: Distributing zakat..."
echo " Invoking chaincode on YDSFJatim..."
echo " Command to be executed:"
echo " peer chaincode invoke -C zakat-channel -n zakat -c '{\"function\":\"DistributeZakat\",\"Args\":[\"ZKT-YDSF-MLG-202401-0001\", \"ahmad\", \"500000\", \"2024-01-26T12:00:00Z\"]}'"
echo
RESULT=$(docker run --rm \
  -v ${FABRIC_ZAKAT_PATH}:/opt/fabric-zakat \
  -w /opt/fabric-zakat/scripts \
  --network fabric_test \
  -e CORE_PEER_TLS_ENABLED=true \
  -e CORE_PEER_LOCALMSPID="YDSFJatimMSP" \
  -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/fabric-zakat/organizations/peerOrganizations/ydsfjatim.example.local/peers/peer0.ydsfjatim.example.local/tls/ca.crt \
  -e CORE_PEER_MSPCONFIGPATH=/opt/fabric-zakat/organizations/peerOrganizations/ydsfjatim.example.local/users/Admin@ydsfjatim.example.local/msp \
  -e CORE_PEER_ADDRESS=peer0.ydsfjatim.example.local:8051 \
  hyperledger/fabric-tools:2.4 \
  peer chaincode invoke -o orderer.example.local:7050 --tls --cafile /opt/fabric-zakat/organizations/ordererOrganizations/example.local/orderers/orderer.example.local/msp/tlscacerts/tlsca.example.local-cert.pem -C zakat-channel -n zakat -c '{"function":"DistributeZakat","Args":["ZKT-YDSF-MLG-202401-0001", "ahmad", "500000", "2024-01-26T12:00:00Z"]}')
format_json "$RESULT"

# Wait for distribution to be committed
sleep 5

# Test 4: Getting all zakat transactions
echo -e "\nTest 4: Getting all zakat transactions..."
echo " Querying chaincode on YDSFJatim..."
echo " Command to be executed:"
echo " peer chaincode query -C zakat-channel -n zakat -c '{\"function\":\"GetAllZakat\",\"Args\":[]}'"
echo
RESULT=$(docker run --rm \
  -v ${FABRIC_ZAKAT_PATH}:/opt/fabric-zakat \
  -w /opt/fabric-zakat/scripts \
  --network fabric_test \
  -e CORE_PEER_TLS_ENABLED=true \
  -e CORE_PEER_LOCALMSPID="YDSFJatimMSP" \
  -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/fabric-zakat/organizations/peerOrganizations/ydsfjatim.example.local/peers/peer0.ydsfjatim.example.local/tls/ca.crt \
  -e CORE_PEER_MSPCONFIGPATH=/opt/fabric-zakat/organizations/peerOrganizations/ydsfjatim.example.local/users/Admin@ydsfjatim.example.local/msp \
  -e CORE_PEER_ADDRESS=peer0.ydsfjatim.example.local:8051 \
  hyperledger/fabric-tools:2.4 \
  peer chaincode query -C zakat-channel -n zakat -c '{"function":"GetAllZakat","Args":[]}')
format_json "$RESULT"

echo -e "\n Chaincode testing complete!"
