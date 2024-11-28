# Fabric Zakat Network (v1.0.0-rc1)

A Hyperledger Fabric blockchain network for managing Zakat transactions between YDSF Malang and YDSF Jatim organizations.

## Overview

This project implements a blockchain network for managing and tracking Zakat transactions. It enables transparent recording of Zakat collection and distribution between multiple organizations.

### Status: Release Candidate

This is a release candidate (RC) version where:
- Chaincode implementation is feature-complete and tested
- Basic network setup scripts are provided
- Network scripts are for development/testing only
- Production deployment requires additional security hardening

## Quick Start (Development)

1. Install prerequisites
2. Clone the repository
3. Install Fabric:
```bash
./install-fabric.sh
```

4. Run the development demo:
```bash
./scripts/demo/demo.sh
```

Note: These scripts are for development and testing purposes. For production deployment, follow Hyperledger Fabric's official guidelines.

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

## Zakat Chaincode (v1.0.0-rc1)

The Zakat chaincode provides a robust implementation for managing Zakat transactions on the Hyperledger Fabric network. It supports the following operations:

### Key Features

- **Initialize Ledger**: Bootstrap the ledger with initial Zakat data
- **Add Zakat**: Record new Zakat transactions with comprehensive validation
- **Query Zakat**: Retrieve specific Zakat transaction details
- **Get All Zakat**: List all recorded Zakat transactions
- **Distribute Zakat**: Track Zakat distribution to beneficiaries
- **Validate Transactions**: Comprehensive validation for all operations

### Data Model

```go
type Zakat struct {
    ID            string  `json:"ID"`           // Format: ZKT-ORG-YYYYMM-NNNN
    Muzakki       string  `json:"muzakki"`      // Zakat payer
    Amount        float64 `json:"amount"`       // Zakat amount
    Type          string  `json:"type"`         // maal/fitrah
    Status        string  `json:"status"`       // collected/distributed
    Organization  string  `json:"organization"` // YDSF Malang/YDSF Jatim
    Timestamp     string  `json:"timestamp"`    // ISO 8601 format
    Mustahik      string  `json:"mustahik"`     // Zakat recipient
    Distribution  float64 `json:"distribution"` // Distributed amount
    DistributedAt string  `json:"distributedAt"`// Distribution timestamp
}
```

### Validation Rules

- **Zakat ID**: Must follow format `ZKT-ORG-YYYYMM-NNNN`
- **Amount**: Must be positive
- **Type**: Must be either 'maal' or 'fitrah'
- **Organization**: Must be either 'YDSF Malang' or 'YDSF Jatim'
- **Timestamps**: Must be in ISO 8601 format
- **Status**: Automatically managed (collected → distributed)

### Testing

The chaincode includes comprehensive test coverage:
- Unit tests for all functions
- Error scenario testing
- Mock-based testing
- Table-driven tests

To run tests:
```bash
cd chaincode/zakat
go test -v
```

## Development Guide

### Environment Setup

1. **Install Prerequisites**: Ensure you have the following installed:
   - Go 1.20+
   - Docker and Docker Compose
   - OpenSSL
   - Git

2. **Source environment variables**: The `env.sh` script contains the necessary environment variables for development:
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

1. **Run the test suite**:
   ```bash
   cd chaincode/zakat
   go test -v
   ```

2. **Run the development network**:
   ```bash
   cd scripts/demo
   ./demo.sh
   ```

## Production Deployment

For production deployment:

1. Follow Hyperledger Fabric's official guidelines for production networks
2. Implement proper security measures:
   - Configure TLS certificates
   - Set up proper access control
   - Enable security features
   - Configure proper endorsement policies
3. Perform security audits
4. Set up monitoring and backup procedures

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- YDSF Malang
- YDSF Jatim
- Hyperledger Fabric Community

## Release Notes (v1.0.0-rc1)

### Features
- Complete Zakat management functionality
- Comprehensive validation and error handling
- Full test coverage
- Development and testing tools provided

### Supported Organizations
- YDSF Malang
- YDSF Jatim

### Requirements
- Hyperledger Fabric 2.4.0+
- Go 1.20+
- Docker and Docker Compose

### Status
- Initial release candidate
- Chaincode implementation complete
- Development scripts provided
- Pending production validation

### Security Notes
- Input validation for all parameters
- Status transitions are strictly controlled
- Organization validation enforced
- Transaction integrity checks
- Production hardening required

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