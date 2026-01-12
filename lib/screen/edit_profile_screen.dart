import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = true;
  bool hidePassword = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// 🔹 Fetch existing user data
  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    emailController.text = user.email ?? '';

    try {
      final doc =
      await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        displayNameController.text = data['displayName'] ?? '';
        phoneController.text = data['phone'] ?? '';
      }
    } catch (e) {
      debugPrint('Failed to load profile: $e');
    }

    setState(() => isLoading = false);
  }

  /// 🔹 Save updated profile
  Future<void> _saveChanges() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      setState(() => isLoading = true);

      // Update password (optional)
      if (passwordController.text.isNotEmpty) {
        await user.updatePassword(passwordController.text.trim());
      }

      // Update display name in FirebaseAuth
      await user.updateDisplayName(displayNameController.text.trim());

      // Update Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'displayName': displayNameController.text.trim(),
        'phone': phoneController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7ED),
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body:
      isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            /// Avatar
            Stack(
              children: [
                const CircleAvatar(
                  radius: 48,
                  backgroundColor: Color(0xFFE5E7EB),
                  child: Icon(Icons.person, size: 40),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFFFF6900),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            /// Email (READ ONLY)
            TextField(
              controller: emailController,
              enabled: false,
              decoration: _inputDecoration('Email'),
            ),

            const SizedBox(height: 16),

            /// Display Name
            TextField(
              controller: displayNameController,
              decoration: _inputDecoration('Display Name'),
            ),

            const SizedBox(height: 16),

            /// Mobile Number
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('Mobile Number'),
            ),

            const SizedBox(height: 16),

            /// Password
            TextField(
              controller: passwordController,
              obscureText: hidePassword,
              decoration: _inputDecoration('New Password (optional)')
                  .copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    hidePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(
                          () => hidePassword = !hidePassword,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 32),

            /// Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6900),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
