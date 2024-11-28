# Zakat Chaincode

## Overview
This Hyperledger Fabric chaincode manages Zakat transactions for YDSF Malang and YDSF Jatim organizations. It provides a transparent and immutable record of Zakat collection and distribution.

## Data Model

### Zakat Transaction
```go
type Zakat struct {
    ID            string  // Format: ZKT-{ORG}-{YYYY}{MM}-{COUNTER}
    Muzakki       string  // Zakat donor's name
    Amount        float64 // Amount in IDR
    Type          string  // "fitrah" or "maal"
    Status        string  // "collected" or "distributed"
    Organization  string  // Collecting organization
    Timestamp     string  // ISO 8601 format
    Mustahik      string  // Recipient's name (if distributed)
    Distribution  float64 // Distributed amount
    DistributedAt string  // Distribution timestamp (ISO 8601)
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

### ID Validation
- Must follow the specified format
- Organization part must match authorized organizations
- Year and month must be valid

### Amount Validation
- Must be positive number
- Must be greater than zero

### Organization Validation
- Must be either "YDSF Malang" or "YDSF Jatim"

### Timestamp Validation
- Must be in ISO 8601 format
- Must be parseable as a valid date/time

### Zakat Type Validation
- Must be either "maal" or "fitrah"

## Testing
The chaincode includes comprehensive test coverage:
- Unit tests for all functions
- Error case testing
- Mock implementations for chaincode interfaces
- Validation testing
- Edge case coverage

## Error Handling
All functions include proper error handling:
- Descriptive error messages
- Proper error propagation
- Transaction rollback on errors
- Validation error details

## Dependencies
- Hyperledger Fabric Contract API
- Hyperledger Fabric Chaincode Go
- Google Protocol Buffers
- Testify (for testing)

## Development
- Go version: 1.20+
- Uses standard Go modules
- Follows Go best practices
- Implements Hyperledger Fabric chaincode interfaces

## Security Considerations
- Input validation for all parameters
- Proper error handling
- No sensitive data exposure
- Transaction integrity checks
- Organization authorization checks

## Future Improvements
- Additional validation rules
- Enhanced error reporting
- Performance optimizations
- Additional query functions
- Batch processing support

## Transaction Flow
1. Donor contributes Zakat via `AddZakat()`
2. Organization tracks donation
3. Beneficiary receives Zakat via `DistributeZakat()`
4. Full transaction history maintained

## Usage Example
```bash
# Add Zakat donation
# Format: ZKT-YDSF-{MLG|JTM}-YYYYMM-NNNN
peer chaincode invoke -C zakat-channel -n zakat -c '{"function":"AddZakat","Args":["ZKT-YDSF-MLG-202401-0001", "Ahmad", "5000000", "maal", "YDSF Malang", "2024-01-15T00:00:00Z"]}'

# Distribute Zakat
peer chaincode invoke -C zakat-channel -n zakat -c '{"function":"DistributeZakat","Args":["ZKT-YDSF-MLG-202401-0001", "Muhammad", "1000000", "2024-01-20T00:00:00Z"]}'

# Query Zakat
peer chaincode query -C zakat-channel -n zakat -c '{"function":"QueryZakat","Args":["ZKT-YDSF-MLG-202401-0001"]}'

# Get All Zakat
peer chaincode query -C zakat-channel -n zakat -c '{"function":"GetAllZakat","Args":[]}'

```

Note:
- Zakat ID format: `ZKT-YDSF-{MLG|JTM}-YYYYMM-NNNN`
  - MLG: YDSF Malang
  - JTM: YDSF Jatim
  - YYYYMM: Year and month
  - NNNN: Sequential number
- Timestamp format: ISO 8601 (e.g., `2024-01-15T00:00:00Z`)
- Amount should be in IDR
- Zakat type should be either "fitrah" or "maal"
- Organization should be either "YDSF Malang" or "YDSF Jatim"
