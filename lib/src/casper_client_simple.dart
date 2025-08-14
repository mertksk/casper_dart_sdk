import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:casper_dart_sdk/src/casper_client.dart';
import 'package:casper_dart_sdk/src/http/casper_node_client.dart';
import 'package:casper_dart_sdk/src/types/cl_public_key.dart';
import 'package:casper_dart_sdk/src/types/deploy.dart';
import 'package:casper_dart_sdk/src/types/transaction.dart';

/// Simple wrapper for CasperClient with unified API
class CasperClientSimple {
  final CasperClient _client;

  CasperClientSimple(Uri nodeUrl) : _client = CasperClient(nodeUrl);

  /// Send a transaction (Deploy or Transaction) to the network
  Future<String> send(dynamic transaction) async {
    if (transaction is Deploy) {
      return await _client.putDeploy(transaction);
    } else if (transaction is Transaction) {
      return await _client.putTransaction(transaction);
    } else {
      throw ArgumentError('Invalid transaction type');
    }
  }

  /// Create a simple transfer
  Future<dynamic> createTransfer({
    required ClPublicKey from,
    required ClPublicKey to,
    required BigInt amount,
    required BigInt paymentAmount,
    required String chainName,
    int? idTransfer,
    BigInt gasPrice = BigInt.one,
    Duration ttl = const Duration(minutes: 30),
  }) async {
    final networkVersion = await _client.detectNetworkVersion();

    if (networkVersion == NetworkVersion.condor) {
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
    } else {
      return Deploy.standardTransfer(
        from,
        to,
        amount,
        paymentAmount,
        chainName,
        idTransfer,
        gasPrice.toInt(),
        ttl,
      );
    }
  }

  /// Get transaction info
  Future<dynamic> getTransaction(String hash) async {
    final networkVersion = await _client.detectNetworkVersion();

    if (networkVersion == NetworkVersion.condor) {
      return await _client.getTransaction(hash);
    } else {
      return await _client.getDeploy(hash);
    }
  }

  /// Close the client
  void close() {
    _client.close();
  }
}
