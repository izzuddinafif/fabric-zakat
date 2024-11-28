package main

import (
	"encoding/json"
	"fmt"
	"testing"
	"time"

	"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"github.com/hyperledger/fabric-protos-go/ledger/queryresult"
	"github.com/hyperledger/fabric-protos-go/peer"
	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// MockStub implements shim.ChaincodeStubInterface
type MockStub struct {
	mock.Mock
}

// Implement the required methods from ChaincodeStubInterface
func (m *MockStub) GetTxID() string {
	args := m.Called()
	return args.String(0)
}

func (m *MockStub) CreateCompositeKey(objectType string, attributes []string) (string, error) {
	args := m.Called(objectType, attributes)
	return args.String(0), args.Error(1)
}

func (m *MockStub) GetState(key string) ([]byte, error) {
	args := m.Called(key)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]byte), args.Error(1)
}

func (m *MockStub) PutState(key string, value []byte) error {
	args := m.Called(key, value)
	return args.Error(0)
}

func (m *MockStub) DelState(key string) error {
	args := m.Called(key)
	return args.Error(0)
}

func (m *MockStub) GetStateByRange(startKey string, endKey string) (shim.StateQueryIteratorInterface, error) {
	mockArgs := m.Called(startKey, endKey)
	return mockArgs.Get(0).(shim.StateQueryIteratorInterface), mockArgs.Error(1)
}

func (m *MockStub) GetStateByPartialCompositeKey(objectType string, keys []string) (shim.StateQueryIteratorInterface, error) {
	args := m.Called(objectType, keys)
	return args.Get(0).(shim.StateQueryIteratorInterface), args.Error(1)
}

func (m *MockStub) InvokeChaincode(chaincodeName string, chaincodeArgs [][]byte, channel string) peer.Response {
	mockArgs := m.Called(chaincodeName, chaincodeArgs, channel)
	return mockArgs.Get(0).(peer.Response)
}

func (m *MockStub) GetDecorations() map[string][]byte {
	mockArgs := m.Called()
	return mockArgs.Get(0).(map[string][]byte)
}

func (m *MockStub) GetChannelID() string {
	mockArgs := m.Called()
	return mockArgs.String(0)
}

func (m *MockStub) GetSignedProposal() (*peer.SignedProposal, error) {
	mockArgs := m.Called()
	return mockArgs.Get(0).(*peer.SignedProposal), mockArgs.Error(1)
}

func (m *MockStub) GetCreator() ([]byte, error) {
	mockArgs := m.Called()
	return mockArgs.Get(0).([]byte), mockArgs.Error(1)
}

func (m *MockStub) GetTransient() (map[string][]byte, error) {
	mockArgs := m.Called()
	return mockArgs.Get(0).(map[string][]byte), mockArgs.Error(1)
}

func (m *MockStub) GetBinding() ([]byte, error) {
	mockArgs := m.Called()
	return mockArgs.Get(0).([]byte), mockArgs.Error(1)
}

func (m *MockStub) GetArgsSlice() ([]byte, error) {
	mockArgs := m.Called()
	return mockArgs.Get(0).([]byte), mockArgs.Error(1)
}

func (m *MockStub) GetStringArgs() []string {
	mockArgs := m.Called()
	return mockArgs.Get(0).([]string)
}

func (m *MockStub) GetFunctionAndParameters() (string, []string) {
	mockArgs := m.Called()
	return mockArgs.String(0), mockArgs.Get(1).([]string)
}

func (m *MockStub) GetArgs() [][]byte {
	mockArgs := m.Called()
	return mockArgs.Get(0).([][]byte)
}

func (m *MockStub) SetStateValidationParameter(key string, ep []byte) error {
	mockArgs := m.Called(key, ep)
	return mockArgs.Error(0)
}

func (m *MockStub) GetStateValidationParameter(key string) ([]byte, error) {
	mockArgs := m.Called(key)
	return mockArgs.Get(0).([]byte), mockArgs.Error(1)
}

func (m *MockStub) GetHistoryForKey(key string) (shim.HistoryQueryIteratorInterface, error) {
	mockArgs := m.Called(key)
	return mockArgs.Get(0).(shim.HistoryQueryIteratorInterface), mockArgs.Error(1)
}

func (m *MockStub) GetPrivateData(collection, key string) ([]byte, error) {
	mockArgs := m.Called(collection, key)
	return mockArgs.Get(0).([]byte), mockArgs.Error(1)
}

func (m *MockStub) GetPrivateDataHash(collection, key string) ([]byte, error) {
	mockArgs := m.Called(collection, key)
	return mockArgs.Get(0).([]byte), mockArgs.Error(1)
}

func (m *MockStub) PutPrivateData(collection string, key string, value []byte) error {
	mockArgs := m.Called(collection, key, value)
	return mockArgs.Error(0)
}

func (m *MockStub) DelPrivateData(collection, key string) error {
	mockArgs := m.Called(collection, key)
	return mockArgs.Error(0)
}

func (m *MockStub) GetPrivateDataByRange(collection, startKey, endKey string) (shim.StateQueryIteratorInterface, error) {
	mockArgs := m.Called(collection, startKey, endKey)
	return mockArgs.Get(0).(shim.StateQueryIteratorInterface), mockArgs.Error(1)
}

func (m *MockStub) GetPrivateDataByPartialCompositeKey(collection, objectType string, keys []string) (shim.StateQueryIteratorInterface, error) {
	mockArgs := m.Called(collection, objectType, keys)
	return mockArgs.Get(0).(shim.StateQueryIteratorInterface), mockArgs.Error(1)
}

func (m *MockStub) GetPrivateDataQueryResult(collection, query string) (shim.StateQueryIteratorInterface, error) {
	mockArgs := m.Called(collection, query)
	return mockArgs.Get(0).(shim.StateQueryIteratorInterface), mockArgs.Error(1)
}

func (m *MockStub) GetQueryResult(query string) (shim.StateQueryIteratorInterface, error) {
	mockArgs := m.Called(query)
	return mockArgs.Get(0).(shim.StateQueryIteratorInterface), mockArgs.Error(1)
}

func (m *MockStub) GetStateByPartialCompositeKeyWithPagination(objectType string, keys []string, pageSize int32, bookmark string) (shim.StateQueryIteratorInterface, *peer.QueryResponseMetadata, error) {
	mockArgs := m.Called(objectType, keys, pageSize, bookmark)
	return mockArgs.Get(0).(shim.StateQueryIteratorInterface), mockArgs.Get(1).(*peer.QueryResponseMetadata), mockArgs.Error(2)
}

func (m *MockStub) GetQueryResultWithPagination(query string, pageSize int32, bookmark string) (shim.StateQueryIteratorInterface, *peer.QueryResponseMetadata, error) {
	mockArgs := m.Called(query, pageSize, bookmark)
	return mockArgs.Get(0).(shim.StateQueryIteratorInterface), mockArgs.Get(1).(*peer.QueryResponseMetadata), mockArgs.Error(2)
}

func (m *MockStub) GetStateByRangeWithPagination(startKey, endKey string, pageSize int32, bookmark string) (shim.StateQueryIteratorInterface, *peer.QueryResponseMetadata, error) {
	mockArgs := m.Called(startKey, endKey, pageSize, bookmark)
	return mockArgs.Get(0).(shim.StateQueryIteratorInterface), mockArgs.Get(1).(*peer.QueryResponseMetadata), mockArgs.Error(2)
}

func (m *MockStub) SetPrivateDataValidationParameter(collection, key string, ep []byte) error {
	mockArgs := m.Called(collection, key, ep)
	return mockArgs.Error(0)
}

func (m *MockStub) GetPrivateDataValidationParameter(collection, key string) ([]byte, error) {
	mockArgs := m.Called(collection, key)
	return mockArgs.Get(0).([]byte), mockArgs.Error(1)
}

func (m *MockStub) GetTxTimestamp() (*timestamppb.Timestamp, error) {
	mockArgs := m.Called()
	return mockArgs.Get(0).(*timestamppb.Timestamp), mockArgs.Error(1)
}

func (m *MockStub) MockTransactionStart(txid string) {
	m.Called(txid)
}

func (m *MockStub) MockTransactionEnd(txid string) {
	m.Called(txid)
}

func (m *MockStub) SetStub(stub interface{}) {
	m.Called(stub)
}

func (m *MockStub) PurgePrivateData(collection string, key string) error {
	mockArgs := m.Called(collection, key)
	return mockArgs.Error(0)
}

func (m *MockStub) SetEvent(name string, payload []byte) error {
	mockArgs := m.Called(name, payload)
	return mockArgs.Error(0)
}

func (m *MockStub) SplitCompositeKey(compositeKey string) (string, []string, error) {
	mockArgs := m.Called(compositeKey)
	return mockArgs.String(0), mockArgs.Get(1).([]string), mockArgs.Error(2)
}

// KV is a key/value pair used in QueryResult
type KV struct {
	Key   string
	Value []byte
}

// MockQueryIterator implements shim.StateQueryIteratorInterface for testing
type MockQueryIterator struct {
	mock.Mock
	Current int
	Items   []QueryResult
}

type QueryResult struct {
	Key   string
	Value []byte
}

func (m *MockQueryIterator) HasNext() bool {
	return m.Current+1 < len(m.Items)
}

func (m *MockQueryIterator) Next() (*queryresult.KV, error) {
	if !m.HasNext() {
		return nil, nil
	}
	m.Current++
	return &queryresult.KV{
		Key:   m.Items[m.Current].Key,
		Value: m.Items[m.Current].Value,
	}, nil
}

func (m *MockQueryIterator) Close() error {
	return nil
}

func TestInitLedger(t *testing.T) {
	t.Run("Success", func(t *testing.T) {
		chaincodeStub := new(MockStub)
		transactionContext := new(contractapi.TransactionContext)
		transactionContext.SetStub(chaincodeStub)

		now := time.Now()
		ts := &timestamppb.Timestamp{
			Seconds: now.Unix(),
			Nanos:   int32(now.Nanosecond()),
		}

		// Set up expectations for initial state check
		chaincodeStub.On("GetTxTimestamp").Return(ts, nil).Maybe()
		chaincodeStub.On("GetState", "ZKT-YDSF-MLG-202311-0001").Return(nil, nil)

		// Set up expectation for state update with mock.Anything for timestamp
		chaincodeStub.On("PutState", "ZKT-YDSF-MLG-202311-0001", mock.Anything).Return(nil).Run(func(args mock.Arguments) {
			// Verify the JSON structure
			var zakat Zakat
			err := json.Unmarshal(args.Get(1).([]byte), &zakat)
			require.NoError(t, err)

			// Verify all fields except timestamp
			require.Equal(t, "ZKT-YDSF-MLG-202311-0001", zakat.ID)
			require.Equal(t, "John Doe", zakat.Muzakki)
			require.Equal(t, float64(1000000), zakat.Amount)
			require.Equal(t, "maal", zakat.Type)
			require.Equal(t, "YDSF Malang", zakat.Organization)
			require.Equal(t, "collected", zakat.Status)

			// Verify timestamp format without exact matching
			_, err = time.Parse(time.RFC3339, zakat.Timestamp)
			require.NoError(t, err)
		})

		smartContract := new(SmartContract)
		err := smartContract.InitLedger(transactionContext)
		require.NoError(t, err)

		chaincodeStub.AssertExpectations(t)
	})

	t.Run("Already exists", func(t *testing.T) {
		chaincodeStub := new(MockStub)
		transactionContext := new(contractapi.TransactionContext)
		transactionContext.SetStub(chaincodeStub)

		// Set up expectation for existing zakat
		chaincodeStub.On("GetState", "ZKT-YDSF-MLG-202311-0001").Return([]byte("existing"), nil)

		smartContract := new(SmartContract)
		err := smartContract.InitLedger(transactionContext)
		require.Error(t, err)
		require.Contains(t, err.Error(), "initial zakat already exists")

		chaincodeStub.AssertExpectations(t)
	})

	t.Run("GetState error", func(t *testing.T) {
		chaincodeStub := new(MockStub)
		transactionContext := new(contractapi.TransactionContext)
		transactionContext.SetStub(chaincodeStub)

		// Set up expectation for GetState error
		chaincodeStub.On("GetState", "ZKT-YDSF-MLG-202311-0001").Return(nil, fmt.Errorf("GetState error"))

		smartContract := new(SmartContract)
		err := smartContract.InitLedger(transactionContext)
		require.Error(t, err)
		require.Contains(t, err.Error(), "failed to check initial zakat existence")

		chaincodeStub.AssertExpectations(t)
	})

	t.Run("PutState error", func(t *testing.T) {
		chaincodeStub := new(MockStub)
		transactionContext := new(contractapi.TransactionContext)
		transactionContext.SetStub(chaincodeStub)

		now := time.Now()
		ts := &timestamppb.Timestamp{
			Seconds: now.Unix(),
			Nanos:   int32(now.Nanosecond()),
		}

		// Set up expectations
		chaincodeStub.On("GetTxTimestamp").Return(ts, nil).Maybe()
		chaincodeStub.On("GetState", "ZKT-YDSF-MLG-202311-0001").Return(nil, nil)
		chaincodeStub.On("PutState", "ZKT-YDSF-MLG-202311-0001", mock.Anything).Return(fmt.Errorf("PutState error"))

		smartContract := new(SmartContract)
		err := smartContract.InitLedger(transactionContext)
		require.Error(t, err)
		require.Contains(t, err.Error(), "failed to put initial zakat to world state")

		chaincodeStub.AssertExpectations(t)
	})
}

func TestAddZakat(t *testing.T) {
	chaincodeStub := new(MockStub)
	transactionContext := new(contractapi.TransactionContext)
	transactionContext.SetStub(chaincodeStub)

	now := time.Now()
	ts := &timestamppb.Timestamp{
		Seconds: now.Unix(),
		Nanos:   int32(now.Nanosecond()),
	}

	zakat := Zakat{
		ID:           "ZKT-YDSF-MLG-202311-0001",
		Muzakki:      "John Doe",
		Amount:       1000000,
		Type:         "maal",
		Organization: "YDSF Malang",
		Timestamp:    now.Format(time.RFC3339),
	}

	// Set up expectations before calling the function
	chaincodeStub.On("GetTxTimestamp").Return(ts, nil).Maybe()
	chaincodeStub.On("GetState", zakat.ID).Return(nil, nil) // Zakat doesn't exist yet
	chaincodeStub.On("PutState", zakat.ID, mock.Anything).Return(nil)

	smartContract := new(SmartContract)
	err := smartContract.AddZakat(transactionContext, zakat.ID, zakat.Muzakki, zakat.Amount, zakat.Type, zakat.Organization, zakat.Timestamp)
	require.NoError(t, err)

	chaincodeStub.AssertExpectations(t)
}

func TestQueryZakat(t *testing.T) {
	chaincodeStub := new(MockStub)
	transactionContext := new(contractapi.TransactionContext)
	transactionContext.SetStub(chaincodeStub)

	now := time.Now()
	ts := &timestamppb.Timestamp{
		Seconds: now.Unix(),
		Nanos:   int32(now.Nanosecond()),
	}

	expectedZakat := Zakat{
		ID:           "ZKT-YDSF-MLG-202311-0001",
		Muzakki:      "John Doe",
		Amount:       1000000,
		Type:         "maal",
		Organization: "YDSF Malang",
		Status:       "collected",
		Timestamp:    now.Format(time.RFC3339),
	}

	zakatJSON, err := json.Marshal(expectedZakat)
	require.NoError(t, err)

	chaincodeStub.On("GetTxTimestamp").Return(ts, nil).Maybe()
	chaincodeStub.On("GetState", expectedZakat.ID).Return(zakatJSON, nil)

	smartContract := new(SmartContract)
	zakat, err := smartContract.QueryZakat(transactionContext, expectedZakat.ID)
	require.NoError(t, err)
	require.Equal(t, expectedZakat, zakat)

	chaincodeStub.AssertExpectations(t)
}

func TestGetAllZakat(t *testing.T) {
	chaincodeStub := new(MockStub)
	transactionContext := new(contractapi.TransactionContext)
	transactionContext.SetStub(chaincodeStub)

	now := time.Now()
	ts := &timestamppb.Timestamp{
		Seconds: now.Unix(),
		Nanos:   int32(now.Nanosecond()),
	}

	expectedZakat1 := Zakat{
		ID:           "ZKT-YDSF-MLG-202311-0001",
		Muzakki:      "John Doe",
		Amount:       1000000,
		Type:         "maal",
		Organization: "YDSF Malang",
		Status:       "collected",
		Timestamp:    now.Format(time.RFC3339),
	}

	expectedZakat2 := Zakat{
		ID:           "ZKT-YDSF-MLG-202311-0002",
		Muzakki:      "Jane Doe",
		Amount:       500000,
		Type:         "fitrah",
		Organization: "YDSF Malang",
		Status:       "collected",
		Timestamp:    now.Format(time.RFC3339),
	}

	iterator := &MockQueryIterator{
		Current: -1,
		Items:   []QueryResult{},
	}

	zakat1JSON, err := json.Marshal(expectedZakat1)
	require.NoError(t, err)
	iterator.Items = append(iterator.Items, QueryResult{
		Key:   expectedZakat1.ID,
		Value: zakat1JSON,
	})

	zakat2JSON, err := json.Marshal(expectedZakat2)
	require.NoError(t, err)
	iterator.Items = append(iterator.Items, QueryResult{
		Key:   expectedZakat2.ID,
		Value: zakat2JSON,
	})

	chaincodeStub.On("GetTxTimestamp").Return(ts, nil).Maybe()
	chaincodeStub.On("GetStateByRange", "", "").Return(iterator, nil)

	smartContract := new(SmartContract)
	zakats, err := smartContract.GetAllZakat(transactionContext)
	require.NoError(t, err)
	require.Equal(t, []Zakat{expectedZakat1, expectedZakat2}, zakats)

	chaincodeStub.AssertExpectations(t)
}

func TestDistributeZakat(t *testing.T) {
	chaincodeStub := new(MockStub)
	transactionContext := new(contractapi.TransactionContext)
	transactionContext.SetStub(chaincodeStub)

	now := time.Now()
	ts := &timestamppb.Timestamp{
		Seconds: now.Unix(),
		Nanos:   int32(now.Nanosecond()),
	}

	zakat := Zakat{
		ID:           "ZKT-YDSF-MLG-202311-0001",
		Muzakki:      "John Doe",
		Amount:       1000000,
		Type:         "maal",
		Organization: "YDSF Malang",
		Status:       "collected",
		Timestamp:    "2023-11-01T10:00:00Z",
	}

	zakatJSON, err := json.Marshal(zakat)
	require.NoError(t, err)

	chaincodeStub.On("GetTxTimestamp").Return(ts, nil).Maybe()
	chaincodeStub.On("GetState", zakat.ID).Return(zakatJSON, nil)
	chaincodeStub.On("PutState", zakat.ID, mock.Anything).Return(nil)

	smartContract := new(SmartContract)
	err = smartContract.DistributeZakat(transactionContext, zakat.ID, "Mustahik1", 1000000, now.Format(time.RFC3339))
	require.NoError(t, err)

	chaincodeStub.On("GetState", "non-existent-id").Return(nil, nil)
	err = smartContract.DistributeZakat(transactionContext, "non-existent-id", "Mustahik2", 1000000, now.Format(time.RFC3339))
	require.Error(t, err)
	require.Contains(t, err.Error(), "does not exist")

	chaincodeStub.AssertExpectations(t)
}

func TestZakatExists(t *testing.T) {
	chaincodeStub := new(MockStub)
	transactionContext := new(contractapi.TransactionContext)
	transactionContext.SetStub(chaincodeStub)

	now := time.Now()
	ts := &timestamppb.Timestamp{
		Seconds: now.Unix(),
		Nanos:   int32(now.Nanosecond()),
	}

	zakat := Zakat{
		ID:           "ZKT-YDSF-MLG-202311-0001",
		Muzakki:      "John Doe",
		Amount:       1000000,
		Type:         "maal",
		Organization: "YDSF Malang",
		Status:       "collected",
		Timestamp:    now.Format(time.RFC3339),
	}

	zakatJSON, err := json.Marshal(zakat)
	require.NoError(t, err)

	chaincodeStub.On("GetTxTimestamp").Return(ts, nil).Maybe()
	chaincodeStub.On("GetState", zakat.ID).Return(zakatJSON, nil)

	smartContract := new(SmartContract)
	exists, err := smartContract.ZakatExists(transactionContext, zakat.ID)
	require.NoError(t, err)
	require.True(t, exists)

	chaincodeStub.AssertExpectations(t)
}
