import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_route.dart';
import '../../../core/theme/app_colors.dart';
import '../application/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.redirectTo});

  final String? redirectTo;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final media = MediaQuery.sizeOf(context);
    final isCompact = media.width < 740;
    final horizontalPadding = isCompact ? 16.0 : 28.0;
    final availableWidth = media.width - (horizontalPadding * 2);
    final desiredMaxWidth = isCompact ? 420.0 : 520.0;
    final cardWidth = availableWidth.clamp(320.0, desiredMaxWidth).toDouble();

    return Scaffold(
      body: Stack(
        children: [
          _AuthBackground(isCompact: isCompact),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 20,
                ),
                child: SizedBox(
                  width: cardWidth,
                  child: _buildLoginCard(context, authState.errorMessage),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context, String? errorMessage) {
    return _GlassCard(
      padding: const EdgeInsets.fromLTRB(28, 30, 28, 28),
      child: _buildLoginForm(context, errorMessage),
    );
  }

  Widget _buildLoginForm(BuildContext context, String? errorMessage) {
    final authState = ref.watch(authControllerProvider);
    final isSubmitting = authState.submitting;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Авторизация',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Введите логин и пароль администратора',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.white70),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _usernameController,
            enabled: !isSubmitting,
            autofillHints: const [AutofillHints.username],
            textInputAction: TextInputAction.next,
            style: const TextStyle(color: AppColors.white),
            cursorColor: AppColors.primary,
            decoration: _inputDecoration(
              labelText: 'Логин',
              prefixIcon: const Icon(Icons.person_outline),
            ),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) {
                return 'Введите логин';
              }
              return null;
            },
            onChanged: (_) =>
                ref.read(authControllerProvider.notifier).clearError(),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _passwordController,
            enabled: !isSubmitting,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            obscureText: _obscurePassword,
            style: const TextStyle(color: AppColors.white),
            cursorColor: AppColors.primary,
            decoration: _inputDecoration(
              labelText: 'Пароль',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                tooltip: _obscurePassword ? 'Показать пароль' : 'Скрыть пароль',
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) {
                return 'Введите пароль';
              }
              return null;
            },
            onChanged: (_) =>
                ref.read(authControllerProvider.notifier).clearError(),
            onFieldSubmitted: (_) => _submit(),
          ),
          if (errorMessage != null && errorMessage.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.error900.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.errorAccent),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.error_outline,
                        size: 18,
                        color: AppColors.errorAccent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.white90,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isSubmitting ? null : _submit,
              icon: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.login_outlined),
              label: Text(isSubmitting ? 'Выполняется вход...' : 'Войти'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = ref.read(authControllerProvider.notifier);
    final success = await controller.login(
      username: _usernameController.text,
      password: _passwordController.text,
    );

    if (!mounted || !success) {
      return;
    }

    final target = _resolveRedirectTarget();
    context.go(target);
  }

  String _resolveRedirectTarget() {
    final candidate = widget.redirectTo?.trim() ?? '';
    if (candidate.isEmpty || !candidate.startsWith('/')) {
      return AppRoutes.dashboard;
    }
    if (candidate == AppRoutes.login) {
      return AppRoutes.dashboard;
    }
    return candidate;
  }

  InputDecoration _inputDecoration({
    required String labelText,
    required Widget prefixIcon,
    Widget? suffixIcon,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.borderLight),
    );

    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: AppColors.white70),
      prefixIconColor: AppColors.white80,
      suffixIconColor: AppColors.white80,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.blackOverlayLight,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.errorAccent),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.errorAccent, width: 1.2),
      ),
    );
  }
}

class _AuthBackground extends StatelessWidget {
  const _AuthBackground({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF030303), Color(0xFF0D1117), Color(0xFF1A1406)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: isCompact ? -120 : -180,
            left: isCompact ? -80 : -120,
            child: const _BlurCircle(size: 320, color: Color(0x66C49331)),
          ),
          Positioned(
            right: isCompact ? -90 : -110,
            bottom: isCompact ? -120 : -150,
            child: const _BlurCircle(size: 360, color: Color(0x334A90E2)),
          ),
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  const _BlurCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child, required this.padding});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.surfaceDarkOverlayStrong,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: child,
        ),
      ),
    );
  }
}
