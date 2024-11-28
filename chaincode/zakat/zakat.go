package main

import (
	"encoding/json"
	"fmt"
	"regexp"
	"time"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// SmartContract provides functions for managing zakat
type SmartContract struct {
	contractapi.Contract
}

// Zakat describes basic details of what makes up a zakat transaction
type Zakat struct {
	ID            string  `json:"ID"`            // Format: ZKT-{ORG}-{YYYY}{MM}-{COUNTER}
	Muzakki       string  `json:"muzakki"`       // Zakat donor's name
	Amount        float64 `json:"amount"`        // Amount in IDR
	Type          string  `json:"type"`          // "fitrah" or "maal"
	Status        string  `json:"status"`        // "collected" or "distributed"
	Organization  string  `json:"organization"`   // Collecting organization
	Timestamp     string  `json:"timestamp"`     // ISO 8601 format
	Mustahik      string  `json:"mustahik"`      // Recipient's name (if distributed)
	Distribution  float64 `json:"distribution"`   // Distributed amount
	DistributedAt string  `json:"distributedAt"` // Distribution timestamp (ISO 8601)
}

// validateZakatID checks if the provided ID follows the required format
func validateZakatID(id string) error {
	pattern := `^ZKT-YDSF-(MLG|JTM)-\d{6}-\d{4}$`
	matched, err := regexp.MatchString(pattern, id)
	if err != nil {
		return fmt.Errorf("error validating zakat ID format: %v", err)
	}
	if !matched {
		return fmt.Errorf("invalid zakat ID format. Expected format: ZKT-YDSF-{MLG|JTM}-YYYYMM-NNNN (e.g., ZKT-YDSF-MLG-202311-0001)")
	}
	return nil
}

// validateTimestamp checks if the provided timestamp is in ISO 8601 format
func validateTimestamp(timestamp string) error {
	_, err := time.Parse(time.RFC3339, timestamp)
	if err != nil {
		return fmt.Errorf("invalid timestamp format. Expected ISO 8601 format (e.g., 2023-11-28T12:00:00Z)")
	}
	return nil
}

// validateZakatType checks if the provided type is valid
func validateZakatType(zakatType string) error {
	if zakatType != "fitrah" && zakatType != "maal" {
		return fmt.Errorf("invalid zakat type. Must be either 'fitrah' or 'maal'")
	}
	return nil
}

// validateAmount checks if the provided amount is valid
func validateAmount(amount float64) error {
	if amount <= 0 {
		return fmt.Errorf("invalid amount. Must be greater than 0")
	}
	return nil
}

// validateOrganization checks if the provided organization is authorized
func validateOrganization(org string) error {
	if org != "YDSF Malang" && org != "YDSF Jatim" {
		return fmt.Errorf("invalid organization. Must be either 'YDSF Malang' or 'YDSF Jatim'")
	}
	return nil
}

// validateStatus checks if the provided status is valid
func validateStatus(status string) error {
	if status != "collected" && status != "distributed" {
		return fmt.Errorf("invalid status. Must be either 'collected' or 'distributed'")
	}
	return nil
}

// InitLedger adds a base set of zakat transactions to the ledger.
// This function is called when the chaincode is instantiated.
// It creates an initial zakat transaction with predefined values.
// If the initial zakat already exists, it returns an error.
// All fields are validated using the standard validation functions.
func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	// Check if initial zakat exists
	zakatID := "ZKT-YDSF-MLG-202311-0001"
	exists, err := ctx.GetStub().GetState(zakatID)
	if err != nil {
		return fmt.Errorf("failed to check initial zakat existence: %v", err)
	}
	if exists != nil {
		return fmt.Errorf("initial zakat already exists")
	}

	// Get current timestamp
	timestamp := time.Now().Format(time.RFC3339)

	// Create initial zakat transaction
	zakat := Zakat{
		ID:           zakatID,
		Muzakki:      "John Doe",
		Amount:       1000000,
		Type:         "maal",
		Status:       "collected",
		Organization: "YDSF Malang",
		Timestamp:    timestamp,
	}

	// Validate the initial zakat data
	if err := validateZakatID(zakat.ID); err != nil {
		return fmt.Errorf("invalid initial zakat ID: %v", err)
	}
	if err := validateAmount(zakat.Amount); err != nil {
		return fmt.Errorf("invalid initial zakat amount: %v", err)
	}
	if err := validateZakatType(zakat.Type); err != nil {
		return fmt.Errorf("invalid initial zakat type: %v", err)
	}
	if err := validateOrganization(zakat.Organization); err != nil {
		return fmt.Errorf("invalid initial zakat organization: %v", err)
	}
	if err := validateTimestamp(zakat.Timestamp); err != nil {
		return fmt.Errorf("invalid initial zakat timestamp: %v", err)
	}

	zakatJSON, err := json.Marshal(zakat)
	if err != nil {
		return fmt.Errorf("failed to marshal initial zakat: %v", err)
	}

	if err := ctx.GetStub().PutState(zakat.ID, zakatJSON); err != nil {
		return fmt.Errorf("failed to put initial zakat to world state: %v", err)
	}

	return nil
}

// AddZakat adds a new zakat transaction to the world state with given details
func (s *SmartContract) AddZakat(ctx contractapi.TransactionContextInterface, id string, muzakki string, amount float64, zakatType string, organization string, timestamp string) error {
	// Validate input parameters
	if err := validateZakatID(id); err != nil {
		return err
	}
	if err := validateAmount(amount); err != nil {
		return err
	}
	if err := validateZakatType(zakatType); err != nil {
		return err
	}
	if err := validateOrganization(organization); err != nil {
		return err
	}
	if err := validateTimestamp(timestamp); err != nil {
		return err
	}

	// Check if zakat already exists
	exists, err := s.ZakatExists(ctx, id)
	if err != nil {
		return err
	}
	if exists {
		return fmt.Errorf("the zakat %s already exists", id)
	}

	// Create the zakat
	zakat := Zakat{
		ID:           id,
		Muzakki:      muzakki,
		Amount:       amount,
		Type:         zakatType,
		Status:       "collected", // Initial status is always collected
		Organization: organization,
		Timestamp:    timestamp,
	}

	// Validate status
	if err := validateStatus(zakat.Status); err != nil {
		return err
	}

	zakatJSON, err := json.Marshal(zakat)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(id, zakatJSON)
}

// QueryZakat returns the zakat transaction stored in the world state with given id
func (s *SmartContract) QueryZakat(ctx contractapi.TransactionContextInterface, id string) (Zakat, error) {
	zakatJSON, err := ctx.GetStub().GetState(id)
	if err != nil {
		return Zakat{}, fmt.Errorf("failed to read from world state: %v", err)
	}
	if zakatJSON == nil {
		return Zakat{}, fmt.Errorf("the zakat transaction %s does not exist", id)
	}

	var zakat Zakat
	err = json.Unmarshal(zakatJSON, &zakat)
	if err != nil {
		return Zakat{}, fmt.Errorf("failed to unmarshal JSON: %v", err)
	}

	return zakat, nil
}

// GetAllZakat returns all zakat transactions found in world state
func (s *SmartContract) GetAllZakat(ctx contractapi.TransactionContextInterface) ([]Zakat, error) {
	resultsIterator, err := ctx.GetStub().GetStateByRange("", "")
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	var zakats []Zakat
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}

		var zakat Zakat
		err = json.Unmarshal(queryResponse.Value, &zakat)
		if err != nil {
			return nil, err
		}
		zakats = append(zakats, zakat)
	}

	return zakats, nil
}

// DistributeZakat updates a zakat transaction to mark it as distributed
func (s *SmartContract) DistributeZakat(ctx contractapi.TransactionContextInterface, id string, mustahik string, amount float64, timestamp string) error {
	zakat, err := s.QueryZakat(ctx, id)
	if err != nil {
		return err
	}

	if zakat.Status == "distributed" {
		return fmt.Errorf("zakat transaction %s has already been distributed", id)
	}

	if amount > zakat.Amount {
		return fmt.Errorf("distribution amount %f exceeds available amount %f", amount, zakat.Amount)
	}

	zakat.Status = "distributed"
	zakat.Mustahik = mustahik
	zakat.Distribution = amount
	zakat.DistributedAt = timestamp

	zakatJSON, err := json.Marshal(zakat)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(id, zakatJSON)
}

// ZakatExists returns true when zakat with given ID exists in world state
func (s *SmartContract) ZakatExists(ctx contractapi.TransactionContextInterface, id string) (bool, error) {
	zakatJSON, err := ctx.GetStub().GetState(id)
	if err != nil {
		return false, fmt.Errorf("failed to read from world state: %v", err)
	}

	return zakatJSON != nil, nil
}

func main() {
	chaincode, err := contractapi.NewChaincode(&SmartContract{})
	if err != nil {
		fmt.Printf("Error creating zakat chaincode: %s", err.Error())
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting zakat chaincode: %s", err.Error())
	}
}
