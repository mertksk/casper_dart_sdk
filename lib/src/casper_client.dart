import 'dart:async';
import 'dart:typed_data';

import 'package:casper_dart_sdk/src/constants.dart';
import 'package:casper_dart_sdk/src/http/casper_node_client.dart';
import 'package:casper_dart_sdk/src/jsonrpc/get_account_info.dart';
import 'package:casper_dart_sdk/src/jsonrpc/get_auction_info.dart';
import 'package:casper_dart_sdk/src/jsonrpc/get_balance.dart';
import 'package:casper_dart_sdk/src/jsonrpc/get_block.dart';
import 'package:casper_dart_sdk/src/jsonrpc/get_block_transfers.dart';
import 'package:casper_dart_sdk/src/jsonrpc/get_deploy.dart';
import 'package:casper_dart_sdk/src/jsonrpc/get_dictionary_item.dart';
import 'package:casper_dart_sdk/src/jsonrpc/get_era_info_by_switch_block.dart';
import 'package:casper_dart_sdk/src/jsonrpc/get_item.dart';
import 'package:casper_dart_sdk/src/jsonrpc/get_peers.dart';
import 'package:casper_dart_sdk/src/jsonrpc/get_state_root_hash.dart';
import 'package:casper_dart_sdk/src/jsonrpc/get_status.dart';
import 'package:casper_dart_sdk/src/jsonrpc/get_transaction.dart';
import 'package:casper_dart_sdk/src/jsonrpc/put_deploy.dart';
import 'package:casper_dart_sdk/src/jsonrpc/query_global_state.dart';
import 'package:casper_dart_sdk/src/types/account.dart';
import 'package:casper_dart_sdk/src/types/auction_state.dart';
import 'package:casper_dart_sdk/src/types/block.dart';
import 'package:casper_dart_sdk/src/types/cl_public_key.dart';
import 'package:casper_dart_sdk/src/types/deploy.dart';
import 'package:casper_dart_sdk/src/types/global_state_key.dart';
import 'package:casper_dart_sdk/src/types/named_arg.dart';
import 'package:casper_dart_sdk/src/types/peer.dart';
import 'package:casper_dart_sdk/src/types/transaction_condor.dart';
import 'package:casper_dart_sdk/src/types/transaction_v1.dart';
import 'package:casper_dart_sdk/src/network_detector.dart' hide NetworkVersion;
import 'package:casper_dart_sdk/src/network_detector.dart' as network show NetworkVersion;

/// Main client for interacting with the Casper network
/// Supports both legacy (Deploy) and Condor (Transaction) formats
class CasperClient {
  final CasperNodeRpcClient _nodeClient;
  final NetworkAwareCasperClient _networkClient;

  CasperClient(Uri nodeUrl)
      : _nodeClient = CasperNodeRpcClient(nodeUrl),
        _networkClient = NetworkAwareCasperClient(CasperNodeRpcClient(nodeUrl));

  /// Gets the underlying RPC client
  CasperNodeRpcClient get nodeClient => _nodeClient;

  /// Gets the network-aware client
  NetworkAwareCasperClient get networkClient => _networkClient;

  /// Detects the network version (legacy vs condor)
  Future<network.NetworkVersion> detectNetworkVersion() async {
    return await _networkClient.getNetworkVersion();
  }

  /// Unified method to send transactions/deploys
  /// Automatically detects network version and uses appropriate format
  Future<dynamic> send(dynamic transactionOrDeploy) async {
    final version = await detectNetworkVersion();

    if (version == network.NetworkVersion.condor) {
      if (transactionOrDeploy is TransactionCondor) {
        return putTransaction(transactionOrDeploy);
      } else if (transactionOrDeploy is TransactionV1) {
        return putTransactionV1(transactionOrDeploy);
      }
      throw ArgumentError('Invalid transaction type for Condor network');
    } else {
      if (transactionOrDeploy is Deploy) {
        return putDeploy(transactionOrDeploy);
      }
      throw ArgumentError('Invalid deploy type for legacy network');
    }
  }

  /// Unified method to get transaction/deploy information
  Future<dynamic> get(dynamic hash) async {
    final version = await detectNetworkVersion();

    if (version == network.NetworkVersion.condor) {
      return getTransaction(hash);
    } else {
      return getDeploy(hash);
    }
  }

  /// Creates a transfer transaction/deploy based on network version
  Future<dynamic> createTransfer(
    ClPublicKey from,
    ClPublicKey to,
    BigInt amount,
    BigInt paymentAmount,
    String chainName, {
    int? idTransfer,
    BigInt? gasPrice,
    Duration ttl = const Duration(minutes: 30),
  }) async {
    final version = await detectNetworkVersion();

    if (version == network.NetworkVersion.condor) {
      return TransactionCondor.standardTransfer(
        from,
        to,
        amount,
        paymentAmount,
        chainName,
        idTransfer: idTransfer,
        gasPrice: gasPrice ?? BigInt.one,
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
        (gasPrice ?? BigInt.one).toInt(),
        ttl,
      );
    }
  }

  /// Legacy methods (backward compatibility)

  /// Puts a deploy to the network (legacy)
  Future<PutDeployResult> putDeploy(Deploy deploy) async {
    return await _nodeClient.putDeploy(deploy);
  }

  /// Gets deploy information (legacy)
  Future<GetDeployResult> getDeploy(String deployHash) async {
    return await _nodeClient.getDeploy(deployHash);
  }

  /// Condor methods (new transaction format)

  /// Puts a transaction to the network (Condor)
  Future<PutTransactionResult> putTransaction(TransactionCondor transaction) async {
    return await _nodeClient.putTransaction(transaction);
  }

  /// Puts a transaction V1 to the network (Condor) - Not implemented yet
  Future<PutTransactionResult> putTransactionV1(TransactionV1 transaction) async {
    throw UnimplementedError('TransactionV1 support not implemented yet');
  }

  /// Gets transaction information (Condor)
  Future<GetTransactionResult> getTransaction(String transactionHash) async {
    return await _nodeClient.getTransaction(transactionHash);
  }

  /// Gets transaction with block information (Condor)
  Future<GetTransactionWithBlockResult> getTransactionWithBlock(
    String transactionHash, {
    bool includeBlock = false,
  }) async {
    return await _nodeClient.getTransactionWithBlock(
      transactionHash,
      includeBlock: includeBlock,
    );
  }

  /// Gets validator rewards (Condor)
  Future<GetValidatorRewardsResult> getValidatorRewards({
    String? eraId,
    String? validatorPublicKey,
    int? limit,
    int? page,
  }) async {
    return await _nodeClient.getValidatorRewards(
      eraId: eraId,
      validatorPublicKey: validatorPublicKey,
      limit: limit,
      page: page,
    );
  }

  /// Gets block with lane information (Condor)
  Future<GetBlockWithLanesResult> getBlockWithLanes({
    String? blockHash,
    int? height,
  }) async {
    return await _nodeClient.getBlockWithLanes(
      blockHash: blockHash,
      height: height,
    );
  }

  /// Standard RPC methods (work on both networks)

  /// Gets the current status of the node
  Future<GetStatusResult> getStatus() async {
    return await _nodeClient.getStatus();
  }

  /// Gets the list of peers connected to the node
  Future<GetPeersResult> getPeers() async {
    return await _nodeClient.getPeers();
  }

  /// Gets the current state root hash
  Future<GetStateRootHashResult> getStateRootHash({String? blockHash}) async {
    return await _nodeClient.getStateRootHash(blockHash: blockHash);
  }

  /// Gets a block by hash or height
  Future<GetBlockResult> getBlock({String? blockHash, int? height}) async {
    return await _nodeClient.getBlock(blockHash: blockHash, height: height);
  }

  /// Gets transfers in a block
  Future<GetBlockTransfersResult> getBlockTransfers({String? blockHash, int? height}) async {
    return await _nodeClient.getBlockTransfers(blockHash: blockHash, height: height);
  }

  /// Gets era information by switch block
  Future<GetEraInfoBySwitchBlockResult> getEraInfoBySwitchBlock({String? blockHash, int? height}) async {
    return await _nodeClient.getEraInfoBySwitchBlock(blockHash: blockHash, height: height);
  }

  /// Gets account information
  Future<GetAccountInfoResult> getAccountInfo(ClPublicKey publicKey, {String? blockHash}) async {
    return await _nodeClient.getAccountInfo(publicKey, blockHash: blockHash);
  }

  /// Gets the balance of an account
  Future<GetBalanceResult> getBalance(GlobalStateKey purseUref, {String? stateRootHash, String? blockHash}) async {
    return await _nodeClient.getBalance(purseUref, stateRootHash: stateRootHash, blockHash: blockHash);
  }

  /// Gets auction information
  Future<GetAuctionInfoResult> getAuctionInfo({String? blockHash}) async {
    return await _nodeClient.getAuctionInfo(blockHash: blockHash);
  }

  /// Gets a dictionary item
  Future<GetDictionaryItemResult> getDictionaryItem(String dictionaryKey, String keyName, {String? blockHash}) async {
    return await _nodeClient.getDictionaryItem(dictionaryKey, keyName, blockHash: blockHash);
  }

  /// Queries global state
  Future<QueryGlobalStateResult> queryGlobalState(GlobalStateKey key, {String? stateRootHash, String? blockHash}) async {
    return await _nodeClient.queryGlobalState(key, stateRootHash: stateRootHash, blockHash: blockHash);
  }

  /// Gets an item from state
  Future<GetItemResult> getItem(GlobalStateKey key, {String? stateRootHash, String? blockHash}) async {
    return await _nodeClient.getItem(key, stateRootHash: stateRootHash, blockHash: blockHash);
  }

  /// Clears the network version cache
  void clearNetworkCache() {
    _networkClient.clearCache();
  }
}

/// Enhanced CasperNodeRpcClient with Condor support
extension CondorCasperNodeRpcClient on CasperNodeRpcClient {
  /// Puts a transaction to the network (Condor)
  Future<PutTransactionResult> putTransaction(TransactionCondor transaction) async {
    return await call<PutTransactionResult>(
      RpcMethodName.accountPutTransaction,
      PutTransactionParams(transaction: transaction),
    );
  }

  /// Puts a transaction V1 to the network (Condor) - Not implemented yet
  Future<PutTransactionResult> putTransactionV1(TransactionV1 transaction) async {
    throw UnimplementedError('TransactionV1 support not implemented yet');
  }

  /// Gets transaction information (Condor)
  Future<GetTransactionResult> getTransaction(String transactionHash) async {
    return await call<GetTransactionResult>(
      RpcMethodName.infoGetTransaction,
      GetTransactionParams(transactionHash),
    );
  }

  /// Gets transaction with block information (Condor)
  Future<GetTransactionWithBlockResult> getTransactionWithBlock(
    String transactionHash, {
    bool includeBlock = false,
  }) async {
    return await call<GetTransactionWithBlockResult>(
      RpcMethodName.infoGetTransaction,
      GetTransactionWithBlockParams(
        transactionHash: transactionHash,
        includeBlock: includeBlock,
      ),
    );
  }

  /// Gets validator rewards (Condor)
  Future<GetValidatorRewardsResult> getValidatorRewards({
    String? eraId,
    String? validatorPublicKey,
    int? limit,
    int? page,
  }) async {
    return await call<GetValidatorRewardsResult>(
      RpcMethodName.infoGetValidatorRewards,
      GetValidatorRewardsParams(
        eraId: eraId,
        validatorPublicKey: validatorPublicKey,
        limit: limit,
        page: page,
      ),
    );
  }

  /// Gets block with lane information (Condor)
  Future<GetBlockWithLanesResult> getBlockWithLanes({
    String? blockHash,
    int? height,
  }) async {
    return await call<GetBlockWithLanesResult>(
      RpcMethodName.chainGetBlockWithLanes,
      GetBlockWithLanesParams(
        blockHash: blockHash,
        height: height,
      ),
    );
  }
}
