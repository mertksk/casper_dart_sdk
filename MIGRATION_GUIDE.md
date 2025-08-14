# Casper Dart SDK - Condor Migration Guide

This guide helps you migrate from the legacy Deploy-based SDK to the new Condor Transaction-based SDK.

## Overview

The Casper network has undergone a major upgrade called **Condor** (Casper 2.0) that introduces:
- **Transactions** replacing **Deploys** as the fundamental unit
- **Block Lanes** for parallel processing
- **Zug Consensus** mechanism
- New RPC endpoints and data structures

## Breaking Changes

### 1. Deploy → Transaction
```dart
// Legacy (Pre-Condor)
Deploy deploy = Deploy(...);
String deployHash = await client.putDeploy(deploy);

// Condor (Casper 2.0+)
Transaction transaction = Transaction(...);
String transactionHash = await client.putTransaction(transaction);
```

### 2. Network Detection
The SDK now automatically detects network version:

```dart
// Automatic detection
CasperClient client = CasperClient(Uri.parse('http://localhost:7777'));
NetworkVersion version = await client.detectNetworkVersion();

// Manual override if needed
if (version == NetworkVersion.condor) {
  // Use Transaction methods
} else {
  // Use Deploy methods
}
```

### 3. Unified API
The new `CasperClient` provides unified methods that work with both formats:

```dart
// Unified send method - automatically detects network
dynamic result = await client.send(transactionOrDeploy);

// Unified get method - automatically detects network
dynamic info = await client.get(hash);
```

## Migration Steps

### Step 1: Update Dependencies
Ensure you're using the latest version of the Casper Dart SDK.

### Step 2: Replace Deploy Creation
```dart
// Before
Deploy deploy = Deploy.standardTransfer(
  fromPublicKey,
  toPublicKey,
  amount,
  paymentAmount,
  chainName,
);

// After
// Option 1: Let SDK handle detection
dynamic tx = await client.createTransfer(
  fromPublicKey,
  toPublicKey,
  amount,
  paymentAmount,
  chainName,
);

// Option 2: Manual creation
Transaction transaction = Transaction.standardTransfer(
  fromPublicKey,
  toPublicKey,
  amount,
  paymentAmount,
  chainName,
);
```

### Step 3: Update RPC Calls
```dart
// Before
GetDeployResult result = await client.getDeploy(deployHash);

// After
// Option 1: Unified method
dynamic info = await client.get(transactionHash);

// Option 2: Explicit method
GetTransactionResult result = await client.getTransaction(transactionHash);
```

### Step 4: Handle New Features (Optional)
```dart
// Block lanes (Condor only)
GetBlockWithLanesResult blockInfo = await client.getBlockWithLanes(height: 12345);

// Validator rewards (Condor only)
GetValidatorRewardsResult rewards = await client.getValidatorRewards(
  validatorPublicKey: '01...',
  limit: 100,
);
```

## Code Examples

### Basic Transfer (Network-Agnostic)
```dart
import 'package:casper_dart_sdk/casper_dart_sdk.dart';

void main() async {
  final client = CasperClient(Uri.parse('http://localhost:7777'));
  
  // Detect network version
  final version = await client.detectNetworkVersion();
  print('Network version: $version');
  
  // Create transfer (automatically uses correct format)
  final transfer = await client.createTransfer(
    fromPublicKey,
    toPublicKey,
    BigInt.from(1000000000), // 1 CSPR
    BigInt.from(100000000),  // 0.1 CSPR fee
    'casper-net-1',
  );
  
  // Send transaction/deploy
  final result = await client.send(transfer);
  print('Sent: ${result.transactionHash ?? result.deployHash}');
}
```

### Advanced Usage with Network Detection
```dart
import 'package:casper_dart_sdk/casper_dart_sdk.dart';

class NetworkAwareService {
  final CasperClient client;
  
  NetworkAwareService(this.client);
  
  Future<void> sendComplexTransaction() async {
    final version = await client.detectNetworkVersion();
    
    if (version == NetworkVersion.condor) {
      // Use new Transaction format
      final transaction = Transaction(
        initiatorAddr: initiatorPublicKey,
        pricingMode: PricingMode.fixed(BigInt.from(100000000)),
        .. // other Condor-specific fields
      );
      
      final result = await client.putTransaction(transaction);
      print('Transaction hash: ${result.transactionHash}');
      
    } else {
      // Use legacy Deploy format
      final deploy = Deploy(
        approvals: [],
        hash: '',
        header: DeployHeader(...),
        payment: ExecutableDeployItem.moduleBytes(...),
        session: ExecutableDeployItem.storedContractByHash(...),
      );
      
      final result = await client.putDeploy(deploy);
      print('Deploy hash: ${result.deployHash}');
    }
  }
}
```

### Error Handling
```dart
try {
  final result = await client.send(transaction);
} catch (e) {
  if (e is NetworkIncompatibleException) {
    print('Transaction format incompatible with network');
  } else {
    print('Error: $e');
  }
}
```

## New Features in Condor

### 1. Block Lanes
```dart
// Get block with lane information
final blockWithLanes = await client.getBlockWithLanes(height: 12345);
print('Block has ${blockWithLanes.lanes.length} lanes');
for (var lane in blockWithLanes.lanes) {
  print('Lane has ${lane.length} transactions');
}
```

### 2. Validator Rewards
```dart
// Get validator rewards for specific era
final rewards = await client.getValidatorRewards(
  eraId: '12345',
  validatorPublicKey: '01...',
);
print('Total rewards: ${rewards.rewards.length}');
```

### 3. Enhanced Transaction Info
```dart
// Get transaction with execution results
final txInfo = await client.getTransactionWithBlock(
  transactionHash,
  includeBlock: true,
);
print('Transaction executed in block: ${txInfo.block?.hash}');
```

## Backward Compatibility

The SDK maintains full backward compatibility:
- All legacy Deploy methods continue to work
- Existing code will function on legacy networks
- New unified methods handle both formats automatically

## Testing

### Test Network Detection
```dart
void testNetworkDetection() async {
  final client = CasperClient(Uri.parse('http://localhost:7777'));
  final version = await client.detectNetworkVersion();
  
  expect(version, anyOf([NetworkVersion.legacy, NetworkVersion.condor]));
}
```

### Test Unified Methods
```dart
void testUnifiedMethods() async {
  final client = CasperClient(Uri.parse('http://localhost:7777'));
  
  // This should work regardless of network version
  final transfer = await client.createTransfer(...);
  final result = await client.send(transfer);
  
  expect(result, isNotNull);
}
```

## Troubleshooting

### Common Issues

1. **"Invalid transaction type" error**
   - Ensure you're using the correct format for your network version
   - Use `client.detectNetworkVersion()` to verify

2. **RPC method not found**
   - Check if your node supports Condor
   - Verify the node URL is correct

3. **Serialization errors**
   - Ensure all required fields are provided
   - Check transaction format matches network version

### Debug Network Detection
```dart
void debugNetwork() async {
  final client = CasperClient(Uri.parse('http://localhost:7777'));
  final status = await client.getStatus();
  
  print('API Version: ${status.apiVersion}');
  print('Protocol Version: ${status.protocolVersion}');
  print('Build Version: ${status.buildVersion}');
  
  final version = await client.detectNetworkVersion();
  print('Detected: $version');
}
```

## Support

For issues or questions:
- Check the [Casper Documentation](https://docs.casper.network/condor/)
- Review the [SDK Examples](https://github.com/datahan35/bangoweb/tree/main/casper_dart_sdk/example)
- Open an issue on GitHub
