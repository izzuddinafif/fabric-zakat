#!/bin/bash

# Get the absolute path to the project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Exit immediately if a command exits with a non-zero status
set -e

# ==============================
# Configuration Variables
# ==============================

# URL to fetch the public SSH keys
PUBKEY_URL="https://github.com/izzuddinafif.keys"

# Log file path
LOG_FILE="${PROJECT_ROOT}/logs/init-ubuntu.log"

# Docker Compose version
DOCKER_COMPOSE_VERSION="2.26.1"

# Additional useful tools to install
ADDITIONAL_TOOLS="tree htop vim net-tools"

# ==============================
# Function Definitions
# ==============================

# Function to log messages with timestamps
log() {
  mkdir -p "$(dirname "${LOG_FILE}")"
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "${LOG_FILE}"
}

# Function to install packages
install_packages() {
  PACKAGES="$1"
  log "Installing packages: ${PACKAGES}"
  sudo apt-get install -y ${PACKAGES} >> "${LOG_FILE}" 2>&1
}

# Function to install Docker
install_docker() {
  log "Installing Docker..."

  # Remove any old versions
  sudo apt-get remove -y docker docker-engine docker.io containerd runc >> "${LOG_FILE}" 2>&1 || true

  # Update package index
  sudo apt-get update -y >> "${LOG_FILE}" 2>&1

  # Install prerequisites
  install_packages "apt-transport-https ca-certificates curl gnupg-agent software-properties-common"

  # Add Docker’s official GPG key
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - >> "${LOG_FILE}" 2>&1

  # Verify the key fingerprint
  sudo apt-key fingerprint 0EBFCD88 >> "${LOG_FILE}" 2>&1

  # Add Docker APT repository
  sudo add-apt-repository \
    "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable" >> "${LOG_FILE}" 2>&1

  # Update package index again
  sudo apt-get update -y >> "${LOG_FILE}" 2>&1

  # Install Docker Engine
  install_packages "docker-ce docker-ce-cli containerd.io"

  # Verify Docker installation
  sudo docker run hello-world >> "${LOG_FILE}" 2>&1
  log "Docker installed successfully."
}

# Function to install Docker Compose
install_docker_compose() {
  log "Installing Docker Compose..."

  # Download Docker Compose binary
  sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose >> "${LOG_FILE}" 2>&1

  # Apply executable permissions
  sudo chmod +x /usr/local/bin/docker-compose >> "${LOG_FILE}" 2>&1

  # Create a symbolic link (if not exists)
  if [ ! -L /usr/bin/docker-compose ]; then
    sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose >> "${LOG_FILE}" 2>&1
  fi

  # Verify installation
  docker-compose --version >> "${LOG_FILE}" 2>&1
  log "Docker Compose installed successfully."
}

# Function to configure Docker permissions
configure_docker_permissions() {
  TARGET_USER="$1"
  log "Configuring Docker permissions for user: ${TARGET_USER}"

  # Add the target user to the docker group
  sudo usermod -aG docker "${TARGET_USER}" >> "${LOG_FILE}" 2>&1

  log "Added ${TARGET_USER} to the docker group."
}

# Function to set up SSH access
setup_ssh_access() {
  TARGET_USER="$1"
  log "Setting up SSH access for user: ${TARGET_USER}"

  # Define the home directory
  USER_HOME=$(eval echo "~${TARGET_USER}")

  # Ensure .ssh directory exists
  sudo -u "${TARGET_USER}" mkdir -p "${USER_HOME}/.ssh"
  sudo chmod 700 "${USER_HOME}/.ssh"

  # Fetch and add public keys
  sudo -u "${TARGET_USER}" curl -fsSL "${PUBKEY_URL}" >> "${USER_HOME}/.ssh/authorized_keys" || true
  sudo chmod 600 "${USER_HOME}/.ssh/authorized_keys"

  log "SSH access configured successfully for user: ${TARGET_USER}"
}

# Function to install Hyperledger Fabric dependencies
install_hlf_dependencies() {
  log "Installing Hyperledger Fabric dependencies..."

  # Install Go (required for chaincode development)
  GO_VERSION="1.23.1"
  wget https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz >> "${LOG_FILE}" 2>&1
  sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz >> "${LOG_FILE}" 2>&1
  rm go${GO_VERSION}.linux-amd64.tar.gz
  echo "export PATH=\$PATH:/usr/local/go/bin" | sudo tee -a /etc/profile >> "${LOG_FILE}" 2>&1
  source /etc/profile

  # Verify Go installation
  go version >> "${LOG_FILE}" 2>&1
  log "Go installed successfully."

  # Install Node.js (optional, for SDKs)
  curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash - >> "${LOG_FILE}" 2>&1
  install_packages "nodejs"
  node -v >> "${LOG_FILE}" 2>&1
  npm -v >> "${LOG_FILE}" 2>&1
  log "Node.js installed successfully."

  # Install other dependencies if needed
  install_packages "jq unzip"

  log "Hyperledger Fabric dependencies installed successfully."
}

# Function to install additional useful tools
install_additional_tools() {
  log "Installing additional useful tools: ${ADDITIONAL_TOOLS}"
  install_packages "${ADDITIONAL_TOOLS}"
  log "Additional tools installed successfully."
}

# ==============================
# Main Script Execution
# ==============================

# Start logging
log "=== Server Initialization Script Started ==="

# Detect the non-root user (the user who invoked sudo)
if [ "$SUDO_USER" ]; then
  TARGET_USER="$SUDO_USER"
  log "Detected non-root user: ${TARGET_USER}"
else
  log "No SUDO_USER detected. Please run this script with sudo."
  exit 1
fi

# Update and upgrade the system
log "Updating and upgrading the system..."
sudo apt-get update -y >> "${LOG_FILE}" 2>&1
sudo apt-get upgrade -y >> "${LOG_FILE}" 2>&1
log "System updated and upgraded successfully."

# Install essential packages
install_packages "curl wget git unzip jq"

# Install Docker
install_docker

# Install Docker Compose
install_docker_compose

# Configure Docker permissions for the target user
configure_docker_permissions "${TARGET_USER}"

# Set up SSH access for the target user
setup_ssh_access "${TARGET_USER}"

# Install additional useful tools
install_additional_tools

# Install Hyperledger Fabric dependencies
install_hlf_dependencies

# Final log message
log "=== Server Initialization Script Completed Successfully ==="
log "Please log out and log back in to apply Docker group changes."

exit 0
