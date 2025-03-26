import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const EncryptDecrypt());
}

class EncryptDecrypt extends StatelessWidget {
  const EncryptDecrypt({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Encrypt & Decrypt',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: const EncryptionScreen(),
    );
  }
}

// Encryption Service Class
class EncryptOrDecryptService {
  static String encryptPassword(String text, String key) {
    if (text.isEmpty || key.length != 16) {
      return key.length != 16 ? 'Key must be 16 characters' : 'Text is empty';
    }
    try {
      final encryptionKey = encrypt.Key.fromUtf8(key);
      final iv = encrypt.IV.fromUtf8(key);
      final encrypter = encrypt.Encrypter(encrypt.AES(encryptionKey, mode: encrypt.AESMode.cbc));
      final encrypted = encrypter.encrypt(text, iv: iv);
      return encrypted.base64;
    } catch (e) {
      return 'Encryption failed: $e';
    }
  }

  static String decryptPassword(String encryptedText, String key) {
    if (encryptedText.isEmpty || key.length != 16) {
      return key.length != 16 ? 'Key must be 16 characters' : 'Text is empty';
    }
    try {
      final encryptionKey = encrypt.Key.fromUtf8(key);
      final iv = encrypt.IV.fromUtf8(key);
      final encrypter = encrypt.Encrypter(encrypt.AES(encryptionKey, mode: encrypt.AESMode.cbc));
      final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      return decrypted;
    } catch (e) {
      return 'Decryption failed: $e';
    }
  }
}

// UI Screen
class EncryptionScreen extends StatefulWidget {
  const EncryptionScreen({super.key});

  @override
  State<EncryptionScreen> createState() => _EncryptionScreenState();
}

class _EncryptionScreenState extends State<EncryptionScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  String _encryptedText = '';
  String _decryptedText = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _keyController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _encryptText() {
    final result = EncryptOrDecryptService.encryptPassword(
      _inputController.text,
      _keyController.text,
    );
    setState(() {
      if (result.contains('failed') || result.contains('must be') || result.isEmpty) {
        _showToast(result, isError: true);
        _encryptedText = '';
      } else {
        _encryptedText = result;
        _decryptedText = '';
        _animationController.forward(from: 0);
        _showToast('Encryption successful!');
      }
    });
  }

  void _decryptText() {
    final result = EncryptOrDecryptService.decryptPassword(
      _inputController.text,
      _keyController.text,
    );
    setState(() {
      if (result.contains('failed') || result.contains('must be') || result.isEmpty) {
        _showToast(result, isError: true);
        _decryptedText = '';
      } else {
        _decryptedText = result;
        _encryptedText = '';
        _animationController.forward(from: 0);
        _showToast('Decryption successful!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Vault'),
        elevation: 0,
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _inputController,
                        decoration: InputDecoration(
                          labelText: 'Enter your text',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.text_fields),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _keyController,
                        decoration: InputDecoration(
                          labelText: 'Enter 16-character key',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.vpn_key),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          counterText: '${_keyController.text.length}/16',
                        ),
                        maxLength: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _encryptText,
                    icon: const Icon(Icons.lock),
                    label: const Text('Encrypt'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _decryptText,
                    icon: const Icon(Icons.lock_open),
                    label: const Text('Decrypt'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_encryptedText.isNotEmpty || _decryptedText.isNotEmpty)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_encryptedText.isNotEmpty) ...[
                            const Text(
                              'Encrypted Text:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            SelectableText(
                              _encryptedText,
                              style: const TextStyle(color: Colors.teal, fontSize: 14),
                            ),
                          ],
                          if (_decryptedText.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            const Text(
                              'Decrypted Text:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            SelectableText(
                              _decryptedText,
                              style: const TextStyle(color: Colors.teal, fontSize: 14),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}