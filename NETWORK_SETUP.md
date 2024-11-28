# **Fabric Zakat Network Setup Guide**

This guide provides detailed instructions for setting up the Fabric Zakat blockchain network.

## **Table of Contents**
1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Network Setup Steps](#network-setup-steps)
4. [Directory Structure](#directory-structure)
5. [Environment Variables](#environment-variables)
6. [Production Deployment](#production-deployment)
7. [Troubleshooting](#troubleshooting)
8. [Security Considerations](#security-considerations)

## **Prerequisites**

- Go 1.20+
- Docker and Docker Compose
- Hyperledger Fabric 2.4.0
- OpenSSL
- Git

## **Initial Setup**

1. Install Fabric binaries and Docker images:
```bash
./install-fabric.sh
```

2. Set up environment variables:
```bash
cd scripts/demo
source env.sh
```

## **Network Setup Steps**

### **1. Clean Previous Network**

```bash
./00_cleanup.sh
```

This will:
- Remove all generated crypto materials
- Clean up Docker containers and volumes
- Remove temporary files

### **2. Generate Network Materials**

```bash
cd $PROJECT_ROOT
./generate.sh
```

This script:
- Uses configs from dev/ or prod/ based on environment
- Generates crypto materials for all organizations
- Creates genesis block
- Creates channel transaction files

### **3. Start the Network**

```bash
cd scripts/demo
./01_network_setup.sh
```

This starts:
- Orderer node
- YDSF Malang peer
- YDSF Jatim peer

### **4. Create and Join Channel**

```bash
./02_channel_setup.sh
```

This:
- Creates zakat-channel
- Joins all peers to the channel
- Updates anchor peers

### **5. Deploy Chaincode**

```bash
./03_chaincode_setup.sh
```

This:
- Packages the zakat chaincode
- Installs it on all peers
- Approves chaincode for both organizations
- Commits chaincode definition

### **6. Test the Network**

```bash
./04_test_chaincode.sh
```

## **Directory Structure**

```
fabric-zakat/
├── bin/                  # Fabric binaries
├── chaincode/           # Chaincode source
├── config/
│   ├── dev/            # Development configs
│   └── prod/           # Production configs
├── scripts/
│   └── demo/           # Setup scripts
└── generate.sh         # Network material generation
```

## **Environment Variables**

Key environment variables (defined in env.sh):
- PROJECT_ROOT: Base project directory
- CONFIG_PATH: Configuration files location
- CHANNEL_NAME: Name of the channel (zakat-channel)
- Organization MSPs:
  * MALANG_MSP: YDSFMalangMSP
  * JATIM_MSP: YDSFJatimMSP

## **Production Deployment**

For production:
1. Use configs from config/prod/
2. Secure crypto materials
3. Use proper domain names
4. Enable TLS
5. Configure proper access control

## **Troubleshooting**

### **Common Issues**

1. Path Resolution
- Ensure PROJECT_ROOT is set correctly
- Use absolute paths in Docker volumes

2. Docker Issues
- Run cleanup script
- Check Docker daemon
- Verify network connectivity

3. Chaincode Issues
- Check vendor dependencies
- Verify package IDs
- Check endorsement policies

### **Debug Tips**

1. Check logs:
```bash
docker logs peer0.ydsfmalang.example.local
docker logs orderer.example.local
```

2. Verify network status:
```bash
docker ps
docker network ls
```

3. Check crypto materials:
```bash
ls -l ${PROJECT_ROOT}/organizations/peerOrganizations
```

## **Security Considerations**

1. Production Environment:
- Secure private keys
- Use proper certificates
- Enable TLS
- Configure proper access control

2. Network Access:
- Restrict port access
- Use firewalls
- Monitor network traffic

3. Data Privacy:
- Use private data collections
- Implement proper ACLs
- Regular security audits
