import 'dart:convert';
import 'dart:typed_data';

import 'package:buffer/buffer.dart';
import 'package:convert/convert.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pointycastle/digests/blake2b.dart';

import 'package:casper_dart_sdk/src/crpyt/key_pair.dart';
import 'package:casper_dart_sdk/src/helpers/checksummed_hex.dart';
import 'package:casper_dart_sdk/src/helpers/string_utils.dart';
import 'package:casper_dart_sdk/src/helpers/byte_utils.dart';
import 'package:casper_dart_sdk/src/serde/byte_serializable.dart';
import 'package:casper_dart_sdk/src/types/global_state_key.dart';
import 'package:casper_dart_sdk/src/types/cl_public_key.dart';
import 'package:casper_dart_sdk/src/types/cl_signature.dart';
import 'package:casper_dart_sdk/src/types/cl_value.dart';

part 'generated/transaction_condor.g.dart';

/// Condor Transaction - replaces Deploy in Casper 2.0
@JsonSerializable(fieldRename: FieldRename.snake)
class TransactionCondor implements ByteSerializable {
  @Cep57ChecksummedHexJsonConverter()
  late String hash;

  late TransactionHeader header;

  late TransactionPayload payload;

  List<TransactionApproval> approvals = [];

  factory TransactionCondor.fromJson(Map<String, dynamic> json) => _$TransactionCondorFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionCondorToJson(this);

  TransactionCondor(this.hash, this.header, this.payload, this.approvals);

  TransactionCondor.create(this.header, this.payload) {
    header.bodyHash = Cep57Checksum.encode(bodyHash);
    hash = Cep57Checksum.encode(headerHash);
  }

  /// Creates a native transfer transaction (Condor version)
  TransactionCondor.transfer(
    ClPublicKey from,
    ClPublicKey to,
    BigInt amount,
    String chainName, {
    int? id,
    BigInt? gasPrice,
    Duration ttl = const Duration(minutes: 30),
  }) {
    header = TransactionHeader.withoutBodyHash(
      from,
      DateTime.now(),
      ttl,
      gasPrice ?? BigInt.one,
      chainName,
    );
    
    payload = TransactionPayload.transfer(
      amount,
      AccountHashKey.fromPublicKey(to),
      id,
    );
    
    header.bodyHash = Cep57Checksum.encode(bodyHash);
    hash = Cep57Checksum.encode(headerHash);
  }

  /// Creates a contract call transaction
  TransactionCondor.contractCall(
    String contractHash,
    String entryPoint,
    List<NamedArg> args,
    ClPublicKey caller,
    String chainName, {
    BigInt? gasPrice,
    Duration ttl = const Duration(minutes: 30),
  }) {
    header = TransactionHeader.withoutBodyHash(
      caller,
      DateTime.now(),
      ttl,
      gasPrice ?? BigInt.one,
      chainName,
    );
    
    payload = TransactionPayload.contractCall(
      contractHash,
      entryPoint,
      args,
    );
    
    header.bodyHash = Cep57Checksum.encode(bodyHash);
    hash = Cep57Checksum.encode(headerHash);
  }

  /// Creates a Wasm deployment transaction
  TransactionCondor.deployWasm(
    Uint8List wasmBytes,
    ClPublicKey deployer,
    String chainName, {
    List<NamedArg>? args,
    BigInt? gasPrice,
    Duration ttl = const Duration(minutes: 30),
  }) {
    header = TransactionHeader.withoutBodyHash(
      deployer,
      DateTime.now(),
      ttl,
      gasPrice ?? BigInt.one,
      chainName,
    );
    
    payload = TransactionPayload.deployWasm(wasmBytes, args ?? []);
    
    header.bodyHash = Cep57Checksum.encode(bodyHash);
    hash = Cep57Checksum.encode(headerHash);
  }

  /// Creates a standard transfer transaction (static factory method)
  static TransactionCondor standardTransfer(
    ClPublicKey from,
    ClPublicKey to,
    BigInt amount,
    BigInt paymentAmount,
    String chainName, {
    int? idTransfer,
    BigInt gasPrice = BigInt.one,
    Duration ttl = const Duration(minutes: 30),
  }) {
    return TransactionCondor.transfer(
      from,
      to,
      amount,
      chainName,
      id: idTransfer,
      gasPrice: gasPrice,
      ttl: ttl,
    );
  }

  /// Creates a contract deployment transaction (static factory method)
  static TransactionCondor contract(
    Uint8List wasmBytes,
    ClPublicKey from,
    BigInt paymentAmount,
    String chainName, {
    BigInt gasPrice = BigInt.one,
    Duration ttl = const Duration(minutes: 30),
  }) {
    return TransactionCondor.deployWasm(
      wasmBytes,
      from,
      chainName,
      gasPrice: gasPrice,
      ttl: ttl,
    );
  }

  Future<Uint8List> sign(KeyPair pair) async {
    Uint8List signatureBytes = await pair.sign(Uint8List.fromList(hex.decode(hash)));
    addApproval(TransactionApproval(pair.publicKey, ClSignature.fromBytes(signatureBytes, pair.publicKey.keyAlgorithm)));
    return signatureBytes;
  }

  void addApproval(TransactionApproval approval) {
    approvals.add(approval);
  }

  Future<ClPublicKey?> verifySignatures() async {
    for (TransactionApproval approval in approvals) {
      if (!(await approval.signer.verify(Uint8List.fromList(hex.decode(hash)), approval.signature.bytes))) {
        return approval.signer;
      }
    }
    return null;
  }

  Uint8List get bodyHash {
    ByteDataWriter mem = ByteDataWriter();
    mem.write(payload.toBytes());
    final blake2 = Blake2bDigest(digestSize: 32);
    final body = mem.toBytes();
    blake2.update(body, 0, body.length);
    Uint8List hash = Uint8List(blake2.digestSize);
    blake2.doFinal(hash, 0);
    return hash;
  }

  Uint8List get headerHash {
    ByteDataWriter mem = ByteDataWriter();
    mem.write(header.toBytes());
    final blake2 = Blake2bDigest(digestSize: 32);
    final body = mem.toBytes();
    blake2.update(body, 0, body.length);
    Uint8List hash = Uint8List(blake2.digestSize);
    blake2.doFinal(hash, 0);
    return hash;
  }

  @override
  Uint8List toBytes() {
    ByteDataWriter mem = ByteDataWriter();
    mem.write(header.toBytes());
    mem.write(hex.decode(hash));
    mem.write(payload.toBytes());
    mem.writeInt32(approvals.length);
    for (var approval in approvals) {
      mem.write(approval.toBytes());
    }
    return mem.toBytes();
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TransactionHeader implements ByteSerializable {
  @ClPublicKeyJsonConverter()
  ClPublicKey initiator;

  @DateTimeJsonConverter()
  DateTime timestamp;

  @HumanReadableDurationJsonConverter()
  Duration ttl;

  BigInt gasPrice;

  @Cep57ChecksummedHexJsonConverter()
  late String bodyHash;

  String chainName;

  factory TransactionHeader.fromJson(Map<String, dynamic> json) => _$TransactionHeaderFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionHeaderToJson(this);

  TransactionHeader(this.initiator, this.timestamp, this.ttl, this.gasPrice, this.bodyHash, this.chainName);
  
  TransactionHeader.withoutBodyHash(
    this.initiator,
    this.timestamp,
    this.ttl,
    this.gasPrice,
    this.chainName,
  );

  @override
  Uint8List toBytes() {
    ByteDataWriter mem = ByteDataWriter();
    mem.write(initiator.bytesWithKeyAlgorithmIdentifier);
    mem.writeUint64(timestamp.millisecondsSinceEpoch);
    mem.writeUint64(ttl.inMilliseconds);
    
    // Write gas price as U512 (variable length)
    Uint8List gasPriceBytes = encodeUnsignedBigIntAsLittleEndian(gasPrice);
    mem.writeUint8(gasPriceBytes.length);
    mem.write(gasPriceBytes);
    
    mem.write(hex.decode(bodyHash));
    mem.writeInt32(chainName.length);
    mem.write(utf8.encode(chainName));
    return mem.toBytes();
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TransactionApproval implements ByteSerializable {
  @ClPublicKeyJsonConverter()
  ClPublicKey signer;

  @ClSignatureJsonConverter()
  ClSignature signature;

  factory TransactionApproval.fromJson(Map<String, dynamic> json) => _$TransactionApprovalFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionApprovalToJson(this);

  TransactionApproval(this.signer, this.signature);

  @override
  Uint8List toBytes() {
    ByteDataWriter mem = ByteDataWriter();
    mem.write(signer.bytesWithKeyAlgorithmIdentifier);
    mem.write(signature.bytesWithKeyAlgorithmIdentifier);
    return mem.toBytes();
  }
}

/// Transaction payload for Condor
abstract class TransactionPayload implements ByteSerializable {
  TransactionPayloadType get payloadType;
  
  factory TransactionPayload.transfer(BigInt amount, AccountHashKey target, int? id) = TransferPayload;
  factory TransactionPayload.deployWasm(Uint8List wasmBytes, List<NamedArg> args) = DeployWasmPayload;
  factory TransactionPayload.contractCall(String contractHash, String entryPoint, List<NamedArg> args) = ContractCallPayload;
  
  factory TransactionPayload.fromJson(Map<String, dynamic> json) {
    final type = json['payload_type'] as String;
    switch (type) {
      case 'Transfer':
        return TransferPayload.fromJson(json);
      case 'DeployWasm':
        return DeployWasmPayload.fromJson(json);
      case 'ContractCall':
        return ContractCallPayload.fromJson(json);
      default:
        throw ArgumentError('Unknown payload type: $type');
    }
  }
  
  Map<String, dynamic> toJson();
}

enum TransactionPayloadType {
  transfer,
  deployWasm,
  contractCall,
  packageCall,
  packageInstall,
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TransferPayload implements TransactionPayload {
  BigInt amount;
  
  @AccountHashKeyJsonConverter()
  AccountHashKey target;
  
  int? id;

  @override
  TransactionPayloadType get payloadType => TransactionPayloadType.transfer;

  TransferPayload(this.amount, this.target, this.id);

  factory TransferPayload.fromJson(Map<String, dynamic> json) => _$TransferPayloadFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$TransferPayloadToJson(this);

  @override
  Uint8List toBytes() {
    ByteDataWriter mem = ByteDataWriter(endian: Endian.little);
    mem.writeUint8(payloadType.index);
    
    // Write amount as U512
    Uint8List amountBytes = encodeUnsignedBigIntAsLittleEndian(amount);
    mem.writeUint8(amountBytes.length);
    mem.write(amountBytes);
    
    // Write target
    mem.write(target.headlessBytes);
    
    // Write optional id
    if (id == null) {
      mem.writeUint8(0);
    } else {
      mem.writeUint8(1);
      mem.writeUint64(id!);
    }
    
    return mem.toBytes();
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class DeployWasmPayload implements TransactionPayload {
  @HexStringBytesJsonConverter()
  Uint8List wasmBytes;
  
  @NamedArgsJsonConverter()
  List<NamedArg> args;

  @override
  TransactionPayloadType get payloadType => TransactionPayloadType.deployWasm;

  DeployWasmPayload(this.wasmBytes, this.args);

  factory DeployWasmPayload.fromJson(Map<String, dynamic> json) => _$DeployWasmPayloadFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$DeployWasmPayloadToJson(this);

  @override
  Uint8List toBytes() {
    ByteDataWriter mem = ByteDataWriter(endian: Endian.little);
    mem.writeUint8(payloadType.index);
    
    // Write wasm bytes
    mem.writeInt32(wasmBytes.length);
    mem.write(wasmBytes);
    
    // Write args
    mem.writeInt32(args.length);
    for (NamedArg arg in args) {
      mem.write(arg.toBytes());
    }
    
    return mem.toBytes();
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ContractCallPayload implements TransactionPayload {
  String contractHash;
  String entryPoint;
  
  @NamedArgsJsonConverter()
  List<NamedArg> args;

  @override
  TransactionPayloadType get payloadType => TransactionPayloadType.contractCall;

  ContractCallPayload(this.contractHash, this.entryPoint, this.args);

  factory ContractCallPayload.fromJson(Map<String, dynamic> json) => _$ContractCallPayloadFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$ContractCallPayloadToJson(this);

  @override
  Uint8List toBytes() {
    ByteDataWriter mem = ByteDataWriter(endian: Endian.little);
    mem.writeUint8(payloadType.index);
    
    // Write contract hash
    mem.write(hex.decode(contractHash));
    
    // Write entry point
    List<int> entryPointBytes = utf8.encode(entryPoint);
    mem.writeInt32(entryPointBytes.length);
    mem.write(entryPointBytes);
    
    // Write args
    mem.writeInt32(args.length);
    for (NamedArg arg in args) {
      mem.write(arg.toBytes());
    }
    
    return mem.toBytes();
  }
}

// Helper classes for named arguments
class NamedArg implements ByteSerializable {
  String name;
  ClValue value;

  NamedArg(this.name, this.value);

  @override
  Uint8List toBytes() {
    ByteDataWriter mem = ByteDataWriter(endian: Endian.little);
    List<int> nameBytes = utf8.encode(name);
    mem.writeInt32(nameBytes.length);
    mem.write(nameBytes);
    mem.write(value.toBytes());
    return mem.toBytes();
  }

  factory NamedArg.fromJson(Map<String, dynamic> json) {
    return NamedArg(
      json['name'] as String,
      ClValue.fromJson(json['value'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value.toJson(),
    };
  }
}

class NamedArgsJsonConverter extends JsonConverter<List<NamedArg>, List<dynamic>> {
  const NamedArgsJsonConverter();

  @override
  List<NamedArg> fromJson(List<dynamic> json) {
    final List<NamedArg> args = <NamedArg>[];
    for (int i = 0; i < json.length; i++) {
      final List<dynamic> arg = json[i];
      final String name = arg[0];
      final Map<String, dynamic> value = arg[1];
      args.add(NamedArg(name, ClValue.fromJson(value)));
    }
    return args;
  }

  @override
  List<dynamic> toJson(List<NamedArg> object) {
    final List<dynamic> args = [];
    for (int i = 0; i < object.length; i++) {
      final NamedArg arg = object[i];
      args.add([arg.name, arg.value.toJson()]);
    }
    return args;
  }
}

Uint8List encodeUnsignedBigIntAsLittleEndian(BigInt number) {
  if (number == BigInt.zero) {
    return Uint8List.fromList([0]);
  }
  
  List<int> bytes = [];
  BigInt temp = number;
  while (temp > BigInt.zero) {
    bytes.add((temp & BigInt.from(0xFF)).toInt());
    temp = temp >> 8;
  }
  
  return Uint8List.fromList(bytes);
}