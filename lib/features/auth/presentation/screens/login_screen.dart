import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quranku/core/constants/asset_constants.dart';
import 'package:quranku/core/network/dio_config.dart';
import 'package:quranku/core/route/root_router.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/generated/locale_keys.g.dart';
import 'package:quranku/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quranku/features/auth/presentation/bloc/auth_event.dart';
import 'package:quranku/features/auth/presentation/bloc/auth_state.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  final String? redirectTo;
  const LoginScreen({super.key, this.redirectTo});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      bottomNavigationBar: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: FilledButton.icon(
                icon: const Icon(Symbols.logout),
                onPressed: state is LoginLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                                AuthLoginRequested(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                ),
                              );
                        }
                      },
                label: state is LoginLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.theme.colorScheme.onPrimary,
                        ),
                      )
                    : Text(LocaleKeys.loginButton.tr()),
              ),
            ),
          );
        },
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            context.showInfoToast(LocaleKeys.loginSuccess.tr());
            if (widget.redirectTo != null && widget.redirectTo!.isNotEmpty) {
              context.goNamed(widget.redirectTo!);
            } else {
              context.goNamed(RootRouter.rootRoute.name);
            }
          } else if (state is LoginError) {
            context.showErrorToast(state.message);
          } else if (state is AuthAuthenticated) {
            context.goNamed(RootRouter.rootRoute.name);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildLoginForm(context, state),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // App Logo
        SizedBox(
          width: 120,
          height: 120,
          child: Image.asset(
            context.isDarkMode
                ? AssetConst.kajianHubLogoLight
                : AssetConst.kajianHubLogoDark,
            width: 80,
            height: 80,
          ),
        ),
        // Welcome Text
        Text(
          LocaleKeys.loginTitle.tr(),
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          LocaleKeys.loginSubtitle.tr(),
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context, AuthState state) {
    return Card(
      elevation: 0,
      color: context.theme.colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: LocaleKeys.email.tr(),
                  hintText: LocaleKeys.emailHint.tr(),
                  prefixIcon: const Icon(Symbols.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LocaleKeys.emailRequired.tr();
                  }
                  final emailRegExp = RegExp(
                    r'^((?!\.)[\w\-_.]*[^.])(@\w+)(\.\w+(\.\w+)?[^.\W])$',
                  );
                  if (!emailRegExp.hasMatch(value)) {
                    return LocaleKeys.emailInvalid.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: LocaleKeys.password.tr(),
                  hintText: LocaleKeys.passwordHint.tr(),
                  prefixIcon: const Icon(Symbols.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Symbols.visibility
                          : Symbols.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    tooltip: _obscurePassword
                        ? LocaleKeys.showPassword.tr()
                        : LocaleKeys.hidePassword.tr(),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LocaleKeys.passwordRequired.tr();
                  }
                  if (value.length < 6) {
                    return LocaleKeys.passwordMinLength.tr();
                  }
                  return null;
                },
                onFieldSubmitted: (_) {
                  if (state is! LoginLoading) {
                    if (_formKey.currentState!.validate()) {
                      context.read<AuthBloc>().add(
                            AuthLoginRequested(
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                            ),
                          );
                    }
                  }
                },
              ),
              const SizedBox(height: 16),

              // Registration Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    LocaleKeys.dontHaveAccount.tr(),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () => _launchRegistrationUrl(),
                    child: Text(
                      LocaleKeys.registerHere.tr(),
                      style: TextStyle(
                        color: context.theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchRegistrationUrl() async {
    final kajianhubUrl = NetworkConfig.baseUrlKajianHub;
    final url = Uri.parse('${kajianhubUrl.split('/api').first}/register');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          context.showErrorToast(LocaleKeys.cannotOpenRegistrationPage.tr());
        }
      }
    } catch (e) {
      if (mounted) {
        context.showErrorToast(LocaleKeys.cannotOpenRegistrationPage.tr());
      }
    }
  }
}
