class CryptoState {
  final String? encryptedText;
  final String? decryptedText;
  final String? doubleEncryptedText; // New field for double encryption
  final String? doubleDecryptedText; // New field for double decryption
  final String? errorMessage;
  final bool isLoading;

  CryptoState({
    this.encryptedText,
    this.decryptedText,
    this.doubleEncryptedText,
    this.doubleDecryptedText,
    this.errorMessage,
    this.isLoading = false,
  });

  factory CryptoState.initial() => CryptoState();
  factory CryptoState.loading() => CryptoState(isLoading: true);
  factory CryptoState.success({
    String? encrypted,
    String? decrypted,
    String? doubleEncrypted,
    String? doubleDecrypted,
  }) =>
      CryptoState(
        encryptedText: encrypted,
        decryptedText: decrypted,
        doubleEncryptedText: doubleEncrypted,
        doubleDecryptedText: doubleDecrypted,
      );
  factory CryptoState.error(String message) => CryptoState(errorMessage: message);

  CryptoState copyWith({
    String? encryptedText,
    String? decryptedText,
    String? doubleEncryptedText,
    String? doubleDecryptedText,
    String? errorMessage,
    bool? isLoading,
  }) {
    return CryptoState(
      encryptedText: encryptedText ?? this.encryptedText,
      decryptedText: decryptedText ?? this.decryptedText,
      doubleEncryptedText: doubleEncryptedText ?? this.doubleEncryptedText,
      doubleDecryptedText: doubleDecryptedText ?? this.doubleDecryptedText,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}