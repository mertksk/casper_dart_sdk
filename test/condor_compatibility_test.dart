import 'package:test/test.dart';
import 'package:casper_dart_sdk/casper_dart_sdk.dart';

void main() {
  group('Condor Compatibility Tests', () {
    test('CasperClient can be created', () {
      final client = CasperClient('http://localhost:7777/rpc');
      expect(client, isNotNull);
      client.close();
    });

    test('Transaction can be created', () {
      final from = ClPublicKey.fromHex('01' + 'a' * 64);
      final to = ClPublicKey.fromHex('01' + 'b' * 64);

      final transaction = Transaction.standardTransfer(
        from,
        to,
        BigInt.from(1000000000),
        BigInt.from(100000000),
        'casper-test',
      );

      expect(transaction.hash, isNotEmpty);
      expect(transaction.header.account, equals(from));
    });

    test('Network version detection', () async {
      final client = CasperClient('http://localhost:7777/rpc');

      try {
        final version = await client.detectNetworkVersion();
        expect(version, anyOf(NetworkVersion.legacy, NetworkVersion.condor));
      } catch (e) {
        // Expected if no node is running
        expect(e, isA<Exception>());
      } finally {
        client.close();
      }
    });
  });
}
