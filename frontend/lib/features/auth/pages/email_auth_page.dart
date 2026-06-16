import 'package:flutter/material.dart';
import 'package:frontend/core/auth/models/auth_session.dart';
import 'package:frontend/core/auth/services/auth_service.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/auth/pages/notification_permission_page.dart';
import 'package:frontend/features/navigation/pages/main_nav_page.dart';

class EmailAuthPage extends StatefulWidget {
  const EmailAuthPage({super.key});

  @override
  State<EmailAuthPage> createState() => _EmailAuthPageState();
}

class _EmailAuthPageState extends State<EmailAuthPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  bool _obscureRegisterConfirmPassword = true;
  String? _loginEmailError;
  String? _loginPasswordError;
  String? _loginGeneralError;
  String? _registerNameError;
  String? _registerEmailError;
  String? _registerPasswordError;
  String? _registerConfirmPasswordError;
  String? _registerGeneralError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final session = await AuthService.signInWithGoogle();
      if (!mounted) return;
      _goToHome(session);
    } on AuthException catch (error) {
      _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogin() async {
    _clearLoginErrors();
    if (!_loginFormKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final session = await AuthService.login(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text,
      );
      if (!mounted) return;
      _goToHome(session);
    } on AuthException catch (error) {
      _applyLoginErrors(error);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleRegister() async {
    _clearRegisterErrors();
    if (!_registerFormKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final session = await AuthService.register(
        name: _registerNameController.text.trim(),
        email: _registerEmailController.text.trim(),
        password: _registerPasswordController.text,
      );

      if (!mounted) return;

      await _showRegisterSuccessAlert();
      if (!mounted) return;

      if (await AuthService.shouldShowPermissionFlow(session)) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => NotificationPermissionPage(session: session),
          ),
          (route) => false,
        );
        return;
      }

      _goToHome(session);
    } on AuthException catch (error) {
      _applyRegisterErrors(error);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goToHome(AuthSession session) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => MainNavPage(
          isGuest: false,
          userEmail: session.user.email,
          userName: session.user.name,
        ),
      ),
      (route) => false,
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _clearLoginErrors() {
    setState(() {
      _loginEmailError = null;
      _loginPasswordError = null;
      _loginGeneralError = null;
    });
  }

  void _clearRegisterErrors() {
    setState(() {
      _registerNameError = null;
      _registerEmailError = null;
      _registerPasswordError = null;
      _registerConfirmPasswordError = null;
      _registerGeneralError = null;
    });
  }

  void _applyLoginErrors(AuthException error) {
    setState(() {
      _loginEmailError = error.fieldErrors['email'];
      _loginPasswordError = error.fieldErrors['password'];
      _loginGeneralError = error.fieldErrors.isEmpty ? error.message : null;
    });

    if (_loginGeneralError != null) {
      _showMessage(_loginGeneralError!);
    }
  }

  void _applyRegisterErrors(AuthException error) {
    setState(() {
      _registerNameError = error.fieldErrors['name'];
      _registerEmailError = error.fieldErrors['email'];
      _registerPasswordError = error.fieldErrors['password'];
      _registerConfirmPasswordError = error.fieldErrors['confirm_password'];
      _registerGeneralError = error.fieldErrors.isEmpty ? error.message : null;
    });

    if (_registerGeneralError != null) {
      _showMessage(_registerGeneralError!);
    }
  }

  Future<void> _showRegisterSuccessAlert() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Account Created',
            style: TextStyle(
              color: AppColors.darkBlue,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Your account has been created successfully.',
            style: TextStyle(
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryEnd,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVeryLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgVeryLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Continue with Email',
          style: TextStyle(
            color: AppColors.darkBlue,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryEnd,
          labelColor: AppColors.primaryEnd,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(text: 'Login'),
            Tab(text: 'Register'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AuthFormShell(
            child: Form(
              key: _loginFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _HeaderText(
                    title: 'Welcome back',
                    subtitle: 'Sign in with your BookyGo email and password.',
                  ),
                  const SizedBox(height: 24),
                  _AuthInput(
                    controller: _loginEmailController,
                    label: 'Email',
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    forceErrorText: _loginEmailError,
                    onChanged: (_) {
                      if (_loginEmailError != null || _loginGeneralError != null) {
                        setState(() {
                          _loginEmailError = null;
                          _loginGeneralError = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _AuthInput(
                    controller: _loginPasswordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    obscureText: _obscureLoginPassword,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureLoginPassword = !_obscureLoginPassword;
                        });
                      },
                      icon: Icon(
                        _obscureLoginPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                    validator: _validatePassword,
                    forceErrorText: _loginPasswordError,
                    onChanged: (_) {
                      if (_loginPasswordError != null ||
                          _loginGeneralError != null) {
                        setState(() {
                          _loginPasswordError = null;
                          _loginGeneralError = null;
                        });
                      }
                    },
                  ),
                  if (_loginGeneralError != null) ...[
                    const SizedBox(height: 10),
                    _InlineError(message: _loginGeneralError!),
                  ],
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        _showMessage(
                          'Forgot password is not available yet in this app.',
                        );
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _PrimaryButton(
                    text: _isLoading ? 'Loading...' : 'Login',
                    onPressed: _isLoading ? null : _handleLogin,
                  ),

                  const SizedBox(height: 16),
                  const _DividerOr(),
                  const SizedBox(height: 16),
                  _GoogleButton(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                  ),
                ],
              ),
            ),
          ),
          _AuthFormShell(
            child: Form(
              key: _registerFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _HeaderText(
                    title: 'Create your account',
                    subtitle:
                        'Enter your full name, email, password, and confirm password first.',
                  ),
                  const SizedBox(height: 24),
                  _AuthInput(
                    controller: _registerNameController,
                    label: 'Full Name',
                    hint: 'Your full name',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Full name is required.';
                      }
                      return null;
                    },
                    forceErrorText: _registerNameError,
                    onChanged: (_) {
                      if (_registerNameError != null ||
                          _registerGeneralError != null) {
                        setState(() {
                          _registerNameError = null;
                          _registerGeneralError = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _AuthInput(
                    controller: _registerEmailController,
                    label: 'Email',
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    forceErrorText: _registerEmailError,
                    onChanged: (_) {
                      if (_registerEmailError != null ||
                          _registerGeneralError != null) {
                        setState(() {
                          _registerEmailError = null;
                          _registerGeneralError = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _AuthInput(
                    controller: _registerPasswordController,
                    label: 'Password',
                    hint: 'Minimum 6 characters',
                    obscureText: _obscureRegisterPassword,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureRegisterPassword = !_obscureRegisterPassword;
                        });
                      },
                      icon: Icon(
                        _obscureRegisterPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                    validator: _validatePassword,
                    forceErrorText: _registerPasswordError,
                    onChanged: (_) {
                      if (_registerPasswordError != null ||
                          _registerGeneralError != null) {
                        setState(() {
                          _registerPasswordError = null;
                          _registerGeneralError = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _AuthInput(
                    controller: _registerConfirmPasswordController,
                    label: 'Confirm Password',
                    hint: 'Repeat your password',
                    obscureText: _obscureRegisterConfirmPassword,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureRegisterConfirmPassword =
                              !_obscureRegisterConfirmPassword;
                        });
                      },
                      icon: Icon(
                        _obscureRegisterConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                    validator: (value) {
                      final passwordError = _validatePassword(value);
                      if (passwordError != null) {
                        return passwordError;
                      }
                      if (value != _registerPasswordController.text) {
                        return 'Passwords do not match.';
                      }
                      return null;
                    },
                    forceErrorText: _registerConfirmPasswordError,
                    onChanged: (_) {
                      if (_registerConfirmPasswordError != null ||
                          _registerGeneralError != null) {
                        setState(() {
                          _registerConfirmPasswordError = null;
                          _registerGeneralError = null;
                        });
                      }
                    },
                  ),
                  if (_registerGeneralError != null) ...[
                    const SizedBox(height: 10),
                    _InlineError(message: _registerGeneralError!),
                  ],
                  const SizedBox(height: 24),
                  _PrimaryButton(
                    text: _isLoading ? 'Loading...' : 'Create Account',
                    onPressed: _isLoading ? null : _handleRegister,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }

    final email = value.trim();
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }
}

class _AuthFormShell extends StatelessWidget {
  const _AuthFormShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: child,
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.darkBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _AuthInput extends StatelessWidget {
  const _AuthInput({
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.forceErrorText,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? forceErrorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.mutedBlue,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            errorText: forceErrorText,
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.blueLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.blueLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.primaryEnd,
                width: 1.6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: Colors.redAccent,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryEnd,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.blueLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _DividerOr extends StatelessWidget {
  const _DividerOr();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: Divider(color: AppColors.blueLight)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.blueLight)),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Image.asset(
          'assets/images/Google_G_Logo.png',
          height: 24,
          width: 24,
        ),
        label: const Text(
          'Continue with Google',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.darkBlue,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.blueLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}