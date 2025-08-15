import 'package:casper_dart_sdk/casper_dart_sdk.dart';

Future<void> main() async {
  // Create client
  final client = CasperClient(Uri.parse('http://localhost:7777/rpc'));
  
  try {
    // Test basic connectivity
    print('🔍 Testing connection...');
    final status = await client.getStatus();
    print('✅ Connected! API Version: ${status.apiVersion}');
    
    // Test network detection
    final version = await client.detectNetworkVersion();
    print('📡 Network version: $version');
    
    // Create key pairs for testing
    final senderKeys = await Ed25519KeyPair.generate();
    final recipientKeys = await Ed25519KeyPair.generate();
    
    print('👤 Sender public key: ${senderKeys.publicKey}');
    print('👤 Recipient public key: ${recipientKeys.publicKey}');
    
    // Note: To actually send transactions, you would need:
    // 1. A funded account
    // 2. The correct chain name
    // 3. A running Casper node
    
    print('✅ SDK basic functionality working!');
    
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    client.clearNetworkCache();
  }
}