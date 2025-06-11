import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_boost/core/widgets/admin_custom_bottom_nav_bar.dart';
import 'package:skill_boost/core/widgets/custom_button.dart';
import 'package:skill_boost/features/auth/domain/entities/user_entity.dart';
import 'package:skill_boost/features/auth/presentation/providers/auth_provider.dart';
import 'package:skill_boost/features/auth/presentation/providers/auth_state.dart';
import 'package:skill_boost/features/auth/presentation/providers/auth_event.dart';

class AdminEditProfilePage extends ConsumerStatefulWidget {
  const AdminEditProfilePage({super.key});

  @override
  ConsumerState<AdminEditProfilePage> createState() => _AdminEditProfilePageState();
}

class _AdminEditProfilePageState extends ConsumerState<AdminEditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  bool isPasswordChanged = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final UserEntity user = ModalRoute.of(context)!.settings.arguments as UserEntity;

    nameController = TextEditingController(text: user.name);
    emailController = TextEditingController(text: user.email);
    usernameController = TextEditingController(text: '@${user.name}');
    passwordController = TextEditingController(text: '••••••••');

    passwordController.addListener(() {
      if (passwordController.text != '••••••••') {
        setState(() {
          isPasswordChanged = true;
        });
      } else {
        setState(() {
          isPasswordChanged = false;
        });
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleSaveChanges() {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    if (isPasswordChanged && passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters long')),
      );
      return;
    }

    ref.read(authProvider.notifier).mapEventToState(
          EditUserEvent(
            nameController.text,
            isPasswordChanged ? passwordController.text : '',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }

      if (next.editSuccess && next.editSuccess != previous?.editSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        ref.read(authProvider.notifier).mapEventToState(ResetEditSuccessEvent());
        Navigator.pop(context); // Go back after success
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      bottomNavigationBar: const AdminCustomBottomNavBar(currentIndex: 2),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: CircleAvatar(
                      radius: 75,
                      backgroundImage: NetworkImage(
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRBwgu1A5zgPSvfE83nurkuzNEoXs9DMNr8Ww&s',
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildFieldLabel('Name'),
                  const SizedBox(height: 8),
                  _buildTextField(controller: nameController, hintText: 'Enter your name'),
                  const SizedBox(height: 20),
                  _buildFieldLabel('Email'),
                  const SizedBox(height: 8),
                  _buildTextField(controller: emailController, hintText: 'Your email', enabled: false),
                  const SizedBox(height: 20),
                  _buildFieldLabel('Username'),
                  const SizedBox(height: 8),
                  _buildTextField(controller: usernameController, hintText: 'Your username'),
                  const SizedBox(height: 20),
                  _buildFieldLabel('Password'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: passwordController,
                    hintText: 'Enter new password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: CustomButton(
                      onTap: authState.isLoading ? null : _handleSaveChanges,
                      label: authState.isLoading ? 'Saving...' : 'Save changes',
                      textColor: Colors.white,
                      backgroundColor: const Color(0xFF884FD0),
                      width: 150,
                      height: 41,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (authState.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hintText,
    bool enabled = true,
    bool obscureText = false,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFEEE7F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              obscureText: obscureText,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: enabled ? Colors.black : Colors.grey,
                height: 1.0,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: const Color(0xFF605D5D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}