// Simplified Transaction class without generated code dependencies
import 'dart:convert';
import 'dart:typed_data';
import 'cl_public_key.dart';
import 'cl_value.dart';

/// Simplified Transaction class for Condor compatibility
class Transaction {
  final String hash;
  final TransactionHeader header;
  final TransactionPayload payload;
  final List<TransactionApproval> approvals;

  Transaction({
    required this.hash,
    required this.header,
    required this.payload,
    required this.approvals,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      hash: json['hash'] as String,
      header: TransactionHeader.fromJson(json['header'] as Map<String, dynamic>),
      payload: TransactionPayload.fromJson(json['payload'] as Map<String, dynamic>),
      approvals: (json['approvals'] as List)
          .map((e) => TransactionApproval.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hash': hash,
      'header': header.toJson(),
      'payload': payload.toJson(),
      'approvals': approvals.map((e) => e.toJson()).toList(),
    };
  }

  /// Create a standard transfer transaction
  factory Transaction.standardTransfer(
    ClPublicKey from,
    ClPublicKey to,
    BigInt amount,
    BigInt paymentAmount,
    String chainName, {
    BigInt? gasPrice,
    int? ttl,
    String? id,
  }) {
    // Simplified transfer creation
    return Transaction(
      hash: 'mock-transaction-hash-${DateTime.now().millisecondsSinceEpoch}',
      header: TransactionHeader(
        account: from,
        chainName: chainName,
        timestamp: DateTime.now().toUtc(),
        ttl: ttl ?? 1800000, // 30 minutes default
        gasPrice: gasPrice ?? BigInt.one,
        bodyHash: 'mock-body-hash',
      ),
      payload: TransactionPayload(
        payment: paymentAmount,
        session: amount,
      ),
      approvals: [],
    );
  }
}

/// Simplified Transaction Header
class TransactionHeader {
  final ClPublicKey account;
  final String chainName;
  final DateTime timestamp;
  final int ttl;
  final BigInt gasPrice;
  final String bodyHash;

  TransactionHeader({
    required this.account,
    required this.chainName,
    required this.timestamp,
    required this.ttl,
    required this.gasPrice,
    required this.bodyHash,
  });

  factory TransactionHeader.fromJson(Map<String, dynamic> json) {
    return TransactionHeader(
      account: ClPublicKey.fromHex(json['account'] as String),
      chainName: json['chain_name'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      ttl: json['ttl'] as int,
      gasPrice: BigInt.parse(json['gas_price'] as String),
      bodyHash: json['body_hash'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account.toHex(),
      'chain_name': chainName,
      'timestamp': timestamp.toIso8601String(),
      'ttl': ttl,
      'gas_price': gasPrice.toString(),
      'body_hash': bodyHash,
    };
  }
}

/// Simplified Transaction Payload
class TransactionPayload {
  final BigInt payment;
  final BigInt session;

  TransactionPayload({
    required this.payment,
    required this.session,
  });

  factory TransactionPayload.fromJson(Map<String, dynamic> json) {
    return TransactionPayload(
      payment: BigInt.parse(json['payment'] as String),
      session: BigInt.parse(json['session'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment': payment.toString(),
      'session': session.toString(),
    };
  }
}

/// Simplified Transaction Approval
class TransactionApproval {
  final String signer;
  final String signature;

  TransactionApproval({
    required this.signer,
    required this.signature,
  });

  factory TransactionApproval.fromJson(Map<String, dynamic> json) {
    return TransactionApproval(
      signer: json['signer'] as String,
      signature: json['signature'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'signer': signer,
      'signature': signature,
    };
  }
}
