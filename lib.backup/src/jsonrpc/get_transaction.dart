import 'package:json_annotation/json_annotation.dart';
import 'package:casper_dart_sdk/src/types/transaction.dart';
import 'package:casper_dart_sdk/src/types/transaction_v1.dart';
import 'package:casper_dart_sdk/src/types/block.dart';
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
  final String apiVersion;
  final Transaction? transaction;
  final TransactionV1? transactionV1;
  final String transactionHash;
  final List<ExecutionResult> executionResults;

  factory GetTransactionResult.fromJson(Map<String, dynamic> json) => _$GetTransactionResultFromJson(json);
  Map<String, dynamic> toJson() => _$GetTransactionResultToJson(this);

  GetTransactionResult({
    required this.apiVersion,
    this.transaction,
    this.transactionV1,
    required this.transactionHash,
    required this.executionResults,
  });

  /// Gets the appropriate transaction based on network version
  dynamic getTransaction() {
    return transactionV1 ?? transaction;
  }
}

/// Parameters for putting a transaction
@JsonSerializable(fieldRename: FieldRename.snake)
class PutTransactionParams extends RpcParams {
  final Transaction? transaction;
  final TransactionV1? transactionV1;

  PutTransactionParams({this.transaction, this.transactionV1})
      : assert(transaction != null || transactionV1 != null, 'Either transaction or transactionV1 must be provided');

  factory PutTransactionParams.fromJson(Map<String, dynamic> json) => _$PutTransactionParamsFromJson(json);
  Map<String, dynamic> toJson() => _$PutTransactionParamsToJson(this);

  /// Gets the transaction data
  dynamic getTransaction() {
    return transactionV1 ?? transaction;
  }
}

/// Response for putting a transaction
@JsonSerializable(fieldRename: FieldRename.snake)
class PutTransactionResult extends RpcResult {
  final String apiVersion;
  final String transactionHash;

  factory PutTransactionResult.fromJson(Map<String, dynamic> json) => _$PutTransactionResultFromJson(json);
  Map<String, dynamic> toJson() => _$PutTransactionResultToJson(this);

  PutTransactionResult({
    required this.apiVersion,
    required this.transactionHash,
  });
}

/// Parameters for getting transaction with block information
@JsonSerializable(fieldRename: FieldRename.snake)
class GetTransactionWithBlockParams extends RpcParams {
  final String transactionHash;
  final bool includeBlock;

  GetTransactionWithBlockParams({
    required this.transactionHash,
    this.includeBlock = false,
  });

  factory GetTransactionWithBlockParams.fromJson(Map<String, dynamic> json) =>
      _$GetTransactionWithBlockParamsFromJson(json);
  Map<String, dynamic> toJson() => _$GetTransactionWithBlockParamsToJson(this);
}

/// Enhanced transaction result with block information
@JsonSerializable(fieldRename: FieldRename.snake)
class GetTransactionWithBlockResult extends RpcResult {
  final String apiVersion;
  final Transaction? transaction;
  final TransactionV1? transactionV1;
  final String transactionHash;
  final List<ExecutionResult> executionResults;
  final Block? block;
  final BlockV1? blockV1;

  factory GetTransactionWithBlockResult.fromJson(Map<String, dynamic> json) =>
      _$GetTransactionWithBlockResultFromJson(json);
  Map<String, dynamic> toJson() => _$GetTransactionWithBlockResultToJson(this);

  GetTransactionWithBlockResult({
    required this.apiVersion,
    this.transaction,
    this.transactionV1,
    required this.transactionHash,
    required this.executionResults,
    this.block,
    this.blockV1,
  });

  /// Gets the appropriate transaction based on network version
  dynamic getTransaction() {
    return transactionV1 ?? transaction;
  }

  /// Gets the appropriate block based on network version
  dynamic getBlock() {
    return blockV1 ?? block;
  }
}

/// Parameters for getting validator rewards
@JsonSerializable(fieldRename: FieldRename.snake)
class GetValidatorRewardsParams extends RpcParams {
  final String? eraId;
  final String? validatorPublicKey;
  final int? limit;
  final int? page;

  GetValidatorRewardsParams({
    this.eraId,
    this.validatorPublicKey,
    this.limit,
    this.page,
  });

  factory GetValidatorRewardsParams.fromJson(Map<String, dynamic> json) =>
      _$GetValidatorRewardsParamsFromJson(json);
  Map<String, dynamic> toJson() => _$GetValidatorRewardsParamsToJson(this);
}

/// Validator reward information
@JsonSerializable(fieldRename: FieldRename.snake)
class ValidatorReward {
  final String validatorPublicKey;
  final String eraId;
  final BigInt amount;
  final String blockHash;
  final DateTime timestamp;

  factory ValidatorReward.fromJson(Map<String, dynamic> json) => _$ValidatorRewardFromJson(json);
  Map<String, dynamic> toJson() => _$ValidatorRewardToJson(this);

  ValidatorReward({
    required this.validatorPublicKey,
    required this.eraId,
    required this.amount,
    required this.blockHash,
    required this.timestamp,
  });
}

/// Response for getting validator rewards
@JsonSerializable(fieldRename: FieldRename.snake)
class GetValidatorRewardsResult extends RpcResult {
  final String apiVersion;
  final List<ValidatorReward> rewards;
  final int totalCount;
  final int page;
  final int limit;

  factory GetValidatorRewardsResult.fromJson(Map<String, dynamic> json) =>
      _$GetValidatorRewardsResultFromJson(json);
  Map<String, dynamic> toJson() => _$GetValidatorRewardsResultToJson(this);

  GetValidatorRewardsResult({
    required this.apiVersion,
    required this.rewards,
    required this.totalCount,
    required this.page,
    required this.limit,
  });
}

/// Parameters for getting block with lanes
@JsonSerializable(fieldRename: FieldRename.snake)
class GetBlockWithLanesParams extends RpcParams {
  final String? blockHash;
  final int? height;

  GetBlockWithLanesParams({
    this.blockHash,
    this.height,
  }) : assert(blockHash != null || height != null, 'Either blockHash or height must be provided');

  factory GetBlockWithLanesParams.fromJson(Map<String, dynamic> json) =>
      _$GetBlockWithLanesParamsFromJson(json);
  Map<String, dynamic> toJson() => _$GetBlockWithLanesParamsToJson(this);
}

/// Response for getting block with lane information
@JsonSerializable(fieldRename: FieldRename.snake)
class GetBlockWithLanesResult extends RpcResult {
  final String apiVersion;
  final BlockV1 block;
  final List<List<String>> lanes; // Transaction hashes organized by lane

  factory GetBlockWithLanesResult.fromJson(Map<String, dynamic> json) =>
      _$GetBlockWithLanesResultFromJson(json);
  Map<String, dynamic> toJson() => _$GetBlockWithLanesResultToJson(this);

  GetBlockWithLanesResult({
    required this.apiVersion,
    required this.block,
    required this.lanes,
  });
}
