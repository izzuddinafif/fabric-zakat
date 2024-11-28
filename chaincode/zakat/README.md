# Zakat Chaincode

## Overview
This Hyperledger Fabric chaincode manages Zakat transactions for YDSF Malang and YDSF Jatim organizations. It provides a transparent and immutable record of Zakat collection and distribution.

## Chaincode Functions

### `AddZakat(zakatId, donorName, amount, zakatType, organization, date)`
- **Description**: Record a new Zakat donation
- **Parameters**:
  - `zakatId`: Unique identifier for the Zakat transaction
  - `donorName`: Name of the Zakat donor
  - `amount`: Monetary amount of Zakat
  - `zakatType`: Type of Zakat (e.g., maal, fitrah)
  - `organization`: Receiving organization
  - `date`: Date of donation

### `QueryZakat(zakatId)`
- **Description**: Retrieve details of a specific Zakat transaction
- **Parameters**:
  - `zakatId`: Unique identifier for the Zakat transaction
- **Returns**: Complete transaction details

### `DistributeZakat(zakatId, recipientName, amount, date)`
- **Description**: Record Zakat distribution to a beneficiary
- **Parameters**:
  - `zakatId`: Identifier of the original Zakat donation
  - `recipientName`: Name of the Zakat recipient
  - `amount`: Amount distributed
  - `date`: Date of distribution

### `GetAllZakat()`
- **Description**: Retrieve all Zakat transactions
- **Returns**: List of all Zakat transactions

## Transaction Flow
1. Donor contributes Zakat via `AddZakat()`
2. Organization tracks donation
3. Beneficiary receives Zakat via `DistributeZakat()`
4. Full transaction history maintained

## Security and Compliance
- Multi-organization validation
- Immutable transaction records
- Transparent audit trail

## Technical Details
- **Language**: Go
- **Hyperledger Fabric Version**: 2.4.0
- **Consensus**: Raft (Crash Fault Tolerant)
- **State Database**: LevelDB

## Development
- Developed for YDSF Malang and YDSF Jatim
- Part of Islamic charitable giving blockchain solution

## Usage Example
```bash
# Add Zakat donation
peer chaincode invoke -C zakat-channel -n zakat -c '{"function":"AddZakat","Args":["zakat1", "Ahmad", "5000000", "maal", "YDSFMalang", "2024-01-15"]}'

# Distribute Zakat
peer chaincode invoke -C zakat-channel -n zakat -c '{"function":"DistributeZakat","Args":["zakat1", "Muhammad", "1000000", "2024-01-20"]}'
