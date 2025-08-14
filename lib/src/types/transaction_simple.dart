import 'dart:typed_data';

import 'package:casper_dart_sdk/src/types/cl_public_key.dart';
import 'package:casper_dart_sdk/src/types/transaction.dart';

/// Simple transaction creation utilities
class TransactionSimple {
  /// Create a simple transfer transaction
  static Transaction createTransfer({
    required ClPublicKey from,
    required ClPublicKey to,
    required BigInt amount,
    required BigInt paymentAmount,
    required String chainName,
    int? idTransfer,
    BigInt gasPrice = BigInt.one,
    Duration ttl = const Duration(minutes: 30),
  }) {
    return Transaction.standardTransfer(
      from: from,
      to: to,
      amount: amount,
      paymentAmount: paymentAmount,
      chainName: chainName,
      idTransfer: idTransfer,
      gasPrice: gasPrice,
      ttl: ttl,
    );
  }

  /// Create a simple contract deployment transaction
  static Transaction createContractDeployment({
    required Uint8List wasmBytes,
    required ClPublicKey from,
    required BigInt paymentAmount,
    required String chainName,
    BigInt gasPrice = BigInt.one,
    Duration ttl = const Duration(minutes: 30),
  }) {
    return Transaction.contract(
      wasmBytes: wasmBytes,
      from: from,
      paymentAmount: paymentAmount,
      chainName: chainName,
      gasPrice: gasPrice,
      ttl: ttl,
    );
  }
}
