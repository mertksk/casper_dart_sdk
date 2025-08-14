import 'key_algorithm.dart';

extension KeyAlgorithmExt on KeyAlgorithm {
  static KeyAlgorithm fromIdentifierByte(int identifierByte) {
    switch (identifierByte) {
      case 0x01:
        return KeyAlgorithm.ed25519;
      case 0x02:
        return KeyAlgorithm.secp256k1;
      default:
        throw ArgumentError('Invalid key algorithm identifier: $identifierByte');
    }
  }

  int get identifierByte {
    switch (this) {
      case KeyAlgorithm.ed25519:
        return 0x01;
      case KeyAlgorithm.secp256k1:
        return 0x02;
    }
  }

  String get identifierByteHex {
    return identifierByte.toRadixString(16).padLeft(2, '0');
  }

  int get publicKeyLength {
    switch (this) {
      case KeyAlgorithm.ed25519:
        return 32;
      case KeyAlgorithm.secp256k1:
        return 33;
    }
  }
}
