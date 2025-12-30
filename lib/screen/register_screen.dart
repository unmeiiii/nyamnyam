import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 🔐 Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 📝 Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool agreeTerms = true;
  bool _showAgreeError = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isLoading = false;

  // For live validation control
  bool _submitted = false;
  bool _firstTouched = false;
  bool _lastTouched = false;
  bool _displayTouched = false;
  bool _emailTouched = false;
  bool _phoneTouched = false;
  bool _passwordTouched = false;
  bool _confirmTouched = false;

  late FocusNode _firstNameFocus;
  late FocusNode _lastNameFocus;
  late FocusNode _displayFocus;
  late FocusNode _emailFocus;
  late FocusNode _phoneFocus;
  late FocusNode _passwordFocus;
  late FocusNode _confirmFocus;

  // ✅ UniKL email validation
  bool isValidUniKLEmail(String email) {
    return email.endsWith('@unikl.edu.my') || email.endsWith('@s.unikl.edu.my');
  }

  @override
  void initState() {
    super.initState();

    _firstNameFocus =
        FocusNode()..addListener(() {
          if (_firstNameFocus.hasFocus) {
            setState(() {
              _firstTouched = true;
            });
            _formKey.currentState?.validate();
          }
        });

    _lastNameFocus =
        FocusNode()..addListener(() {
          if (_lastNameFocus.hasFocus) {
            setState(() => _lastTouched = true);
            _formKey.currentState?.validate();
          }
        });

    _displayFocus =
        FocusNode()..addListener(() {
          if (_displayFocus.hasFocus) {
            setState(() => _displayTouched = true);
            _formKey.currentState?.validate();
          }
        });

    _emailFocus =
        FocusNode()..addListener(() {
          if (_emailFocus.hasFocus) {
            setState(() => _emailTouched = true);
            _formKey.currentState?.validate();
          }
        });

    _phoneFocus =
        FocusNode()..addListener(() {
          if (_phoneFocus.hasFocus) {
            setState(() => _phoneTouched = true);
            _formKey.currentState?.validate();
          }
        });

    _passwordFocus =
        FocusNode()..addListener(() {
          if (_passwordFocus.hasFocus) {
            setState(() => _passwordTouched = true);
            _formKey.currentState?.validate();
          }
        });

    _confirmFocus =
        FocusNode()..addListener(() {
          if (_confirmFocus.hasFocus) {
            setState(() => _confirmTouched = true);
            _formKey.currentState?.validate();
          }
        });
  }

  @override
  void dispose() {
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _displayFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();

    firstNameController.dispose();
    lastNameController.dispose();
    displayNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  // 🔘 REGISTER FUNCTION
  Future<void> registerUser() async {
    // Reset agree error first and mark form submitted to show all errors
    setState(() {
      _showAgreeError = false;
      _submitted = true;
    });

    // Validate form fields first
    if (!_formKey.currentState!.validate()) return;

    if (!agreeTerms) {
      setState(() => _showAgreeError = true);
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      setState(() => isLoading = true);

      // 🔐 Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;

      // 🗂 Firestore
      await _firestore.collection('users').doc(uid).set({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'displayName': displayNameController.text.trim(),
        'email': email,
        'phone': phoneController.text.trim(),
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ➡️ Go to Login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Registration failed')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF9810FA)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          /// HEADER
          Container(
            height: 220,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFED7AA), Color(0xFFFDBA74)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const CircleAvatar(
                    radius: 55,
                    backgroundColor: Color(0xFFE5E7EB),
                    child: Icon(Icons.person, size: 60),
                  ),
                ],
              ),
            ),
          ),

          /// FORM
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Center(
                            child: Text(
                              "Login",
                              style: TextStyle(color: Color(0xFFFFB86A)),
                            ),
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Column(
                          children: [
                            Text(
                              "Register",
                              style: TextStyle(color: Color(0xFF9810FA)),
                            ),
                            Divider(thickness: 2, color: Color(0xFF9810FA)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                focusNode: _firstNameFocus,
                                controller: firstNameController,
                                decoration: _inputDecoration(
                                  hint: 'First Name',
                                  icon: Icons.person_outline,
                                ),
                                onChanged:
                                    (_) => _formKey.currentState?.validate(),
                                validator: (v) {
                                  if (!_firstTouched && !_submitted)
                                    return null;
                                  if (v == null || v.trim().isEmpty) {
                                    return 'First name is required';
                                  }
                                  final letters =
                                      RegExp(r'[A-Za-z]').allMatches(v).length;
                                  if (letters < 2) {
                                    return 'First name must be at least 2 letters';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                focusNode: _lastNameFocus,
                                controller: lastNameController,
                                decoration: _inputDecoration(
                                  hint: 'Last Name',
                                  icon: Icons.person_outline,
                                ),
                                onChanged:
                                    (_) => _formKey.currentState?.validate(),
                                validator: (v) {
                                  if (!_lastTouched && !_submitted) return null;
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Last name is required';
                                  }
                                  final letters =
                                      RegExp(r'[A-Za-z]').allMatches(v).length;
                                  if (letters < 2) {
                                    return 'Last name must be at least 2 letters';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          focusNode: _displayFocus,
                          controller: displayNameController,
                          decoration: _inputDecoration(
                            hint: 'Display Name',
                            icon: Icons.badge_outlined,
                          ),
                          onChanged: (_) => _formKey.currentState?.validate(),
                          validator: (v) {
                            if (!_displayTouched && !_submitted) return null;
                            if (v == null || v.trim().isEmpty) {
                              return 'Display name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          focusNode: _emailFocus,
                          controller: emailController,
                          decoration: _inputDecoration(
                            hint: 'UniKL Email',
                            icon: Icons.email_outlined,
                          ),
                          onChanged: (_) => _formKey.currentState?.validate(),
                          validator: (v) {
                            if (!_emailTouched && !_submitted) return null;
                            if (v == null || v.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!isValidUniKLEmail(v.trim())) {
                              return 'Use UniKL email only (@unikl.edu.my or @s.unikl.edu.my)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          focusNode: _phoneFocus,
                          controller: phoneController,
                          decoration: _inputDecoration(
                            hint: 'Mobile',
                            icon: Icons.phone_outlined,
                          ),
                          keyboardType: TextInputType.phone,
                          onChanged: (_) => _formKey.currentState?.validate(),
                          validator: (v) {
                            if (!_phoneTouched && !_submitted) return null;
                            if (v == null || v.trim().isEmpty) {
                              return 'Mobile is required';
                            }

                            if (!RegExp(r'^\d+$').hasMatch(v.trim())) {
                              return 'Mobile must contain digits only';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          focusNode: _passwordFocus,
                          controller: passwordController,
                          obscureText: hidePassword,
                          decoration: _inputDecoration(
                            hint: 'Password',
                            icon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                hidePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() => hidePassword = !hidePassword);
                              },
                            ),
                          ),
                          onChanged: (_) => _formKey.currentState?.validate(),
                          validator: (v) {
                            if (!_passwordTouched && !_submitted) return null;
                            if (v == null || v.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            if (!RegExp(r'[^A-Za-z0-9]').hasMatch(v)) {
                              return 'Password must include at least one special character';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          focusNode: _confirmFocus,
                          controller: confirmPasswordController,
                          obscureText: hideConfirmPassword,
                          decoration: _inputDecoration(
                            hint: 'Confirm Password',
                            icon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                hideConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(
                                  () =>
                                      hideConfirmPassword =
                                          !hideConfirmPassword,
                                );
                              },
                            ),
                          ),
                          onChanged: (_) => _formKey.currentState?.validate(),
                          validator: (v) {
                            if (!_confirmTouched && !_submitted) return null;
                            if (v == null || v.isEmpty) {
                              return 'Confirm your password';
                            }
                            if (v != passwordController.text) {
                              return 'Password does not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Checkbox(
                              value: agreeTerms,
                              onChanged: (v) {
                                setState(() {
                                  agreeTerms = v ?? false;
                                  _showAgreeError = !agreeTerms;
                                });
                              },
                            ),
                            const Expanded(
                              child: Text(
                                'I agree to the Terms & Conditions and Privacy Policy',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        if (_showAgreeError)
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 8.0, top: 4.0),
                              child: Text(
                                'You must agree before registering',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : registerUser,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child:
                          isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'Register',
                                style: TextStyle(color: Colors.white),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
