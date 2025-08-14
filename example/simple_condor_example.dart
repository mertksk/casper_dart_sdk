import 'package:casper_dart_sdk/casper_dart_sdk.dart';

void main() async {
  print('🚀 Casper Dart SDK - Condor Example');
  print('====================================');

  final client = CasperClient('http://localhost:7777/rpc');

  try {
    print('📡 Connecting to Casper node...');
    final version = await client.detectNetworkVersion();
    print('✅ Connected to ${version.name} network');

    // Example usage
    print('💡 Example usage:');
    print('   final transaction = Transaction.standardTransfer(from, to, amount, payment, chainName);');
    print('   final result = await client.sendTransaction(transaction);');

  } catch (e) {
    print('❌ Error: $e');
    print('💡 Make sure you have a Casper node running at http://localhost:7777');
  } finally {
    client.close();
  }
}
