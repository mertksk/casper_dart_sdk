import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:casper_dart_sdk/src/types/transaction_condor.dart';
import 'package:casper_dart_sdk/src/types/cl_public_key.dart';
import 'package:casper_dart_sdk/src/types/global_state_key.dart';
import 'package:casper_dart_sdk/src/types/cl_value.dart';
import 'package:casper_dart_sdk/src/crpyt/key_pair.dart';

void main() {
  group('Condor Transaction Tests', () {
    test('creates transfer transaction', () async {
      final keyPair = await Ed25519KeyPair.generate();
      final publicKey = keyPair.publicKey;
      
      final transaction = TransactionCondor.transfer(
        publicKey,
        publicKey,
        BigInt.from(2500000000),
        "casper-test",
        id: 12345,
        gasPrice: BigInt.from(1),
      );
      
      expect(transaction.header.initiator, equals(publicKey));
      expect(transaction.header.chainName, equals("casper-test"));
      expect(transaction.payload, isA<TransferPayload>());
      
      final payload = transaction.payload as TransferPayload;
      expect(payload.amount, equals(BigInt.from(2500000000)));
      expect(payload.id, equals(12345));
    });
    
    test('creates contract call transaction', () async {
      final keyPair = await Ed25519KeyPair.generate();
      final publicKey = keyPair.publicKey;
      
      final transaction = TransactionCondor.contractCall(
        "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
        "transfer",
        [
          NamedArg("amount", ClValue.u512(BigInt.from(1000))),
          NamedArg("recipient", ClValue.publicKey(publicKey)),
        ],
        publicKey,
        "casper-test",
      );
      
      expect(transaction.payload, isA<ContractCallPayload>());
      final payload = transaction.payload as ContractCallPayload;
      expect(payload.contractHash, equals("0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"));
      expect(payload.entryPoint, equals("transfer"));
      expect(payload.args.length, equals(2));
    });
    
    test('creates WASM deployment transaction', () async {
      final keyPair = await Ed25519KeyPair.generate();
      final publicKey = keyPair.publicKey;
      final wasmBytes = Uint8List.fromList([0x00, 0x61, 0x73, 0x6d]); // Minimal WASM header
      
      final transaction = TransactionCondor.deployWasm(
        wasmBytes,
        publicKey,
        "casper-test",
        args: [
          NamedArg("initial_value", ClValue.u32(0)),
        ],
      );
      
      expect(transaction.payload, isA<DeployWasmPayload>());
      final payload = transaction.payload as DeployWasmPayload;
      expect(payload.wasmBytes, equals(wasmBytes));
      expect(payload.args.length, equals(1));
    });
    
    test('signs and verifies transaction', () async {
      final keyPair = await Ed25519KeyPair.generate();
      final publicKey = keyPair.publicKey;
      
      final transaction = TransactionCondor.transfer(
        publicKey,
        publicKey,
        BigInt.from(1000000000),
        "casper-test",
      );
      
      // Sign the transaction
      await transaction.sign(keyPair);
      
      expect(transaction.approvals.length, equals(1));
      expect(transaction.approvals[0].signer, equals(publicKey));
      
      // Verify signature
      final invalidSigner = await transaction.verifySignatures();
      expect(invalidSigner, isNull); // null means all signatures are valid
    });
    
    test('serializes transaction to bytes', () async {
      final keyPair = await Ed25519KeyPair.generate();
      final publicKey = keyPair.publicKey;
      
      final transaction = TransactionCondor.transfer(
        publicKey,
        publicKey,
        BigInt.from(1000000000),
        "casper-test",
        gasPrice: BigInt.from(1),
      );
      
      final bytes = transaction.toBytes();
      expect(bytes, isA<Uint8List>());
      expect(bytes.length, greaterThan(0));
    });
    
    test('transaction hash is deterministic with same inputs', () async {
      final keyPair = await Ed25519KeyPair.generate();
      final publicKey = keyPair.publicKey;
      
      // Create transactions with same timestamp to ensure deterministic hashing
      final timestamp = DateTime.now();
      final header1 = TransactionHeader.withoutBodyHash(
        publicKey,
        timestamp, // Same timestamp
        Duration(minutes: 30),
        BigInt.from(1),
        "casper-test",
      );
      
      final header2 = TransactionHeader.withoutBodyHash(
        publicKey,
        timestamp, // Same timestamp
        Duration(minutes: 30),
        BigInt.from(1),
        "casper-test",
      );
      
      final payload1 = TransferPayload(
        BigInt.from(1000000000),
        AccountHashKey.fromPublicKey(publicKey),
        null,
      );
      
      final payload2 = TransferPayload(
        BigInt.from(1000000000),
        AccountHashKey.fromPublicKey(publicKey),
        null,
      );
      
      final tx1 = TransactionCondor.create(header1, payload1);
      final tx2 = TransactionCondor.create(header2, payload2);
      
      // Same content should produce same hash
      expect(tx1.hash, equals(tx2.hash));
      
      // Different content should produce different hash
      final payload3 = TransferPayload(
        BigInt.from(2000000000), // Different amount
        AccountHashKey.fromPublicKey(publicKey),
        null,
      );
      final tx3 = TransactionCondor.create(header1, payload3);
      
      expect(tx3.hash, isNot(equals(tx1.hash)));
    });
  });
}