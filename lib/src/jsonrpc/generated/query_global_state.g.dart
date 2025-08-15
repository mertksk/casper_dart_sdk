// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../query_global_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueryGlobalStateParams _$QueryGlobalStateParamsFromJson(
  Map<String, dynamic> json,
) => QueryGlobalStateParams(
  json['key'] as String,
  json['state_identifier'] as Map<String, dynamic>,
  (json['path'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$QueryGlobalStateParamsToJson(
  QueryGlobalStateParams instance,
) => <String, dynamic>{
  'key': instance.key,
  'state_identifier': instance.stateIdentifier,
  'path': instance.path,
};

QueryGlobalStateResult _$QueryGlobalStateResultFromJson(
  Map<String, dynamic> json,
) => QueryGlobalStateResult(
  json['api_version'],
  _$JsonConverterFromJson<Map<String, dynamic>, dynamic>(
    json['stored_value'],
    const StoredValueJsonConverter().fromJson,
  ),
  json['block_header'] == null
      ? null
      : BlockHeader.fromJson(json['block_header'] as Map<String, dynamic>),
  json['merkle_proof'] as String,
);

Map<String, dynamic> _$QueryGlobalStateResultToJson(
  QueryGlobalStateResult instance,
) => <String, dynamic>{
  'api_version': instance.apiVersion,
  'block_header': instance.blockHeader?.toJson(),
  'stored_value': const StoredValueJsonConverter().toJson(instance.storedValue),
  'merkle_proof': instance.merkleProof,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);
