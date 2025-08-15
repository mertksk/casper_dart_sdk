import 'package:json_annotation/json_annotation.dart';
import 'package:casper_dart_sdk/src/types/transaction_condor.dart';
import 'package:casper_dart_sdk/src/types/transaction_v1.dart';
import 'package:casper_dart_sdk/src/jsonrpc/rpc_params.dart';
import 'package:casper_dart_sdk/src/jsonrpc/rpc_result.dart';

part 'generated/get_transaction.g.dart';

/// Parameters for getting transaction information
@JsonSerializable(fieldRename: FieldRename.snake)
class GetTransactionParams extends RpcParams {
  final String transactionHash;

  GetTransactionParams(this.transactionHash);

  factory GetTransactionParams.fromJson(Map<String, dynamic> json) => _$GetTransactionParamsFromJson(json);
  Map<String, dynamic> toJson() => _$GetTransactionParamsToJson(this);
}

/// Response for getting transaction information
@JsonSerializable(fieldRename: FieldRename.snake)
class GetTransactionResult extends RpcResult {
  final TransactionCondor? transaction;
  final List<ExecutionResult> executionResults;

  factory GetTransactionResult.fromJson(Map<String, dynamic> json) => _$GetTransactionResultFromJson(json);
  Map<String, dynamic> toJson() => _$GetTransactionResultToJson(this);

  GetTransactionResult(String apiVersion, this.transaction, this.executionResults) : super(apiVersion);
}

/// Parameters for putting a transaction
@JsonSerializable(fieldRename: FieldRename.snake)
class PutTransactionParams extends RpcParams {
  final TransactionCondor transaction;

  PutTransactionParams({required this.transaction});

  factory PutTransactionParams.fromJson(Map<String, dynamic> json) => _$PutTransactionParamsFromJson(json);
  Map<String, dynamic> toJson() => _$PutTransactionParamsToJson(this);
}

/// Response for putting a transaction
@JsonSerializable(fieldRename: FieldRename.snake)
class PutTransactionResult extends RpcResult {
  final String transactionHash;

  factory PutTransactionResult.fromJson(Map<String, dynamic> json) => _$PutTransactionResultFromJson(json);
  Map<String, dynamic> toJson() => _$PutTransactionResultToJson(this);

  PutTransactionResult(String apiVersion, this.transactionHash) : super(apiVersion);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ExecutionResult {
  bool success;
  int? errorCode;
  String? errorMessage;
  BigInt? gasUsed;
  List<TransformEntry>? transforms;

  factory ExecutionResult.fromJson(Map<String, dynamic> json) => _$ExecutionResultFromJson(json);
  Map<String, dynamic> toJson() => _$ExecutionResultToJson(this);

  ExecutionResult(this.success, this.errorCode, this.errorMessage, this.gasUsed, this.transforms);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TransformEntry {
  String key;
  Map<String, dynamic> transform;

  factory TransformEntry.fromJson(Map<String, dynamic> json) => _$TransformEntryFromJson(json);
  Map<String, dynamic> toJson() => _$TransformEntryToJson(this);

  TransformEntry(this.key, this.transform);
}