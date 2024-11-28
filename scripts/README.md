# Scripts Directory

This directory contains all scripts for managing the Fabric Zakat network.

## Directory Structure

```
scripts/
├── demo/                # Development and testing scripts
│   ├── env.sh          # Environment variables
│   ├── 00_cleanup.sh   # Network cleanup
│   ├── 01_network_setup.sh    # Start network
│   ├── 02_channel_setup.sh    # Channel creation
│   ├── 03_chaincode_setup.sh  # Deploy chaincode
│   ├── 04_test_chaincode.sh   # Test network
│   └── demo.sh          # Run entire network
├── dev/                 # Development environment scripts
└── temp/               # Temporary files directory
```

## Development Scripts

### Environment Setup (`env.sh`)
- Sets up all required environment variables
- Defines paths and configuration locations
- Sets organization-specific variables

### Running the Network

To set up and run the entire Hyperledger Fabric Zakat network, simply use the `demo.sh` script:

```bash
./demo.sh
```

This single script handles all steps:
- Cleaning up previous network
- Generating network materials
- Starting the network
- Creating and joining the channel
- Deploying chaincode
- Running initial tests

### Docker Network

The network is configured with the name `fabric_test`. This ensures consistent networking across all Hyperledger Fabric components during development and testing.

## Development Directory
The `dev` directory contains scripts and resources for setting up and testing the development environment. It includes `test_local.sh` for local testing and `cleanup.sh` for cleaning up the environment after tests.

- **test_local.sh**: Script to set up and test the local development network.
- **cleanup.sh**: Script to clean up Docker containers, networks, and volumes, and remove generated artifacts to reset the development environment.

## Temporary Files

The `temp/` directory stores:
- Chaincode packages
- Package IDs
- Sequence numbers
- Other temporary artifacts

This directory is cleaned by `00_cleanup.sh`

## Error Handling

Each script:
- Checks for required environment variables
- Validates prerequisites
- Provides clear error messages
- Exits on critical failures

## Best Practices

1. Always source `env.sh` first
2. Run scripts in the correct order
3. Check logs for errors
4. Clean up before restarting network

## Troubleshooting

1. Path Issues
   - Verify PROJECT_ROOT is set
   - Check file permissions
   - Use absolute paths

2. Docker Problems
   - Run cleanup script
   - Check Docker service
   - Verify network connectivity

3. Chaincode Errors
   - Check Go environment
   - Verify dependencies
   - Check package IDs
