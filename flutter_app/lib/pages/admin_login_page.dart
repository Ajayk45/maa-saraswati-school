import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  // API SERVICE
  final ApiService _api = ApiService();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  // ==========================================================
  // LOGIN
  // ==========================================================

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty) {
      showMessage('Username bharein');
      return;
    }

    if (password.isEmpty) {
      showMessage('Password bharein');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // ApiService login karega
      // aur JWT token automatically save karega.
      await _api.adminLogin(
        username,
        password,
      );

      if (!mounted) return;

      showMessage(
        'Admin login successful',
        success: true,
      );

      // Dashboard
      Navigator.pushReplacementNamed(
        context,
        '/admin-dashboard',
      );
    } catch (error) {
      if (!mounted) return;

      showMessage(
        error
            .toString()
            .replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void showMessage(
    String message, {
    bool success = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            success ? Colors.green : Colors.red,
      ),
    );
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ==========================================================
  // UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f7fb),

      appBar: AppBar(
        title: const Text(
          'Admin Login',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xff1565c0),
        foregroundColor: Colors.white,
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 430,
            ),

            child: Card(
              elevation: 8,

              child: Padding(
                padding: const EdgeInsets.all(28),

                child: Column(
                  children: [
                    // LOGO
                    Image.asset(
                      'assets/logo.png',
                      width: 90,
                      height: 100,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'School Admin Panel',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Login to manage school information',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // USERNAME
                    TextField(
                      controller: usernameController,
                      textInputAction:
                          TextInputAction.next,
                      decoration:
                          const InputDecoration(
                        labelText: 'Username',
                        hintText:
                            'Enter admin username',
                        prefixIcon:
                            Icon(Icons.person),
                        border:
                            OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // PASSWORD
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      textInputAction:
                          TextInputAction.done,

                      onSubmitted: (_) {
                        if (!isLoading) {
                          login();
                        }
                      },

                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText:
                            'Enter admin password',
                        prefixIcon:
                            const Icon(Icons.lock),

                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword =
                                  !obscurePassword;
                            });
                          },
                        ),

                        border:
                            const OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // LOGIN BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,

                      child: ElevatedButton(
                        onPressed:
                            isLoading ? null : login,

                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xff1565c0),
                          foregroundColor:
                              Colors.white,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                        ),

                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      Colors.white,
                                ),
                              )
                            : const Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}