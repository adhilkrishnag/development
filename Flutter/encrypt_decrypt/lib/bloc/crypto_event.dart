abstract class CryptoEvent {}

class EncryptTextEvent extends CryptoEvent {
  final String text;
  final String key;

  EncryptTextEvent(this.text, this.key);
}

class DecryptTextEvent extends CryptoEvent {
  final String text;
  final String key;

  DecryptTextEvent(this.text, this.key);
}

class DoubleEncryptTextEvent extends CryptoEvent {
  final String text;
  final String key;

  DoubleEncryptTextEvent(this.text, this.key);
}

class DoubleDecryptTextEvent extends CryptoEvent {
  final String text;
  final String key;

  DoubleDecryptTextEvent(this.text, this.key);
}