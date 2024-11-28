package main

import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// SmartContract provides functions for managing zakat
type SmartContract struct {
	contractapi.Contract
}

// Zakat describes basic details of what makes up a zakat transaction
type Zakat struct {
	ID            string  `json:"ID"`
	Muzakki       string  `json:"muzakki"`
	Amount        float64 `json:"amount"`
	Type          string  `json:"type"`
	Status        string  `json:"status"`
	Organization  string  `json:"organization"`
	Timestamp     string  `json:"timestamp"`
	Mustahik      string  `json:"mustahik"`
	Distribution  float64 `json:"distribution"`
	DistributedAt string  `json:"distributedAt"`
}

// InitLedger adds a base set of zakat transactions to the ledger
func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	return nil
}

// AddZakat adds a new zakat transaction to the world state with given details
func (s *SmartContract) AddZakat(ctx contractapi.TransactionContextInterface, id string, muzakki string, amount float64, zakatType string, organization string, timestamp string) error {
	exists, err := s.ZakatExists(ctx, id)
	if err != nil {
		return err
	}
	if exists {
		return fmt.Errorf("the zakat transaction %s already exists", id)
	}

	zakat := Zakat{
		ID:           id,
		Muzakki:      muzakki,
		Amount:       amount,
		Type:         zakatType,
		Status:       "collected",
		Organization: organization,
		Timestamp:    timestamp,
		Mustahik:     "",
		Distribution: 0,
		DistributedAt: "",
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
