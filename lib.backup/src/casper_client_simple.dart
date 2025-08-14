// Simplified CasperClient for Condor compatibility
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'types/cl_public_key.dart';
import 'types/transaction_simple.dart';

/// Network version enum
enum NetworkVersion {
  legacy,
  condor,
}

/// Simplified CasperClient for Condor compatibility
class CasperClient {
  final http.Client _httpClient;
  final Uri _rpcUrl;
  NetworkVersion? _networkVersion;

  CasperClient(String rpcUrl)
      : _httpClient = http.Client(),
        _rpcUrl = Uri.parse(rpcUrl);

  /// Detect network version
  Future<NetworkVersion> detectNetworkVersion() async {
    try {
      // Try Condor-specific RPC call
      final response = await _callRpc('info_get_status', {});
      final result = response['result'];

      // Check if this is a Condor network
      if (result['protocol_version'] != null) {
        final version = result['protocol_version'] as String;
        if (version.startsWith('2.')) {
          _networkVersion = NetworkVersion.condor;
        } else {
          _networkVersion = NetworkVersion.legacy;
        }
      } else {
        _networkVersion = NetworkVersion.legacy;
      }

      return _networkVersion!;
    } catch (e) {
      // Fallback to legacy
      _networkVersion = NetworkVersion.legacy;
      return _networkVersion!;
    }
  }

  /// Send a transaction (works for both legacy and Condor)
  Future<Map<String, dynamic>> sendTransaction(Transaction transaction) async {
    final version = _networkVersion ?? await detectNetworkVersion();

    if (version == NetworkVersion.condor) {
      return await _sendCondorTransaction(transaction);
    } else {
      throw UnsupportedError('Legacy deploy support not implemented in this simplified version');
    }
  }

  /// Send transaction to Condor network
  Future<Map<String, dynamic>> _sendCondorTransaction(Transaction transaction) async {
    final params = {
      'transaction': transaction.toJson(),
    };

    return await _callRpc('account_put_transaction', params);
  }

  /// Get transaction info
  Future<Map<String, dynamic>> getTransaction(String transactionHash) async {
    final params = {
      'transaction_hash': transactionHash,
    };

    return await _callRpc('info_get_transaction', params);
  }

  /// Get account info
  Future<Map<String, dynamic>> getAccountInfo(ClPublicKey publicKey) async {
    final params = {
      'public_key': publicKey.toHex(),
    };

    return await _callRpc('state_get_account_info', params);
  }

  /// Get balance
  Future<BigInt> getBalance(ClPublicKey publicKey) async {
    final accountInfo = await getAccountInfo(publicKey);
    final result = accountInfo['result'];

    if (result == null || result['account'] == null) {
      return BigInt.zero;
    }

    final mainPurse = result['account']['main_purse'] as String;
    return await getBalanceByURef(mainPurse);
  }

  /// Get balance by URef
  Future<BigInt> getBalanceByURef(String uref) async {
    final params = {
      'uref': uref,
    };

    final response = await _callRpc('state_get_balance', params);
    final balance = response['result']['balance_value'] as String;
    return BigInt.parse(balance);
  }

  /// Get latest block
  Future<Map<String, dynamic>> getLatestBlock() async {
    return await _callRpc('chain_get_block', {});
  }

  /// Get block by hash
  Future<Map<String, dynamic>> getBlock(String blockHash) async {
    final params = {
      'block_hash': blockHash,
    };

    return await _callRpc('chain_get_block', params);
  }

  /// Get block by height
  Future<Map<String, dynamic>> getBlockByHeight(int height) async {
    final params = {
      'height': height,
    };

    return await _callRpc('chain_get_block', params);
  }

  /// Get validator rewards
  Future<Map<String, dynamic>> getValidatorRewards({
    String? eraId,
    String? validatorPublicKey,
  }) async {
    final params = {};

    if (eraId != null) {
      params['era_id'] = eraId;
    }

    if (validatorPublicKey != null) {
      params['validator_public_key'] = validatorPublicKey;
    }

    return await _callRpc('info_get_validator_rewards', params);
  }

  /// Get block with lanes (Condor specific)
  Future<Map<String, dynamic>> getBlockWithLanes({
    String? blockHash,
    int? height,
  }) async {
    final params = {};

    if (blockHash != null) {
      params['block_hash'] = blockHash;
    }

    if (height != null) {
      params['height'] = height;
    }

    return await _callRpc('chain_get_block_with_lanes', params);
  }

  /// Generic RPC call
  Future<Map<String, dynamic>> _callRpc(String method, Map<String, dynamic> params) async {
    final request = {
      'jsonrpc': '2.0',
      'method': method,
      'params': params,
      'id': DateTime.now().millisecondsSinceEpoch,
    };

    final response = await _httpClient.post(
      _rpcUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request),
    );

    if (response.statusCode != 200) {
      throw Exception('RPC call failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);

    if (data['error'] != null) {
      throw Exception('RPC error: ${data['error']}');
    }

    return data;
  }

  /// Close the client
  void close() {
    _httpClient.close();
  }
}
