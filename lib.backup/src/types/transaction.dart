import 'dart:convert';
import 'dart:typed_data';

import 'package:buffer/buffer.dart';
import 'package:casper_dart_sdk/casper_dart_sdk.dart';
import 'package:convert/convert.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pointycastle/digests/blake2b.dart';

import 'package:casper_dart_sdk/src/crpyt/key_pair.dart';
import 'package:casper_dart_sdk/src/helpers/checksummed_hex.dart';
import 'package:casper_dart_sdk/src/helpers/string_utils.dart';
import 'package:casper_dart_sdk/src/serde/byte_serializable.dart';
import 'package:casper_dart_sdk/src/types/global_state_key.dart';
import 'package:casper_dart_sdk/src/types/cl_public_key.dart';
import 'package:casper_dart_sdk/src/types/cl_signature.dart';
import 'package:casper_dart_sdk/src/types/named_arg.dart';

part 'generated/transaction.g.dart';

/// Base transaction class for Condor network support
/// This replaces Deploy in Condor networks (Casper 2.0+)
@JsonSerializable(fieldRename: FieldRename.snake)
class Transaction implements ByteSerializable {
  @Cep57ChecksummedHexJsonConverter()
  late String hash;

  late TransactionHeader header;

  @ExecutableDeployItemJsonConverter()
  late ExecutableDeployItem payment;

  @ExecutableDeployItemJsonConverter()
  late ExecutableDeployItem session;

  List<TransactionApproval> approvals = [];

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  Transaction(this.hash, this.header, this.payment, this.session, this.approvals);

  Transaction.create(this.header, this.payment, this.session) {
    header.bodyHash = Cep57Checksum.encode(bodyHash);
    hash = Cep57Checksum.encode(headerHash);
  }

  /// Creates a [Transaction] object to make a transfer of CSPR between two accounts.
  /// [from] is the source account key.
  /// [to] is the target account key.
  /// [amount] is the amount of CSPR (in motes) to transfer.
  /// [paymentAmount] is the amount of CSPR (in motes) to pay for the transfer.
  /// [chainName] is the name of the network that will execute the transfer.
  /// [idTransfer] is the id of the transfer. Can be null if not needed.
  /// [gasPrice] is the gas price. Default value is 1.
  /// [ttl] is the validity period of the Transaction since creation. Default value is 30 minutes.
  Transaction.standardTransfer(ClPublicKey from, ClPublicKey to, BigInt amount, BigInt paymentAmount, String chainName,
      [int? idTransfer, int gasPrice = 1, Duration ttl = const Duration(minutes: 30)]) {
    header = TransactionHeader.withoutBodyHash(
      from,
      DateTime.now(),
      ttl,
      gasPrice,
      [],
      chainName,
    );
    payment = ModuleBytesDeployItem.fromAmount(paymentAmount);
    session = TransferDeployItem.transfer(amount, AccountHashKey.fromPublicKey(to), idTransfer);
    header.bodyHash = Cep57Checksum.encode(bodyHash);
    hash = Cep57Checksum.encode(headerHash);
  }

  /// Creates a [Transaction] object to deploy a contract in the network.
  /// [wasmBytes] is the array of bytes of the contract compiled in Wasm.
  /// [instigator] is the public key of the account that deploys the contract.
  /// [paymentAmount] is the amount of CSPR (in motes) to pay for the deploy.
  /// [chainName] is the name of the network that will execute the deploy.
  /// [gasPrice] is the gas price. Default value is 1.
  /// [ttl] is the validity period of the Transaction since creation. Default value is 30 minutes.
  Transaction.contract(Uint8List wasmBytes, ClPublicKey instigator, BigInt paymentAmount, String chainName,
      [int gasPrice = 1, Duration ttl = const Duration(minutes: 30)]) {
    header = TransactionHeader.withoutBodyHash(
      instigator,
      DateTime.now(),
      ttl,
      gasPrice,
      [],
      chainName,
    );

    payment = ModuleBytesDeployItem.fromAmount(paymentAmount);
    session = ModuleBytesDeployItem.fromBytes(wasmBytes);
    header.bodyHash = Cep57Checksum.encode(bodyHash);
    hash = Cep57Checksum.encode(headerHash);
  }

  /// Creates a [Transaction] object to call an entry point in a contract.
  /// [contractName] is the named key in the caller account that contains a reference to the contract hash key.
  /// [contractEntryPoint] is the entry point of the contract to be called.
  /// [args] is the list of runtime arguments to be passed to the entry point.
  /// [caller] is the public key of the account that calls the contract.
  /// [paymentAmount] is the amount of CSPR (in motes) to pay for the call.
  /// [chainName] is the name of the network that will execute the call.
  /// [gasPrice] is the gas price. Default value is 1.
  /// [ttl] is the validity period of the Transaction since creation. Default value is 30 minutes.
  Transaction.contractCall(String contractName, String contractEntryPoint, List<NamedArg> args, ClPublicKey caller,
      BigInt paymentAmount, String chainName,
      [int gasPrice = 1, Duration ttl = const Duration(minutes: 30)]) {
    header = TransactionHeader.withoutBodyHash(
      caller,
      DateTime.now(),
      ttl,
      gasPrice,
      [],
      chainName,
    );

    payment = ModuleBytesDeployItem.fromAmount(paymentAmount);
    session = StoredContractByNameDeployItem(contractName, contractEntryPoint, args);
    header.bodyHash = Cep57Checksum.encode(bodyHash);
    hash = Cep57Checksum.encode(headerHash);
  }

  Future<Uint8List> sign(KeyPair pair) async {
    Uint8List signatureBytes = await pair.sign(Uint8List.fromList(hex.decode(hash)));
    addApproval(TransactionApproval(ClSignature.fromBytes(signatureBytes, pair.publicKey.keyAlgorithm), pair.publicKey));
    return signatureBytes;
  }

  void addApproval(TransactionApproval approval) {
    approvals.add(approval);
  }

  /// Verifies the approval signatures of the transaction
  /// Returns null if the signature is valid, otherwise
  /// returns the public key of the signer that failed to verify
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
    mem.write(payment.toBytes());
    mem.write(session.toBytes());
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
    mem.write(payment.toBytes());
    mem.write(session.toBytes());
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

  int gasPrice;

  @Cep57ChecksummedHexJsonConverter()
  late String bodyHash;

  List<String> dependencies;

  String chainName;

  factory TransactionHeader.fromJson(Map<String, dynamic> json) => _$TransactionHeaderFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionHeaderToJson(this);

  TransactionHeader(this.initiator, this.timestamp, this.ttl, this.gasPrice, this.bodyHash, this.dependencies, this.chainName);
  TransactionHeader.withoutBodyHash(
      this.initiator, this.timestamp, this.ttl, this.gasPrice, this.dependencies, this.chainName);

  @override
  Uint8List toBytes() {
    ByteDataWriter mem = ByteDataWriter();
    mem.write(initiator.bytesWithKeyAlgorithmIdentifier);
    mem.writeUint64(timestamp.millisecondsSinceEpoch);
    mem.writeUint64(ttl.inMilliseconds);
    mem.writeUint64(gasPrice);
    mem.write(hex.decode(bodyHash));
    mem.writeInt32(dependencies.length);
    for (String dependency in dependencies) {
      mem.write(hex.decode(dependency));
    }
    mem.writeInt32(chainName.length);
    mem.write(utf8.encode(chainName));
    return mem.toBytes();
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TransactionApproval implements ByteSerializable {
  @ClSignatureJsonConverter()
  ClSignature signature;

  @ClPublicKeyJsonConverter()
  ClPublicKey signer;

  factory TransactionApproval.fromJson(Map<String, dynamic> json) => _$TransactionApprovalFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionApprovalToJson(this);

  TransactionApproval(this.signature, this.signer);

  @override
  Uint8List toBytes() {
    ByteDataWriter mem = ByteDataWriter();
    mem.write(signer.bytesWithKeyAlgorithmIdentifier);
    mem.write(signature.bytesWithKeyAlgorithmIdentifier);
    return mem.toBytes();
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TransactionInfo {
  String transactionHash;

  @AccountHashKeyJsonConverter()
  AccountHashKey from;

  BigInt gas;

  @UrefJsonConverter()
  Uref source;

  @TransferKeyJsonConverter()
  List<TransferKey> transfers;

  factory TransactionInfo.fromJson(Map<String, dynamic> json) => _$TransactionInfoFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionInfoToJson(this);

  TransactionInfo(this.transactionHash, this.from, this.gas, this.source, this.transfers);
}
