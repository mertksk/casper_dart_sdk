enum KeyAlgorithm {
  ed25519,
  secp256k1,
}

extension KeyAlgorithmExtension on KeyAlgorithm {
  String get name {
    switch (this) {
      case KeyAlgorithm.ed25519:
        return 'ed25519';
      case KeyAlgorithm.secp256k1:
        return 'secp256k1';
    }
  }

  int get identifierByte {
    switch (this) {
      case KeyAlgorithm.ed25519:
        return 1;
      case KeyAlgorithm.secp256k1:
        return 2;
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

  int get value => identifierByte;
}

// Additional extension for static methods
extension KeyAlgorithmExt on KeyAlgorithm {
  static KeyAlgorithm fromIdentifierByte(int byte) {
    switch (byte) {
      case 1:
        return KeyAlgorithm.ed25519;
      case 2:
        return KeyAlgorithm.secp256k1;
      default:
        throw ArgumentError('Unknown key algorithm identifier: $byte');
    }
  }
}
