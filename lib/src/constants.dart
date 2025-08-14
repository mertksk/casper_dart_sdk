class RpcMethodName {
  static const String rpcDiscover = 'rpc.discover';

  // Info - Legacy
  static const String infoGetPeers = "info_get_peers";
  static const String infoGetDeploy = "info_get_deploy";
  static const String infoGetStatus = "info_get_status";
  
  // Info - Condor
  static const String infoGetTransaction = "info_get_transaction";
  static const String infoGetValidatorRewards = "info_get_validator_rewards";

  // Chain - Legacy
  static const String chainGetStateRootHash = "chain_get_state_root_hash";
  static const String chainGetBlock = "chain_get_block";
  static const String chainGetBlockTransfers = "chain_get_block_transfers";
  static const String chainGetEraInfoBySwitchBlock = "chain_get_era_info_by_switch_block";
  
  // Chain - Condor
  static const String chainGetBlockWithLanes = "chain_get_block_with_lanes";
  static const String chainGetTransactionByHash = "chain_get_transaction_by_hash";

  // State
  static const String stateGetBalance = "state_get_balance";
  static const String queryGlobalState = "query_global_state";
  static const String stateGetItem = "state_get_item";
  static const String stateGetAuctionInfo = "state_get_auction_info";
  static const String stateGetDictionaryItem = "state_get_dictionary_item";
  static const String stateGetAccountInfo = "state_get_account_info";
  
  // State - Condor
  static const String stateGetEntity = "state_get_entity";
  static const String stateGetPackage = "state_get_package";

  // Account - Legacy
  static const String accountPutDeploy = "account_put_deploy";
  
  // Account - Condor
  static const String accountPutTransaction = "account_put_transaction";
  static const String accountGetTransactionStatus = "account_get_transaction_status";
}

enum NetworkVersion {
  legacy,  // Pre-Condor (Casper 1.x)
  condor   // Condor (Casper 2.0)
}
