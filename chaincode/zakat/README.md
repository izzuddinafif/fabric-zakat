# Zakat Chaincode v1.0.0-rc1

## Overview
This Hyperledger Fabric chaincode manages Zakat transactions for YDSF Malang and YDSF Jatim organizations. It provides a transparent and immutable record of Zakat collection and distribution.

## Status
This is a release candidate (RC) version with:
- Feature-complete implementation
- Comprehensive validation rules
- Full test coverage
- Error handling
- Pending production validation

## Features
- Secure Zakat transaction management
- Comprehensive validation rules
- Full test coverage
- Production-ready error handling
- Support for multiple organizations
- Transparent distribution tracking

## Requirements
- Hyperledger Fabric 2.4.0+
- Go 1.20+
- Docker and Docker Compose

## Data Model

### Zakat Transaction
```go
type Zakat struct {
    ID            string  `json:"ID"`           // Format: ZKT-ORG-YYYYMM-NNNN
    Muzakki       string  `json:"muzakki"`      // Zakat donor's name
    Amount        float64 `json:"amount"`       // Amount in IDR
    Type          string  `json:"type"`         // "fitrah" or "maal"
    Status        string  `json:"status"`       // "collected" or "distributed"
    Organization  string  `json:"organization"` // Collecting organization
    Timestamp     string  `json:"timestamp"`    // ISO 8601 format
    Mustahik      string  `json:"mustahik"`     // Recipient's name (if distributed)
    Distribution  float64 `json:"distribution"` // Distributed amount
    DistributedAt string  `json:"distributedAt"`// Distribution timestamp (ISO 8601)
}
```

## ID Format
The Zakat ID follows a specific format to ensure uniqueness and traceability:
- Format: `ZKT-{ORG}-{YYYY}{MM}-{COUNTER}`
- Example: `ZKT-YDSF-MLG-202311-0001`
- Components:
  - `ZKT`: Fixed prefix for Zakat transactions
  - `ORG`: Organization identifier (e.g., YDSF-MLG, YDSF-JTM)
  - `YYYY`: 4-digit year
  - `MM`: 2-digit month
  - `COUNTER`: 4-digit sequential counter

## Chaincode Functions

### `InitLedger()`
- **Description**: Initializes the ledger with a sample Zakat transaction
- **Validation**:
  - Checks if initial transaction already exists
  - Validates all fields using standard validation functions
  - Uses current timestamp in ISO 8601 format
- **Error Handling**:
  - Returns descriptive errors for validation failures
  - Handles GetState and PutState errors
- **Returns**: Error if initialization fails

### `AddZakat(zakatId, donorName, amount, zakatType, organization, date)`
- **Description**: Records a new Zakat donation
- **Parameters**:
  - `zakatId`: Unique identifier (must follow ID format)
  - `donorName`: Name of the Zakat donor
  - `amount`: Monetary amount (must be positive)
  - `zakatType`: Type of Zakat ("maal" or "fitrah")
  - `organization`: Receiving organization (must be authorized)
  - `date`: Date of donation (ISO 8601 format)
- **Validation**:
  - Validates ID format
  - Checks for existing transactions
  - Validates amount and organization
  - Verifies timestamp format
- **Returns**: Error if validation fails or transaction exists

### `QueryZakat(zakatId)`
- **Description**: Retrieves details of a specific Zakat transaction
- **Parameters**:
  - `zakatId`: Unique identifier for the Zakat transaction
- **Returns**: Complete transaction details or error if not found

### `GetAllZakat()`
- **Description**: Retrieves all Zakat transactions from the ledger
- **Returns**: Array of all Zakat transactions
- **Error Handling**: Returns error if retrieval fails

### `DistributeZakat(zakatId, mustahik, amount, timestamp)`
- **Description**: Records the distribution of a Zakat transaction
- **Parameters**:
  - `zakatId`: Unique identifier of the Zakat to distribute
  - `mustahik`: Name of the recipient
  - `amount`: Amount distributed
  - `timestamp`: Distribution timestamp (ISO 8601)
- **Validation**:
  - Verifies Zakat exists and is not distributed
  - Validates distribution amount
  - Checks timestamp format
- **Returns**: Error if validation fails or Zakat not found

### `ZakatExists(zakatId)`
- **Description**: Checks if a Zakat transaction exists
- **Parameters**:
  - `zakatId`: Unique identifier to check
- **Returns**: Boolean indicating existence and any error

## Validation Rules

### ID Format
- Must follow pattern: `ZKT-{ORG}-{YYYY}{MM}-{COUNTER}`
- Organization must be valid
- Date components must be valid

### Amount
- Must be positive number
- Must be greater than 0
- Distribution amount cannot exceed original amount

### Organization
- Must be either "YDSF Malang" or "YDSF Jatim"
- Must be authorized in the network

### Type
- Must be either "maal" or "fitrah"
- Cannot be changed after creation

### Status
- Automatically set to "collected" on creation
- Changes to "distributed" after successful distribution
- Cannot be manually modified

### Timestamps
- Must be in ISO 8601 format
- Cannot be future dates
- Distribution date must be after collection date

## Testing
The chaincode includes comprehensive test coverage:
```bash
cd chaincode/zakat
go test -v
```

## Security Considerations
- Input validation for all parameters
- Status transitions are strictly controlled
- Organization validation enforced
- Transaction integrity checks
- No direct status manipulation allowed
- Timestamp validation to prevent future dating

## Transaction Flow
1. Organization receives Zakat via `AddZakat()`
2. Transaction is recorded with "collected" status
3. Organization distributes via `DistributeZakat()`
4. Status updates to "distributed"
5. Full history maintained on chain

## License
This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details.
