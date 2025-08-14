import 'dart:io';

import 'package:casper_dart_sdk/casper_dart_sdk.dart';
import 'package:casper_dart_sdk/src/casper_client_simple.dart';
import 'package:casper_dart_sdk/src/crpyt/key_pair.dart';
import 'package:casper_dart_sdk/src/types/cl_public_key.dart';

/// Complete working example for Condor network
/// This example demonstrates how to use the Casper Dart SDK with Condor compatibility

Future<void> main() async {
  // Configuration
  final nodeUrl = Uri.parse('http://localhost:7777/rpc');
  final chainName = 'casper-test'; // Change based on your network

  // Create client
  final client = CasperClientSimple(nodeUrl);

  try {
    // Test network connection
    print('🔍 Testing network connection...');
    final status = await client._client.getStatus();
    print('✅ Connected to network: ${status.chainName}');

    // Detect network version
    final version = await client._client.detectNetworkVersion();
    print('📡 Network version: $version');

    // Load keys (example - replace with your actual keys)
    final senderKeyPair = await _loadKeyPair();
    final recipientKeyPair = await _loadRecipientKeyPair();

    // Create transfer
    print('💸 Creating transfer...');
    final transfer = await client.createTransfer(
      from: senderKeyPair.publicKey,
      to: recipientKeyPair.publicKey,
      amount: BigInt.from(1000000000), // 1 CSPR
      paymentAmount: BigInt.from(100000000), // 0.1 CSPR for gas
      chainName: chainName,
    );

    // Sign transaction
    print('✍️ Signing transaction...');
    if (transfer is Deploy) {
      await transfer.sign(senderKeyPair);
    } else if (transfer is Transaction) {
      await transfer.sign(senderKeyPair);
    }

    // Send transaction
    print('🚀 Sending transaction...');
    final hash = await client.send(transfer);
    print('✅ Transaction sent! Hash: $hash');

    // Wait for confirmation
    print('⏳ Waiting for confirmation...');
    await _waitForConfirmation(client, hash);

    // Get transaction details
    final details = await client.getTransaction(hash);
    print('📋 Transaction details: $details');

  } catch (e) {
    print('❌ Error: $e');
  } finally {
    client.close();
  }
}

Future<KeyPair> _loadKeyPair() async {
  // Example: Load from environment or file
  // In production, use secure key management
  final privateKeyHex = Platform.environment['CASPER_PRIVATE_KEY'] ??
      'your-private-key-here';
  return KeyPair.fromPrivateKeyHex(privateKeyHex);
}

Future<KeyPair> _loadRecipientKeyPair() async {
  // Example: Generate a new key pair for recipient
  return KeyPair.fromRandom(KeyAlgorithm.ed25519);
}

Future<void> _waitForConfirmation(CasperClientSimple client, String hash) async {
  const maxAttempts = 30;
  const delay = Duration(seconds: 2);

  for (var i = 0; i < maxAttempts; i++) {
    try {
      final details = await client.getTransaction(hash);
      if (details != null) {
        print('✅ Transaction confirmed!');
        return;
      }
    } catch (e) {
      // Transaction not found yet
    }

    await Future.delayed(delay);
    print('⏳ Waiting... (${i + 1}/$maxAttempts)');
  }

  throw Exception('Transaction not confirmed within timeout');
}
