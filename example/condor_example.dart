import 'dart:io';
import 'package:casper_dart_sdk/casper_dart_sdk.dart';

/// Comprehensive example demonstrating Condor features
/// This example shows how to use the SDK with both legacy and Condor networks
void main() async {
  print('🚀 Casper Dart SDK - Condor Example');
  print('====================================');

  // Initialize client
  final nodeUrl = Platform.environment['CASPER_NODE_URL'] ?? 'http://localhost:7777';
  final client = CasperClient(Uri.parse(nodeUrl));

  try {
    // Step 1: Detect network version
    print('\n📡 Detecting network version...');
    final version = await client.detectNetworkVersion();
    print('✅ Network version: $version');

    // Step 2: Get network status
    print('\n📊 Getting network status...');
    final status = await client.getStatus();
    print('🔗 Chain name: ${status.chainName}');
    print('🔢 Protocol version: ${status.protocolVersion}');
    print('📦 Latest block height: ${status.lastAddedBlockInfo?.height}');

    // Step 3: Create sample keys for demonstration
    final keyPair = KeyPair.ed25519();
    final fromPublicKey = keyPair.publicKey;
    final toPublicKey = KeyPair.ed25519().publicKey;

    // Step 4: Create transfer based on network version
    print('\n💸 Creating transfer...');
    final transfer = await client.createTransfer(
      fromPublicKey,
      toPublicKey,
      BigInt.from(1000000000), // 1 CSPR
      BigInt.from(100000000),  // 0.1 CSPR fee
      status.chainName,
    );

    print('✅ Transfer created for $version network');

    // Step 5: Demonstrate Condor-specific features
    if (version == NetworkVersion.condor) {
      print('\n🆕 Condor-specific features:');

      // Get validator rewards
      print('\n🏆 Getting validator rewards...');
      try {
        final rewards = await client.getValidatorRewards(
          limit: 5,
        );
        print('📈 Found ${rewards.rewards.length} validator rewards');
        if (rewards.rewards.isNotEmpty) {
          final reward = rewards.rewards.first;
          print('💰 Sample reward: ${reward.amount} motes to ${reward.validatorPublicKey}');
        }
      } catch (e) {
        print('⚠️  Could not get validator rewards: $e');
      }

      // Get block with lanes
      print('\n🛤️  Getting block with lanes...');
      try {
        final blockWithLanes = await client.getBlockWithLanes(
          height: status.lastAddedBlockInfo?.height ?? 1,
        );
        print('🚦 Block has ${blockWithLanes.lanes.length} lanes');
        for (int i = 0; i < blockWithLanes.lanes.length; i++) {
          print('  Lane $i: ${blockWithLanes.lanes[i].length} transactions');
        }
      } catch (e) {
        print('⚠️  Could not get block lanes: $e');
      }

    } else {
      print('\n📋 Legacy network detected - using Deploy format');
    }

    // Step 6: Demonstrate unified API
    print('\n🔄 Demonstrating unified API...');

    // Get account info (works on both networks)
    final accountInfo = await client.getAccountInfo(fromPublicKey);
    print('👤 Account balance: ${accountInfo.account?.mainPurse}');

    // Get auction info (works on both networks)
    final auctionInfo = await client.getAuctionInfo();
    print('🏛️  Active validators: ${auctionInfo.auctionState?.bids?.length}');

    // Step 7: Error handling example
    print('\n🛡️  Testing error handling...');
    try {
      await client.getTransaction('invalid-hash');
    } catch (e) {
      print('✅ Properly handled error: ${e.runtimeType}');
    }

    print('\n✨ Example completed successfully!');

  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  } finally {
    client.clearNetworkCache();
  }
}

/// Example of network-specific implementation
class NetworkSpecificExample {
  final CasperClient client;

  NetworkSpecificExample(this.client);

  Future<void> demonstrateNetworkSpecificFeatures() async {
    final version = await client.detectNetworkVersion();

    switch (version) {
      case NetworkVersion.condor:
        await _demonstrateCondorFeatures();
        break;
      case NetworkVersion.legacy:
        await _demonstrateLegacyFeatures();
        break;
    }
  }

  Future<void> _demonstrateCondorFeatures() async {
    print('\n🔥 Condor Network Features:');

    // Create advanced transaction
    final transaction = Transaction(
      initiatorAddr: KeyPair.ed25519().publicKey,
      networkName: 'casper-net-1',
      timestamp: DateTime.now().toUtc(),
      ttl: Duration(hours: 1),
      pricingMode: PricingMode.fixed(BigInt.from(100000000)),
      paymentAmount: BigInt.from(100000000),
      session: ExecutableDeployItem.moduleBytes(
        Uint8List.fromList([0, 1, 2, 3]),
        [],
      ),
    );

    // Sign transaction
    final keyPair = KeyPair.ed25519();
    final signedTransaction = transaction.sign(keyPair);

    print('✅ Created Condor transaction: ${signedTransaction.hash}');

    // Get validator rewards
    final rewards = await client.getValidatorRewards(limit: 10);
    print('📊 Validator rewards: ${rewards.rewards.length} entries');
  }

  Future<void> _demonstrateLegacyFeatures() async {
    print('\n📜 Legacy Network Features:');

    // Create legacy deploy
    final deploy = Deploy(
      approvals: [],
      hash: '',
      header: DeployHeader(
        account: KeyPair.ed25519().publicKey,
        bodyHash: '',
        chainName: 'casper-net-1',
        gasPrice: 1,
        timestamp: DateTime.now().toUtc(),
        ttl: Duration(hours: 1),
        dependencies: [],
      ),
      payment: ExecutableDeployItem.moduleBytes(
        Uint8List.fromList([0, 1, 2, 3]),
        [],
      ),
      session: ExecutableDeployItem.moduleBytes(
        Uint8List.fromList([4, 5, 6, 7]),
        [],
      ),
    );

    // Sign deploy
    final keyPair = KeyPair.ed25519();
    final signedDeploy = deploy.sign(keyPair);

    print('✅ Created legacy deploy: ${signedDeploy.hash}');
  }
}

/// Utility function to create test accounts
Future<void> createTestAccounts() async {
  final client = CasperClient(Uri.parse('http://localhost:7777'));

  print('\n🧪 Creating test accounts...');

  // Create Ed25519 key pair
  final ed25519KeyPair = KeyPair.ed25519();
  print('🔑 Ed25519 Public Key: ${ed25519KeyPair.publicKey.toHex()}');

  // Create Secp256k1 key pair
  final secp256k1KeyPair = KeyPair.secp256k1();
  print('🔑 Secp256k1 Public Key: ${secp256k1KeyPair.publicKey.toHex()}');

  // Get account info for both
  try {
    final ed25519Account = await client.getAccountInfo(ed25519KeyPair.publicKey);
    print('💰 Ed25519 Account: ${ed25519Account.account?.mainPurse}');
  } catch (e) {
    print('⚠️  Ed25519 Account not found: $e');
  }

  try {
    final secp256k1Account = await client.getAccountInfo(secp256k1KeyPair.publicKey);
    print('💰 Secp256k1 Account: ${secp256k1Account.account?.mainPurse}');
  } catch (e) {
    print('⚠️  Secp256k1 Account not found: $e');
  }
}
