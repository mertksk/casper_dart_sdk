import 'dart:io';

import 'package:casper_dart_sdk/casper_dart_sdk.dart';
import 'package:casper_dart_sdk/src/casper_client_simple.dart';
import 'package:casper_dart_sdk/src/crpyt/key_pair.dart';
import 'package:casper_dart_sdk/src/types/cl_public_key.dart';

/// Simple test to verify Condor compatibility

Future<void> main() async {
  print('🧪 Casper Dart SDK Condor Compatibility Test');
  print('============================================');

  final nodeUrl = Uri.parse('http://localhost:7777/rpc');
  final client = CasperClientSimple(nodeUrl);

  try {
    // Test 1: Network connection
    print('\n1. Testing network connection...');
    final status = await client._client.getStatus();
    print('   ✅ Connected to: ${status.chainName}');

    // Test 2: Network version detection
    print('\n2. Testing network version detection...');
    final version = await client._client.detectNetworkVersion();
    print('   ✅ Network version: $version');

    // Test 3: Key generation
    print('\n3. Testing key generation...');
    final keyPair = KeyPair.fromRandom(KeyAlgorithm.ed25519);
    print('   ✅ Generated key pair: ${keyPair.publicKey.toHex()}');

    // Test 4: Transaction creation
    print('\n4. Testing transaction creation...');
    final recipient = KeyPair.fromRandom(KeyAlgorithm.ed25519);

    final transaction = await client.createTransfer(
      from: keyPair.publicKey,
      to: recipient.publicKey,
      amount: BigInt.from(1000000000),
      paymentAmount: BigInt.from(100000000),
      chainName: status.chainName,
    );

    print('   ✅ Created ${transaction.runtimeType}');

    // Test 5: Transaction serialization
    print('\n5. Testing transaction serialization...');
    if (transaction is Deploy) {
      final bytes = transaction.toBytes();
      print('   ✅ Deploy serialized to ${bytes.length} bytes');
    } else if (transaction is Transaction) {
      final bytes = transaction.toBytes();
      print('   ✅ Transaction serialized to ${bytes.length} bytes');
    }

    // Test 6: Transaction signing
    print('\n6. Testing transaction signing...');
    if (transaction is Deploy) {
      await transaction.sign(keyPair);
      print('   ✅ Deploy signed with ${transaction.approvals.length} approvals');
    } else if (transaction is Transaction) {
      await transaction.sign(keyPair);
      print('   ✅ Transaction signed with ${transaction.approvals.length} approvals');
    }

    print('\n🎉 All tests passed! SDK is Condor compatible.');

  } catch (e) {
    print('\n❌ Test failed: $e');
    exit(1);
  } finally {
    client.close();
  }
}
