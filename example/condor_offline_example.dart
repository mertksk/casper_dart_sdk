import 'dart:typed_data';
import 'package:casper_dart_sdk/casper_dart_sdk.dart';

/// Offline example demonstrating Condor transaction creation (no network required)
Future<void> main() async {
  print('🚀 Casper Dart SDK - Condor Transaction Demo (Offline)');
  print('=' * 50);

  try {
    // Generate key pairs for testing
    print('🔑 Generating key pairs...');
    final senderKeys = await Ed25519KeyPair.generate();
    final recipientKeys = await Ed25519KeyPair.generate();
    
    print('👤 Sender public key: ${senderKeys.publicKey}');
    print('👤 Recipient public key: ${recipientKeys.publicKey}');
    print('');

    // Test 1: Create a standard transfer transaction
    print('💸 Creating Condor transfer transaction...');
    final transferTx = TransactionCondor.standardTransfer(
      senderKeys.publicKey,
      recipientKeys.publicKey,
      BigInt.from(1000000000), // 1 CSPR
      BigInt.from(100000000),  // 0.1 CSPR for gas
      'casper-test',
      idTransfer: 12345,
      gasPrice: BigInt.from(1),
    );

    print('✅ Transfer transaction created!');
    print('   Hash: ${transferTx.hash}');
    print('   From: ${transferTx.header.initiator}');
    print('   Gas Price: ${transferTx.header.gasPrice}');
    print('   Chain: ${transferTx.header.chainName}');
    print('');

    // Test 2: Sign the transaction
    print('✍️ Signing transfer transaction...');
    await transferTx.sign(senderKeys);
    print('✅ Transaction signed! Approvals: ${transferTx.approvals.length}');
    print('');

    // Test 3: Create a contract deployment transaction
    print('📦 Creating contract deployment transaction...');
    final wasmBytes = Uint8List.fromList(List<int>.filled(100, 42)); // Dummy WASM
    final contractTx = TransactionCondor.contract(
      wasmBytes,
      senderKeys.publicKey,
      BigInt.from(500000000), // 0.5 CSPR for gas
      'casper-test',
      gasPrice: BigInt.from(2),
    );

    print('✅ Contract deployment transaction created!');
    print('   Hash: ${contractTx.hash}');
    print('   Deployer: ${contractTx.header.initiator}');
    print('   WASM size: ${wasmBytes.length} bytes');
    print('');

    // Test 4: Create a native transfer (lower level)
    print('🔄 Creating native transfer transaction...');
    final nativeTx = TransactionCondor.transfer(
      senderKeys.publicKey,
      recipientKeys.publicKey,
      BigInt.from(500000000), // 0.5 CSPR
      'casper-test',
      id: 67890,
      gasPrice: BigInt.from(3),
    );

    await nativeTx.sign(senderKeys);
    print('✅ Native transfer created and signed!');
    print('   Hash: ${nativeTx.hash}');
    print('   Transfer ID: 67890');
    print('');

    // Test 5: Demonstrate transaction serialization
    print('📊 Testing transaction serialization...');
    final serialized = transferTx.toBytes();
    print('✅ Transaction serialized to ${serialized.length} bytes');
    
    final jsonData = transferTx.toJson();
    print('✅ Transaction JSON keys: ${jsonData.keys.join(', ')}');
    print('');

    print('🎉 All Condor transaction tests passed!');
    print('');
    print('📝 Summary:');
    print('   • TransactionCondor.standardTransfer() ✅');
    print('   • TransactionCondor.contract() ✅');
    print('   • TransactionCondor.transfer() ✅');
    print('   • Transaction signing ✅');
    print('   • Transaction serialization ✅');
    print('   • JSON serialization ✅');
    print('');
    print('🚀 Your Casper Dart SDK is ready for Condor networks!');
    
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
  }
}