// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../transaction_condor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionCondor _$TransactionCondorFromJson(Map<String, dynamic> json) =>
    TransactionCondor(
      const Cep57ChecksummedHexJsonConverter().fromJson(json['hash'] as String),
      TransactionHeader.fromJson(json['header'] as Map<String, dynamic>),
      TransactionPayload.fromJson(json['payload'] as Map<String, dynamic>),
      (json['approvals'] as List<dynamic>)
          .map((e) => TransactionApproval.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TransactionCondorToJson(TransactionCondor instance) =>
    <String, dynamic>{
      'hash': const Cep57ChecksummedHexJsonConverter().toJson(instance.hash),
      'header': instance.header.toJson(),
      'payload': instance.payload.toJson(),
      'approvals': instance.approvals.map((e) => e.toJson()).toList(),
    };

TransactionHeader _$TransactionHeaderFromJson(Map<String, dynamic> json) =>
    TransactionHeader(
      const ClPublicKeyJsonConverter().fromJson(json['initiator'] as String),
      const DateTimeJsonConverter().fromJson(json['timestamp'] as String),
      const HumanReadableDurationJsonConverter().fromJson(
        json['ttl'] as String,
      ),
      BigInt.parse(json['gas_price'] as String),
      const Cep57ChecksummedHexJsonConverter().fromJson(
        json['body_hash'] as String,
      ),
      json['chain_name'] as String,
    );

Map<String, dynamic> _$TransactionHeaderToJson(TransactionHeader instance) =>
    <String, dynamic>{
      'initiator': const ClPublicKeyJsonConverter().toJson(instance.initiator),
      'timestamp': const DateTimeJsonConverter().toJson(instance.timestamp),
      'ttl': const HumanReadableDurationJsonConverter().toJson(instance.ttl),
      'gas_price': instance.gasPrice.toString(),
      'body_hash': const Cep57ChecksummedHexJsonConverter().toJson(
        instance.bodyHash,
      ),
      'chain_name': instance.chainName,
    };

TransactionApproval _$TransactionApprovalFromJson(Map<String, dynamic> json) =>
    TransactionApproval(
      const ClPublicKeyJsonConverter().fromJson(json['signer'] as String),
      const ClSignatureJsonConverter().fromJson(json['signature'] as String),
    );

Map<String, dynamic> _$TransactionApprovalToJson(
  TransactionApproval instance,
) => <String, dynamic>{
  'signer': const ClPublicKeyJsonConverter().toJson(instance.signer),
  'signature': const ClSignatureJsonConverter().toJson(instance.signature),
};

TransferPayload _$TransferPayloadFromJson(Map<String, dynamic> json) =>
    TransferPayload(
      BigInt.parse(json['amount'] as String),
      const AccountHashKeyJsonConverter().fromJson(json['target'] as String),
      (json['id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TransferPayloadToJson(TransferPayload instance) =>
    <String, dynamic>{
      'amount': instance.amount.toString(),
      'target': const AccountHashKeyJsonConverter().toJson(instance.target),
      'id': instance.id,
    };

DeployWasmPayload _$DeployWasmPayloadFromJson(Map<String, dynamic> json) =>
    DeployWasmPayload(
      const HexStringBytesJsonConverter().fromJson(
        json['wasm_bytes'] as String,
      ),
      const NamedArgsJsonConverter().fromJson(json['args'] as List),
    );

Map<String, dynamic> _$DeployWasmPayloadToJson(
  DeployWasmPayload instance,
) => <String, dynamic>{
  'wasm_bytes': const HexStringBytesJsonConverter().toJson(instance.wasmBytes),
  'args': const NamedArgsJsonConverter().toJson(instance.args),
};

ContractCallPayload _$ContractCallPayloadFromJson(Map<String, dynamic> json) =>
    ContractCallPayload(
      json['contract_hash'] as String,
      json['entry_point'] as String,
      const NamedArgsJsonConverter().fromJson(json['args'] as List),
    );

Map<String, dynamic> _$ContractCallPayloadToJson(
  ContractCallPayload instance,
) => <String, dynamic>{
  'contract_hash': instance.contractHash,
  'entry_point': instance.entryPoint,
  'args': const NamedArgsJsonConverter().toJson(instance.args),
};
