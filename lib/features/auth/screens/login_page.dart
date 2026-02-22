import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/core/utils/responsive.dart';
import 'package:smart_home_ai/features/auth/providers/auth_provider.dart';
import 'package:smart_home_ai/features/home/screens/web_shell.dart';
import 'package:smart_home_ai/features/home/screens/mobile_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _obscure = true;
  bool _remember = false;
  late AnimationController _anim;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isLogin = !_isLogin);
    _anim.reset();
    _anim.forward();
  }

  void _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();
    bool ok;
    if (_isLogin) {
      ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text.trim());
    } else {
      ok = await auth.register(
          _nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text.trim());
    }
    if (ok && mounted) _goHome();
  }

  void _demo() {
    context.read<AuthProvider>().demoLogin();
    _goHome();
  }

  void _goHome() {
    final isDesktop = Responsive.isDesktop(context);
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            isDesktop ? const WebShell() : const MobileShell(),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final isMobile = Responsive.isMobile(context);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: isDesktop
            ? _buildDesktopLayout(auth)
            : _buildMobileLayout(auth, isMobile),
      ),
    );
  }

  // ================ DESKTOP: side-by-side ================
  Widget _buildDesktopLayout(AuthProvider auth) {
    return Row(
      children: [
        // Left panel — branding
        Expanded(
          flex: 5,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF12164A), Color(0xFF0E1230)],
              ),
            ),
            child: Stack(
              children: [
                // Glows
                Positioned(
                  left: -80, top: -80,
                  child: _glow(AppTheme.primaryColor, 350),
                ),
                Positioned(
                  right: -60, bottom: 60,
                  child: _glow(AppTheme.secondaryColor, 250),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.home_rounded,
                                  color: Colors.white, size: 26),
                            ),
                            const SizedBox(width: 14),
                            const Text('SmartHome AI',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          'Control Your\nEntire Home\nWith Intelligence',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                            letterSpacing: -1.2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 380,
                          child: const Text(
                            'AI-powered automation, 50+ device types, '
                            'real-time analytics, and enterprise-grade security '
                            '— all in one elegant platform.',
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: 15,
                                height: 1.6),
                          ),
                        ),
                        const SizedBox(height: 36),
                        // Feature pills
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _pill(Icons.bolt, '150+ Features'),
                            _pill(Icons.devices, '50+ Devices'),
                            _pill(Icons.shield, 'Encrypted'),
                          ],
                        ),
                        const SizedBox(height: 48),
                        // Social proof
                        Row(
                          children: [
                            // Avatars
                            SizedBox(
                              width: 88,
                              height: 32,
                              child: Stack(
                                children: List.generate(3, (i) {
                                  final colors = [
                                    AppTheme.primaryColor,
                                    AppTheme.secondaryColor,
                                    AppTheme.successColor,
                                  ];
                                  return Positioned(
                                    left: i * 24.0,
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: colors[i],
                                      child: Text(
                                        ['J', 'S', 'M'][i],
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '10K+ homeowners trust SmartHome AI',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right panel — form
        Expanded(
          flex: 4,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _buildForm(auth, false),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================ MOBILE: stacked ================
  Widget _buildMobileLayout(AuthProvider auth, bool isMobile) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 48,
          vertical: 20,
        ),
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: isMobile ? 32 : 48),
              // Logo
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.home_rounded,
                    size: 36, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text('SmartHome AI',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Your intelligent home awaits',
                  style: TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 40),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: _buildForm(auth, true),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ================ SHARED FORM ================
  Widget _buildForm(AuthProvider auth, bool isMobile) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isLogin ? 'Welcome back' : 'Create account',
            style: const TextStyle(
                color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            _isLogin
                ? 'Sign in to manage your smart home'
                : 'Start your smart home journey',
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 32),
          // Name field (signup only)
          if (!_isLogin) ...[
            _field(
              ctrl: _nameCtrl,
              hint: 'Full Name',
              icon: Icons.person_outline,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Name required' : null,
            ),
            const SizedBox(height: 16),
          ],
          // Email
          _field(
            ctrl: _emailCtrl,
            hint: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Email required' : null,
          ),
          const SizedBox(height: 16),
          // Password
          _field(
            ctrl: _passCtrl,
            hint: 'Password',
            icon: Icons.lock_outline,
            obscure: _obscure,
            suffix: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.white30,
                size: 20,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            validator: (v) =>
                (v == null || v.length < 4) ? 'Min 4 characters' : null,
          ),
          const SizedBox(height: 16),
          // Remember / Forgot
          if (_isLogin)
            Row(
              children: [
                SizedBox(
                  width: 20, height: 20,
                  child: Checkbox(
                    value: _remember,
                    onChanged: (v) => setState(() => _remember = v ?? false),
                    activeColor: AppTheme.primaryColor,
                    side: const BorderSide(color: Colors.white30),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Remember me',
                    style: TextStyle(color: Colors.white54, fontSize: 13)),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('Forgot password?',
                      style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          const SizedBox(height: 24),
          // Submit
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: auth.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 6,
                shadowColor: AppTheme.primaryColor.withValues(alpha: 0.35),
              ),
              child: auth.isLoading
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : Text(
                      _isLogin ? 'Sign In' : 'Create Account',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.08))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('or',
                    style: TextStyle(color: Colors.white30, fontSize: 13)),
              ),
              Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.08))),
            ],
          ),
          const SizedBox(height: 20),
          // Demo button
          OutlinedButton(
            onPressed: _demo,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rocket_launch_rounded,
                    size: 18, color: AppTheme.secondaryColor),
                const SizedBox(width: 10),
                const Text('Try Demo — No Account Needed',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Social login
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialBtn(Icons.g_mobiledata_rounded, 'Google'),
              const SizedBox(width: 12),
              _socialBtn(Icons.apple_rounded, 'Apple'),
              const SizedBox(width: 12),
              _socialBtn(Icons.fingerprint_rounded, 'Biometric'),
            ],
          ),
          const SizedBox(height: 28),
          // Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isLogin
                    ? 'Don\'t have an account?'
                    : 'Already have an account?',
                style: const TextStyle(color: Colors.white38, fontSize: 13),
              ),
              TextButton(
                onPressed: _toggle,
                child: Text(
                  _isLogin ? 'Sign Up' : 'Sign In',
                  style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================ HELPERS ================
  Widget _field({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.white30, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.errorColor),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _socialBtn(IconData icon, String label) {
    return Tooltip(
      message: 'Continue with $label',
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Container(
            width: 54, height: 48,
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white54, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _glow(Color color, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.15), Colors.transparent],
        ),
      ),
    );
  }

  Widget _pill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 16),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
