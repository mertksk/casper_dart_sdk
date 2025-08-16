// Legacy transaction_v1.dart - deprecated in favor of transaction_condor.dart
// This file is kept for backward compatibility but should not be used

import 'transaction_condor.dart';

@Deprecated('Use TransactionCondor from transaction_condor.dart instead')
export 'transaction_condor.dart' show TransactionCondor;

@Deprecated('Use TransactionCondor instead')
typedef TransactionV1 = TransactionCondor;