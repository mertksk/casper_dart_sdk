// Export the proper Condor transaction implementation
export 'transaction_condor.dart' show TransactionCondor, TransactionHeader, TransactionApproval, TransactionPayload, TransferPayload, DeployWasmPayload, ContractCallPayload;

// For backward compatibility, create a type alias
typedef Transaction = TransactionCondor;