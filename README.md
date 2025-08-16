# Casper Dart SDK

The Dart package casper_dart_sdk is a comprehensive SDK for interacting with the Casper Blockchain, with full support for both **Legacy (Casper 1.x)** and **Condor (Casper 2.0)** networks.

## 🚀 Features

- ✅ **Full Condor (Casper 2.0) Support** - Complete transaction creation and submission
- ✅ **Legacy Network Compatibility** - Backward compatibility with Casper 1.x 
- ✅ **Automatic Network Detection** - Seamlessly works with both network types
- ✅ **Comprehensive Transaction Types** - Transfers, contract deployments, and contract calls
- ✅ **Cryptographic Key Management** - Ed25519 and Secp256k1 key pair support
- ✅ **Type-Safe RPC Client** - Full JSON-RPC 2.0 implementation
- ✅ **Production Ready** - Robust error handling and validation

## Requirements
- [Dart SDK](https://dart.dev/get-dart) version 3.8.0 or higher

## Installation

```yaml
dependencies:
  casper_dart_sdk: ^0.2.0-condor
```

## Quick Start

### Basic Usage
```dart
import 'package:casper_dart_sdk/casper_dart_sdk.dart';

// Create client
final client = CasperClient(Uri.parse("http://127.0.0.1:7777/rpc"));

// Check network status
final status = await client.getStatus();
print('Connected to: ${status.chainspecName}');

// Detect network version (Legacy vs Condor)
final version = await client.detectNetworkVersion();
print('Network type: $version');
```

### Condor Transaction Example
```dart
// Generate key pairs
final senderKeys = await Ed25519KeyPair.generate();
final recipientKeys = await Ed25519KeyPair.generate();

// Create a Condor transfer transaction
final transaction = TransactionCondor.standardTransfer(
  senderKeys.publicKey,
  recipientKeys.publicKey,
  BigInt.from(1000000000), // 1 CSPR
  BigInt.from(100000000),  // 0.1 CSPR for gas
  'casper-test',
  idTransfer: 12345,
);

// Sign the transaction
await transaction.sign(senderKeys);

// Submit to network (requires funded account)
try {
  final result = await client.putTransaction(transaction);
  print('Transaction submitted: ${result.transactionHash}');
} catch (e) {
  print('Submission failed: $e');
}
```

### Contract Deployment
```dart
// Deploy a smart contract (Condor)
final wasmBytes = await File('contract.wasm').readAsBytes();
final contractTx = TransactionCondor.contract(
  wasmBytes,
  deployerKeys.publicKey,
  BigInt.from(500000000), // Gas amount
  'casper-test',
);

await contractTx.sign(deployerKeys);
final result = await client.putTransaction(contractTx);
```

## 🌟 Condor vs Legacy

The SDK automatically detects and adapts to the network type:

| Feature | Legacy (Casper 1.x) | Condor (Casper 2.0) | SDK Support |
|---------|-------------------|-------------------|-------------|
| Transaction Format | `Deploy` | `TransactionCondor` | ✅ Both |
| Network Detection | Manual | Automatic | ✅ Auto |
| Transfer Method | `Deploy.standardTransfer()` | `TransactionCondor.standardTransfer()` | ✅ Both |
| RPC Submission | `putDeploy()` | `putTransaction()` | ✅ Both |
| Query Method | `getDeploy()` | `getTransaction()` | ✅ Both |

## 📖 Examples

Check out the example files for complete working demonstrations:

- **[basic_example.dart](example/basic_example.dart)** - Basic connectivity and status checking
- **[condor_offline_example.dart](example/condor_offline_example.dart)** - Offline Condor transaction creation  
- **[condor_transaction_example.dart](example/condor_transaction_example.dart)** - Full network transaction demo

## 🏗️ API Reference

### Core Classes

#### `CasperClient`
Main client for network interaction with automatic version detection.

```dart
final client = CasperClient(nodeUrl);
await client.detectNetworkVersion(); // Returns NetworkVersion.condor or .legacy
```

#### `TransactionCondor` (Condor Networks)
Modern transaction format for Casper 2.0:

```dart
// Standard transfer
TransactionCondor.standardTransfer(from, to, amount, paymentAmount, chainName)

// Native transfer  
TransactionCondor.transfer(from, to, amount, chainName)

// Contract deployment
TransactionCondor.contract(wasmBytes, deployer, paymentAmount, chainName)

// Contract call
TransactionCondor.contractCall(contractHash, entryPoint, args, caller, chainName)
```

#### `Deploy` (Legacy Networks)
Classic transaction format for Casper 1.x - fully supported for backward compatibility.

#### Key Management
```dart
// Generate new key pairs
final ed25519Keys = await Ed25519KeyPair.generate();
final secp256k1Keys = await Secp256k1KeyPair.generate();

// Sign transactions
await transaction.sign(keyPair);
```

The [usage.md](./doc/usage.md) document contains more detailed information about the SDK usage.

## Development

### Building

Get dependencies:
```bash
dart pub get
```

Generate serialization classes:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Testing

Run the working examples:
```bash
# Test offline Condor transaction creation
dart run example/condor_offline_example.dart

# Test basic SDK functionality  
dart run example/basic_example.dart

# Test network connectivity (requires running Casper node)
dart run example/condor_transaction_example.dart
```

Run unit tests:
```bash
dart test
```

Check code quality:
```bash
dart analyze
```

### Architecture

The SDK is organized into several key modules:

- **`src/types/`** - Core data structures (`TransactionCondor`, `Deploy`, etc.)
- **`src/jsonrpc/`** - RPC method definitions and parameter classes
- **`src/http/`** - HTTP client and JSON-RPC 2.0 implementation  
- **`src/crpyt/`** - Cryptographic key management and signing
- **`src/network_detector.dart`** - Automatic network version detection

### Contributing

1. Ensure all examples run successfully
2. Run `dart analyze` with no errors
3. Update tests for new functionality
4. Follow existing code patterns and naming conventions

## 📋 Changelog

### v0.2.0-condor
- ✅ **Full Condor (Casper 2.0) Support** - Complete transaction creation and network interaction
- ✅ **Automatic Network Detection** - Seamlessly detects and adapts to Legacy vs Condor networks  
- ✅ **Enhanced Transaction Types** - Support for transfers, contract deployments, and contract calls
- ✅ **Improved Type Safety** - Better JSON serialization and validation
- ✅ **Production Ready** - Robust error handling and comprehensive examples

### v0.1.3 (Legacy)
- Basic Casper 1.x support with `Deploy` transactions

## 🤝 Support

- **Issues**: [GitHub Issues](https://github.com/casper-ecosystem/casper-dart-sdk/issues)
- **Documentation**: [usage.md](./doc/usage.md)
- **Examples**: See `example/` directory for working code samples

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.