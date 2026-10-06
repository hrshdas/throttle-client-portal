import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

class AcceptInvitationScreen extends StatefulWidget {
  final String token;

  const AcceptInvitationScreen({super.key, required this.token});

  @override
  State<AcceptInvitationScreen> createState() => _AcceptInvitationScreenState();
}

class _AcceptInvitationScreenState extends State<AcceptInvitationScreen> {
  bool _isLoadingDetails = true;
  String? _detailsError;
  Map<String, dynamic>? _invitationDetails;

  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loadDetails() async {
    try {
      final details = await AuthService.getInvitationDetails(widget.token);
      setState(() {
        _invitationDetails = details;
        if (details['name'] != null) {
          _nameController.text = details['name'];
        }
        _isLoadingDetails = false;
      });
    } catch (e) {
      setState(() {
        _detailsError = e.toString();
        _isLoadingDetails = false;
      });
    }
  }

  void _handleAccept() async {
    if (_nameController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in your name and password'),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.acceptInvitation(
      token: widget.token,
      name: _nameController.text.trim(),
      password: _passwordController.text,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Failed to accept invitation'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (_isLoadingDetails) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F2F7),
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    if (_detailsError != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF2F2F7),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(28),
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Invalid Invitation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(_detailsError!, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
    }

    final orgName = _invitationDetails?['organization_name'] ?? 'Throttle Workspace';
    final email = _invitationDetails?['email'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(28.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFE4E4E8), width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Join $orgName',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'You\'ve been invited as $email',
                    style: TextStyle(fontSize: 14, color: AppTheme.secondaryText),
                  ),
                  const SizedBox(height: 24),

                  // Name Field
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outline, size: 20, color: Colors.black45),
                      filled: true,
                      fillColor: const Color(0xFFF7F7F9),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'Set Account Password',
                      prefixIcon: const Icon(Icons.lock_outline, size: 20, color: Colors.black45),
                      filled: true,
                      fillColor: const Color(0xFFF7F7F9),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _handleAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Accept & Create Account',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
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
