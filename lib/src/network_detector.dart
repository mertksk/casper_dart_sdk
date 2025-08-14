import 'dart:async';
import 'package:casper_dart_sdk/src/http/casper_node_client.dart';
import 'package:casper_dart_sdk/src/jsonrpc/get_status.dart';

/// Network version detection for Condor compatibility
/// Automatically determines whether to use legacy Deploy or new Transaction format
enum NetworkVersion {
  legacy, // Pre-Condor networks (Casper 1.x)
  condor, // Condor networks (Casper 2.0+)
}

/// Configuration for network detection
class NetworkDetectionConfig {
  final Duration timeout;
  final int maxRetries;

  const NetworkDetectionConfig({
    this.timeout = const Duration(seconds: 10),
    this.maxRetries = 3,
  });
}

/// Network detector that determines the network version
class NetworkDetector {
  final CasperNodeRpcClient _client;
  final NetworkDetectionConfig _config;

  NetworkDetector(this._client, {NetworkDetectionConfig? config})
      : _config = config ?? const NetworkDetectionConfig();

  /// Detects the network version by querying the node status
  Future<NetworkVersion> detectNetworkVersion() async {
    int attempts = 0;
    Exception? lastError;

    while (attempts < _config.maxRetries) {
      try {
        final status = await _client.getStatus().timeout(_config.timeout);
        return _determineVersionFromStatus(status);
      } catch (e) {
        lastError = e as Exception;
        attempts++;
        if (attempts >= _config.maxRetries) {
          break;
        }
        await Future.delayed(Duration(milliseconds: 100 * attempts));
      }
    }

    // If detection fails, default to legacy for backward compatibility
    print('Warning: Failed to detect network version, defaulting to legacy: $lastError');
    return NetworkVersion.legacy;
  }

  /// Determines network version from node status
  NetworkVersion _determineVersionFromStatus(GetStatusResult status) {
    final apiVersion = status.apiVersion;
    final protocolVersion = status.protocolVersion;

    // Condor networks use protocol version 2.0.0 or higher
    // and have specific API version patterns
    try {
      final protocolParts = protocolVersion.split('.');
      final majorVersion = int.parse(protocolParts[0]);

      if (majorVersion >= 2) {
        return NetworkVersion.condor;
      }

      // Also check for Condor-specific features in status
      if (status.buildVersion.contains('condor') ||
          status.buildVersion.contains('2.0') ||
          _hasCondorFeatures(status)) {
        return NetworkVersion.condor;
      }

      return NetworkVersion.legacy;
    } catch (e) {
      // If parsing fails, assume legacy for safety
      return NetworkVersion.legacy;
    }
  }

  /// Checks for Condor-specific features in status
  bool _hasCondorFeatures(GetStatusResult status) {
    // Condor networks have additional fields in status
    try {
      final rawJson = status.toJson();

      // Check for Condor-specific fields
      if (rawJson.containsKey('validator_rewards') ||
          rawJson.containsKey('block_lanes') ||
          rawJson.containsKey('zug_consensus')) {
        return true;
      }

      // Check for transaction-related fields
      if (rawJson.containsKey('transaction_count') ||
          rawJson.containsKey('transaction_rate')) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Gets the appropriate RPC method name based on network version
  static String getTransactionMethod(NetworkVersion version) {
    return version == NetworkVersion.condor
        ? 'account_put_transaction'
        : 'account_put_deploy';
  }

  static String getTransactionInfoMethod(NetworkVersion version) {
    return version == NetworkVersion.condor
        ? 'info_get_transaction'
        : 'info_get_deploy';
  }

  /// Validates if a transaction format is compatible with the network
  static bool isTransactionCompatible(NetworkVersion version, Type transactionType) {
    if (version == NetworkVersion.condor) {
      return transactionType.toString() == 'Transaction' ||
             transactionType.toString() == 'TransactionV1';
    } else {
      return transactionType.toString() == 'Deploy';
    }
  }
}

/// Network-aware client wrapper
class NetworkAwareCasperClient {
  final CasperNodeRpcClient _client;
  NetworkVersion? _cachedVersion;
  DateTime? _lastDetectionTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  NetworkAwareCasperClient(this._client);

  /// Gets the network version with caching
  Future<NetworkVersion> getNetworkVersion() async {
    final now = DateTime.now();

    // Use cached version if still valid
    if (_cachedVersion != null &&
        _lastDetectionTime != null &&
        now.difference(_lastDetectionTime!) < _cacheDuration) {
      return _cachedVersion!;
    }

    // Detect new version
    final detector = NetworkDetector(_client);
    _cachedVersion = await detector.detectNetworkVersion();
    _lastDetectionTime = now;

    return _cachedVersion!;
  }

  /// Clears the network version cache
  void clearCache() {
    _cachedVersion = null;
    _lastDetectionTime = null;
  }

  /// Gets the appropriate RPC method name for the current network
  Future<String> getTransactionMethod() async {
    final version = await getNetworkVersion();
    return NetworkDetector.getTransactionMethod(version);
  }

  /// Validates transaction compatibility
  Future<bool> validateTransactionCompatibility(Type transactionType) async {
    final version = await getNetworkVersion();
    return NetworkDetector.isTransactionCompatible(version, transactionType);
  }
}
