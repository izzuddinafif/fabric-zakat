# Fabric Zakat Network

A Hyperledger Fabric blockchain network for managing Zakat transactions between YDSF Malang and YDSF Jatim organizations.

## Overview

This project implements a blockchain network for managing and tracking Zakat transactions. It enables transparent recording of Zakat collection and distribution between multiple organizations.

## Quick Start

1. Install prerequisites
2. Clone the repository
3. Install Fabric:
```bash
./install-fabric.sh
```

4. Run the demo:
```bash
./demo.sh
```

## Prerequisites

- Go 1.20+
- Docker and Docker Compose
- Hyperledger Fabric 2.4.0
- OpenSSL
- Git

## Network Architecture

### Organizations
- YDSF Malang (`ydsfmalang.example.local`)
- YDSF Jatim (`ydsfjatim.example.local`)
- Orderer Org (`orderer.example.local`)

### Components
- 1 Orderer node (etcdraft)
- 2 Peer nodes (one per organization)
- 1 Channel (`zakat-channel`)
- LevelDB state database
- Zakat chaincode

## Docker Network

The default Docker network is `fabric_test`. This network connects all Hyperledger Fabric components, including peers, orderers, and instances.

## Repository Structure

```
fabric-zakat/
├── bin/                  # Fabric binaries
├── chaincode/
│   └── zakat/           # Zakat chaincode implementation
├── config/
│   ├── dev/             # Development environment configs
│   │   ├── configtx.yaml
│   │   └── crypto-config.yaml
│   ├── prod/            # Production environment configs
│   └── docker-compose-test.yaml
├── scripts/
│   ├── demo/            # Demo and testing scripts
│   │   ├── env.sh      # Environment variables
│   │   ├── 00_cleanup.sh
│   │   ├── 01_network_setup.sh
│   │   ├── 02_channel_setup.sh
│   │   ├── 03_chaincode_setup.sh
│   │   └── 04_test_chaincode.sh
│   └── temp/           # Temporary files directory
├── generate.sh         # Network material generation script
└── install-fabric.sh   # Fabric installation script
```

## Development Guide

### Environment Setup

1. **Install Prerequisites**: Ensure you have the following installed:
   - Go 1.20+
   - Docker and Docker Compose
   - OpenSSL
   - Git

2. **Source environment variables**: The `env.sh` script contains the necessary environment variables. Simply source it to set up your environment:
   ```bash
   cd scripts/demo
   source env.sh
   ```

3. **Generate network materials**:
   ```bash
   cd $PROJECT_ROOT
   ./generate.sh
   ```

4. **Start development network**:
   ```bash
   cd scripts/demo
   ./01_network_setup.sh
   ```

### Testing

Run the test script:
```bash
./04_test_chaincode.sh
```

This will:
- Create a test Zakat transaction
- Query the transaction
- Test endorsement policies

### Cleanup
The script now performs cleanup only in the event of a failure. This ensures that the network remains up for further testing if the script completes successfully. If you need to manually clean up resources, you can run the cleanup function separately.

### Error Handling
A trap is set up to handle errors and perform cleanup if the script exits with a non-zero status.

### Troubleshooting

- **Network Issues**: Ensure Docker is running and the correct network name is used.
- **Path Issues**: Verify that `PROJECT_ROOT` is set correctly.
- **Chaincode Errors**: Check Go environment and dependencies.

### Advanced Configuration

For custom configurations, modify the files in `config/dev/` and `config/prod/` to suit your environment needs.

## Production Deployment

For production environment:

1. Use configs from `config/prod/`
2. Update domain names in crypto-config
3. Configure proper TLS certificates
4. Set up proper access control
5. Enable security features

## Troubleshooting

### Common Issues

1. Path Resolution
- Ensure PROJECT_ROOT is set correctly
- Use absolute paths in Docker volumes

2. Docker Issues
- Run cleanup script
- Check Docker daemon
- Verify network connectivity

3. Chaincode Issues
- Check Go environment
- Verify dependencies
- Check package IDs

### Debug Tips

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

## Security Considerations

1. Network Security
- Enable TLS
- Configure firewalls
- Use proper certificates

2. Access Control
- Set proper MSP policies
- Configure endorsement policies
- Regular access audits

3. Data Privacy
- Use private data collections
- Implement proper ACLs
- Regular security audits

## Documentation

- [Network Setup Guide](NETWORK_SETUP.md)
- [Configuration Guide](config/README.md)
- [Scripts Documentation](scripts/README.md)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.