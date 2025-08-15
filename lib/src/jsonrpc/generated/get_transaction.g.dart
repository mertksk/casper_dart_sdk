// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../get_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetTransactionParams _$GetTransactionParamsFromJson(
  Map<String, dynamic> json,
) => GetTransactionParams(json['transaction_hash'] as String);

Map<String, dynamic> _$GetTransactionParamsToJson(
  GetTransactionParams instance,
) => <String, dynamic>{'transaction_hash': instance.transactionHash};

GetTransactionResult _$GetTransactionResultFromJson(
  Map<String, dynamic> json,
) => GetTransactionResult(
  json['api_version'] as String,
  json['transaction'] == null
      ? null
      : TransactionCondor.fromJson(json['transaction'] as Map<String, dynamic>),
  (json['execution_results'] as List<dynamic>)
      .map((e) => ExecutionResult.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GetTransactionResultToJson(
  GetTransactionResult instance,
) => <String, dynamic>{
  'api_version': instance.apiVersion,
  'transaction': instance.transaction?.toJson(),
  'execution_results': instance.executionResults
      .map((e) => e.toJson())
      .toList(),
};

PutTransactionParams _$PutTransactionParamsFromJson(
  Map<String, dynamic> json,
) => PutTransactionParams(
  TransactionCondor.fromJson(json['transaction'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PutTransactionParamsToJson(
  PutTransactionParams instance,
) => <String, dynamic>{'transaction': instance.transaction.toJson()};

PutTransactionResult _$PutTransactionResultFromJson(
  Map<String, dynamic> json,
) => PutTransactionResult(
  json['api_version'] as String,
  json['transaction_hash'] as String,
);

Map<String, dynamic> _$PutTransactionResultToJson(
  PutTransactionResult instance,
) => <String, dynamic>{
  'api_version': instance.apiVersion,
  'transaction_hash': instance.transactionHash,
};

ExecutionResult _$ExecutionResultFromJson(Map<String, dynamic> json) =>
    ExecutionResult(
      json['success'] as bool,
      (json['error_code'] as num?)?.toInt(),
      json['error_message'] as String?,
      json['gas_used'] == null
          ? null
          : BigInt.parse(json['gas_used'] as String),
      (json['transforms'] as List<dynamic>?)
          ?.map((e) => TransformEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ExecutionResultToJson(ExecutionResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'error_code': instance.errorCode,
      'error_message': instance.errorMessage,
      'gas_used': instance.gasUsed?.toString(),
      'transforms': instance.transforms?.map((e) => e.toJson()).toList(),
    };

TransformEntry _$TransformEntryFromJson(Map<String, dynamic> json) =>
    TransformEntry(
      json['key'] as String,
      json['transform'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$TransformEntryToJson(TransformEntry instance) =>
    <String, dynamic>{'key': instance.key, 'transform': instance.transform};
