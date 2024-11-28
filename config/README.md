# Configuration Directory

This directory contains all configuration files for the Fabric Zakat network.

## Files Structure

```
config/
├── dev/                     # Development environment configs
│   ├── configtx.yaml       # Channel configuration for development
│   └── crypto-config.yaml  # Crypto configuration for development
├── prod/                    # Production environment configs
│   ├── configtx.yaml       # Channel configuration for production
│   └── crypto-config.yaml  # Crypto configuration for production
├── docker-compose-test.yaml # Docker compose for test network
└── README.md               # This documentation
```

## Environment Configuration

Development and production environments are separated into different directories:

### Development (`dev/`)
- `configtx.yaml`: Channel configuration for local development
- `crypto-config.yaml`: MSP configuration for development
- Used with docker-compose-test.yaml for local testing

### Production (`prod/`)
- `configtx.yaml`: Channel configuration for production deployment
- `crypto-config.yaml`: MSP configuration for production environment
- **Note**: Production configs should be managed securely and not committed to git

## Docker Compose

`docker-compose-test.yaml` defines the local test network with:
- Orderer node
- YDSF Malang peer
- YDSF Jatim peer
- CLI containers

## Generating Network Materials

Use the generate.sh script in the project root:
```bash
./generate.sh
```

This will:
1. Use configs from dev/ or prod/ based on environment
2. Generate crypto materials
3. Create genesis block
4. Create channel transaction files
