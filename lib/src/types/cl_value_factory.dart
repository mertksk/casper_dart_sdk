import 'cl_value.dart';
import 'cl_public_key.dart';

class ClValue {
  static ClValueU512 u512(BigInt value) => ClValueU512(value);
  static ClValuePublicKey publicKey(ClPublicKey key) => ClValuePublicKey(key);
}
