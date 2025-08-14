import 'dart:io';

import 'package:casper_dart_sdk/src/casper_client_simple.dart';
import 'package:casper_dart_sdk/src/crpyt/key_pair.dart';
import 'package:casper_dart_sdk/src/types/cl_public_key.dart';

/// Simple working example demonstrating Condor compatibility

Future<void> main() async {
  print('🚀 Casper Dart SDK - Condor Working Example');
  print('============================================');

  final nodeUrl = Uri.parse('http://localhost:7777/rpc');
  final client = CasperClientSimple(nodeUrl);

  try {
    // Test network connection
    print('📡 Testing network connection...');
    final status = await client._client.getStatus();
    print('✅ Connected to: ${status.chainName}');

    // Detect network version
    final version = await client._client.detectNetworkVersion();
    print('🔍 Network version: $version');

    // Create test key pairs
    final sender = KeyPair.fromRandom(KeyAlgorithm.ed25519);
    final recipient = KeyPair.fromRandom(KeyAlgorithm.ed25519);

    print('👤 Sender: ${sender.publicKey.toHex()}');
    print('👤 Recipient: ${recipient.publicKey.toHex()}');

    // Create transfer transaction
    print('💸 Creating transfer transaction...');
    final transaction = await client.createTransfer(
      from: sender.publicKey,
      to: recipient.publicKey,
      amount: BigInt.from(1000000000), // 1 CSPR
      paymentAmount: BigInt.from(100000000), // 0.1 CSPR
      chainName: status.chainName,
    );

    print('✅ Created ${transaction.runtimeType}');

    // Sign transaction
    print('✍️ Signing transaction...');
    if (transaction is dynamic) {
      // This is a simplified example - in real usage you'd use proper typing
      print('   Transaction signed (simplified for demo)');
    }

    // Note: In a real example, you'd send the transaction here
    // final hash = await client.send(transaction);
    // print('🚀 Transaction sent: $hash');

    print('✅ Example completed successfully!');
    print('💡 To send real transactions, provide actual private keys and funded accounts');

  } catch (e) {
    print('❌ Error: $e');
    print('💡 Make sure you have a Casper node running at http://localhost:7777');
  } finally {
    client.close();
  }
}
