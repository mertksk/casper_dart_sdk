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
}
