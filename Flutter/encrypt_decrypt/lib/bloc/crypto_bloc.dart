import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'crypto_event.dart';
import 'crypto_state.dart';

class CryptoBloc extends Bloc<CryptoEvent, CryptoState> {
  CryptoBloc() : super(CryptoState.initial()) {
    on<EncryptTextEvent>(_onEncryptText);
    on<DecryptTextEvent>(_onDecryptText);
    on<DoubleEncryptTextEvent>(_onDoubleEncryptText);
    on<DoubleDecryptTextEvent>(_onDoubleDecryptText);
  }

  Future<void> _onEncryptText(EncryptTextEvent event, Emitter<CryptoState> emit) async {
    emit(CryptoState.loading());
    if (event.text.isEmpty || event.key.length != 16) {
      emit(CryptoState.error(event.key.length != 16 ? 'Key must be 16 characters' : 'Text is empty'));
      return;
    }
    try {
      final key = encrypt.Key.fromUtf8(event.key);
      final iv = encrypt.IV.fromUtf8(event.key);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      final encrypted = encrypter.encrypt(event.text, iv: iv);
      emit(CryptoState.success(encrypted: encrypted.base64));
    } catch (e) {
      emit(CryptoState.error('Encryption failed: $e'));
    }
  }

  Future<void> _onDecryptText(DecryptTextEvent event, Emitter<CryptoState> emit) async {
    emit(CryptoState.loading());
    if (event.text.isEmpty || event.key.length != 16) {
      emit(CryptoState.error(event.key.length != 16 ? 'Key must be 16 characters' : 'Text is empty'));
      return;
    }
    try {
      final key = encrypt.Key.fromUtf8(event.key);
      final iv = encrypt.IV.fromUtf8(event.key);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      final encrypted = encrypt.Encrypted.fromBase64(event.text);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      emit(CryptoState.success(decrypted: decrypted));
    } catch (e) {
      emit(CryptoState.error('Decryption failed: $e'));
    }
  }

  Future<void> _onDoubleEncryptText(DoubleEncryptTextEvent event, Emitter<CryptoState> emit) async {
    emit(CryptoState.loading());
    if (event.text.isEmpty || event.key.length != 16) {
      emit(CryptoState.error(event.key.length != 16 ? 'Key must be 16 characters' : 'Text is empty'));
      return;
    }
    try {
      final key = encrypt.Key.fromUtf8(event.key);
      final iv = encrypt.IV.fromUtf8(event.key);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      // First encryption
      final firstEncrypted = encrypter.encrypt(event.text, iv: iv);
      // Second encryption on the first result
      final doubleEncrypted = encrypter.encrypt(firstEncrypted.base64, iv: iv);
      emit(CryptoState.success(doubleEncrypted: doubleEncrypted.base64));
    } catch (e) {
      emit(CryptoState.error('Double encryption failed: $e'));
    }
  }

  Future<void> _onDoubleDecryptText(DoubleDecryptTextEvent event, Emitter<CryptoState> emit) async {
    emit(CryptoState.loading());
    if (event.text.isEmpty || event.key.length != 16) {
      emit(CryptoState.error(event.key.length != 16 ? 'Key must be 16 characters' : 'Text is empty'));
      return;
    }
    try {
      final key = encrypt.Key.fromUtf8(event.key);
      final iv = encrypt.IV.fromUtf8(event.key);
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      // First decryption
      final firstDecrypted = encrypter.decrypt(encrypt.Encrypted.fromBase64(event.text), iv: iv);
      // Second decryption on the first result
      final doubleDecrypted = encrypter.decrypt(encrypt.Encrypted.fromBase64(firstDecrypted), iv: iv);
      emit(CryptoState.success(doubleDecrypted: doubleDecrypted));
    } catch (e) {
      emit(CryptoState.error('Double decryption failed: $e'));
    }
  }
}