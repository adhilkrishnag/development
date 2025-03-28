import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'bloc/crypto_bloc.dart';
import 'bloc/crypto_event.dart';
import 'bloc/crypto_state.dart';

void main() {
  runApp(const EncryptDecrypt());
}

class EncryptDecrypt extends StatelessWidget {
  const EncryptDecrypt({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Vault',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: BlocProvider(
        create: (_) => CryptoBloc(),
        child: const EncryptionScreen(),
      ),
    );
  }
}

class EncryptionScreen extends StatefulWidget {
  const EncryptionScreen({super.key});

  @override
  State<EncryptionScreen> createState() => _EncryptionScreenState();
}

class _EncryptionScreenState extends State<EncryptionScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
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
    // Add listener to update UI on key input changes
    _keyController.addListener(() {
      setState(() {}); // Rebuild to update counterText
    });
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

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showToast('Copied to clipboard!');
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _inputController,
                            decoration: InputDecoration(
                              labelText: 'Enter text to encrypt/decrypt',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.text_fields),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                            ),
                            maxLines: 3,
                            minLines: 1,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _keyController,
                            decoration: InputDecoration(
                              labelText: 'Enter 16-character key',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.vpn_key),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              counterText:
                                  '${_keyController.text.length}/16', // Updates in real-time
                            ),
                            maxLength: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16.0,
                    runSpacing: 16.0,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<CryptoBloc>().add(
                            EncryptTextEvent(
                              _inputController.text,
                              _keyController.text,
                            ),
                          );
                        },
                        icon: const Icon(Icons.lock, size: 20),
                        label: const Text('Encrypt'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<CryptoBloc>().add(
                            DecryptTextEvent(
                              _inputController.text,
                              _keyController.text,
                            ),
                          );
                        },
                        icon: const Icon(Icons.lock_open, size: 20),
                        label: const Text('Decrypt'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<CryptoBloc>().add(
                            DoubleEncryptTextEvent(
                              _inputController.text,
                              _keyController.text,
                            ),
                          );
                        },
                        icon: const Icon(Icons.lock, size: 20),
                        label: const Text('Double Encrypt'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<CryptoBloc>().add(
                            DoubleDecryptTextEvent(
                              _inputController.text,
                              _keyController.text,
                            ),
                          );
                        },
                        icon: const Icon(Icons.lock_open, size: 20),
                        label: const Text('Double Decrypt'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  BlocConsumer<CryptoBloc, CryptoState>(
                    listener: (context, state) {
                      if (state.errorMessage != null) {
                        _showToast(state.errorMessage!, isError: true);
                      } else if (state.encryptedText != null ||
                          state.decryptedText != null ||
                          state.doubleEncryptedText != null ||
                          state.doubleDecryptedText != null) {
                        _showToast(
                          state.encryptedText != null
                              ? 'Encryption successful!'
                              : state.decryptedText != null
                              ? 'Decryption successful!'
                              : state.doubleEncryptedText != null
                              ? 'Double encryption successful!'
                              : 'Double decryption successful!',
                        );
                        _animationController.forward(from: 0);
                      }
                    },
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state.encryptedText != null ||
                          state.decryptedText != null ||
                          state.doubleEncryptedText != null ||
                          state.doubleDecryptedText != null) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (state.encryptedText != null) ...[
                                    const Text(
                                      'Encrypted Text:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SelectableText(
                                            state.encryptedText!,
                                            style: const TextStyle(
                                              color: Colors.teal,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.copy,
                                            color: Colors.teal,
                                          ),
                                          onPressed:
                                              () => _copyToClipboard(
                                                state.encryptedText!,
                                              ),
                                          tooltip: 'Copy to clipboard',
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (state.decryptedText != null) ...[
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Decrypted Text:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SelectableText(
                                            state.decryptedText!,
                                            style: const TextStyle(
                                              color: Colors.teal,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.copy,
                                            color: Colors.teal,
                                          ),
                                          onPressed:
                                              () => _copyToClipboard(
                                                state.decryptedText!,
                                              ),
                                          tooltip: 'Copy to clipboard',
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (state.doubleEncryptedText != null) ...[
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Double Encrypted Text:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SelectableText(
                                            state.doubleEncryptedText!,
                                            style: const TextStyle(
                                              color: Colors.teal,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.copy,
                                            color: Colors.teal,
                                          ),
                                          onPressed:
                                              () => _copyToClipboard(
                                                state.doubleEncryptedText!,
                                              ),
                                          tooltip: 'Copy to clipboard',
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (state.doubleDecryptedText != null) ...[
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Double Decrypted Text:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SelectableText(
                                            state.doubleDecryptedText!,
                                            style: const TextStyle(
                                              color: Colors.teal,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.copy,
                                            color: Colors.teal,
                                          ),
                                          onPressed:
                                              () => _copyToClipboard(
                                                state.doubleDecryptedText!,
                                              ),
                                          tooltip: 'Copy to clipboard',
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
