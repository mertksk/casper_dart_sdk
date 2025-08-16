import 'dart:typed_data';
import 'package:casper_dart_sdk/casper_dart_sdk.dart';

/// Example demonstrating Condor transaction creation and submission
Future<void> main() async {
  // Configuration
  final nodeUrl = Uri.parse('http://localhost:7777/rpc');
  final chainName = 'casper-test'; // Change based on your network

  // Create client
  final client = CasperClient(nodeUrl);

  try {
    // Test network connection
    print('🔍 Testing network connection...');
    final status = await client.getStatus();
    print('✅ Connected! API Version: ${status.apiVersion}');

    // Detect network version
    final version = await client.detectNetworkVersion();
    print('📡 Network version: $version');

    if (version == NetworkVersion.condor) {
      print('🚀 Condor network detected - testing Condor transactions...');
      
      // Generate key pairs for testing
      final senderKeys = await Ed25519KeyPair.generate();
      final recipientKeys = await Ed25519KeyPair.generate();
      
      print('👤 Sender public key: ${senderKeys.publicKey}');
      print('👤 Recipient public key: ${recipientKeys.publicKey}');

      // Create a Condor transfer transaction
      print('💸 Creating Condor transfer transaction...');
      final transaction = TransactionCondor.transfer(
        senderKeys.publicKey,
        recipientKeys.publicKey,
        BigInt.from(1000000000), // 1 CSPR
        chainName,
        id: 12345,
        gasPrice: BigInt.from(1),
      );

      print('📋 Transaction created with hash: ${transaction.hash}');

      // Sign the transaction
      print('✍️ Signing transaction...');
      await transaction.sign(senderKeys);
      print('✅ Transaction signed');

      // Note: To actually submit, you would need a funded account and running Condor node
      try {
        print('🚀 Attempting to submit transaction...');
        final result = await client.putTransaction(transaction);
        print('✅ Transaction submitted! Hash: ${result.transactionHash}');
        
        // Wait a moment, then query the transaction
        print('⏳ Waiting before querying transaction...');
        await Future.delayed(Duration(seconds: 2));
        
        final txInfo = await client.getTransaction(result.transactionHash);
        print('📋 Transaction info retrieved: ${txInfo.transaction?.hash}');
        
      } catch (e) {
        print('⚠️ Transaction submission failed (expected if no funded account): $e');
        print('✅ But transaction creation and signing worked correctly!');
      }
      
    } else {
      print('📡 Legacy network detected - Condor features not available');
      
      // Test creating TransactionCondor objects anyway (for API testing)
      print('🧪 Testing TransactionCondor creation on legacy network...');
      
      final senderKeys = await Ed25519KeyPair.generate();
      final recipientKeys = await Ed25519KeyPair.generate();
      
      final transaction = TransactionCondor.standardTransfer(
        senderKeys.publicKey,
        recipientKeys.publicKey,
        BigInt.from(1000000000), // 1 CSPR
        BigInt.from(100000000),  // 0.1 CSPR for gas
        chainName,
        idTransfer: 12345,
        gasPrice: BigInt.from(1),
      );
      
      print('✅ TransactionCondor.standardTransfer() works: ${transaction.hash}');
      
      // Test contract deployment
      final wasmBytes = Uint8List.fromList(List<int>.filled(100, 0)); // Dummy WASM
      final contractTx = TransactionCondor.contract(
        wasmBytes,
        senderKeys.publicKey,
        BigInt.from(100000000),
        chainName,
      );
      
      print('✅ TransactionCondor.contract() works: ${contractTx.hash}');
    }

  } catch (e) {
    print('❌ Error: $e');
  } finally {
    client.clearNetworkCache();
  }
}