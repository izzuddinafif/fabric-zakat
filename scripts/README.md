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

This directory contains scripts for development and testing of the Fabric Zakat network. 
**Note: These scripts are intended for development and testing purposes only. For production deployment, follow Hyperledger Fabric's official guidelines.**

### Environment Setup (`env.sh`)
- Sets up required environment variables for development
- Defines paths and configuration locations
- Sets organization-specific variables for testing

### Running the Development Network

To set up and run the development network:

```bash
./demo.sh
```

This script handles development setup:
- Cleaning up previous network
- Generating test materials
- Starting development network
- Creating and joining test channel
- Deploying chaincode
- Running basic tests

### Docker Network

The development network uses `fabric_test` as the Docker network name. This is for development consistency only and should be reconfigured for production.

## Development Directory
The `dev` directory contains development testing resources:
- `test_local.sh`: Local development network testing
- `cleanup.sh`: Development environment cleanup

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

## Important Notes

1. These scripts are for development and testing only
2. Not suitable for production deployment as-is
3. Security features are minimal for development ease
4. Production deployment requires:
   - Proper security configuration
   - Network hardening
   - Access control setup
   - Monitoring implementation
   - Backup procedures

## License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.
