#!/bin/bash

# Get the directory where the script is located and source env.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/env.sh"

# Function to prompt for user input
prompt_continue() {
    echo -e "\n\033[1;33mPress Enter to continue...\033[0m"
    read
}

# Function to print section header
print_section() {
    echo -e "\n\033[1;33m========================================\033[0m"
    echo -e "\033[0;32m$1\033[0m"
    echo -e "\033[1;33m========================================\033[0m\n"
}

# Function to print step explanation
explain_step() {
    echo -e "\033[1;34m$1\033[0m\n"
}

# Step 1: Clean up previous network
print_section "Step 1: Cleaning up previous network"
explain_step "This step removes any existing network resources to ensure a clean start:
- Stops and removes all Docker containers
- Removes all Docker volumes
- Cleans up any leftover files"
prompt_continue

bash "${SCRIPT_DIR}/00_cleanup.sh"

# Step 2: Set up the network
print_section "Step 2: Setting up the network"
explain_step "This step sets up the Hyperledger Fabric network:
- Generates crypto materials using cryptogen
- Creates genesis block and channel artifacts
- Starts the network containers"
prompt_continue

bash "${SCRIPT_DIR}/01_network_setup.sh"

# Step 3: Set up the channel
print_section "Step 3: Setting up the channel"
explain_step "This step creates and configures the channel:
- Creates the channel
- Makes peers join the channel
- Updates anchor peers"
prompt_continue

bash "${SCRIPT_DIR}/02_channel_setup.sh"

# Step 4: Set up the chaincode
print_section "Step 4: Setting up the chaincode"
explain_step "This step deploys the Zakat chaincode:
- Packages the chaincode
- Installs it on all peers
- Approves it for both organizations
- Commits it to the channel"
prompt_continue

bash "${SCRIPT_DIR}/03_chaincode_setup.sh"

# Step 5: Test the chaincode
print_section "Step 5: Testing the chaincode"
explain_step "This step tests the deployed chaincode:
- Invokes chaincode functions
- Queries the ledger
- Verifies the results"
prompt_continue

bash "${SCRIPT_DIR}/04_test_chaincode.sh"

print_section "Demo Complete! 🎉"
echo -e "\033[0;32mThe Zakat blockchain network has been successfully set up and tested.\033[0m"
echo -e "\033[0;32mYou can now interact with the network using the provided APIs.\033[0m"

echo -e "\n\033[1;33m========================================\033[0m"
echo -e "\033[0;32mStep 6: Cleaning up\033[0m"
echo -e "\033[1;33m========================================\033[0m\n"

echo -e "\033[1;34mThis step cleans up all resources:
- Stops and removes all Docker containers
- Removes Docker volumes
- Cleans up generated files\033[0m\n"

echo -e "\033[1;33mPress Enter to continue...\033[0m"
read

bash "${SCRIPT_DIR}/00_cleanup.sh"

echo -e "\033[0;32m✅ Step completed successfully\033[0m\n"
