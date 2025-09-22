import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quranku/core/route/root_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:quranku/core/components/spacer.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/generated/locale_keys.g.dart';
import 'package:quranku/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quranku/features/auth/presentation/bloc/auth_event.dart';
import 'package:quranku/features/auth/presentation/bloc/auth_state.dart';
import 'package:quranku/features/auth/domain/entities/auth_user.codegen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.profileTitle.tr()),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      bottomNavigationBar: _buildActionButtons(context),
      body: const _ProfileBody(),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: FilledButton.icon(
          onPressed: () {
            context.read<AuthBloc>().add(AuthLogoutRequested());
            context.pop();
          },
          icon: const Icon(Symbols.logout),
          label: Text(LocaleKeys.logout.tr()),
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AuthAuthenticated) {
          return _buildProfileContent(context, state.user);
        } else if (state is AuthUnauthenticated) {
          return _buildUnauthenticatedView(context);
        } else if (state is AuthError) {
          return _buildErrorView(context, state.message);
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildProfileContent(BuildContext context, AuthUser user) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AuthBloc>().add(AuthGetMeRequested());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(context, user),
            const VSpacer(height: 32),
            _buildInfoSection(context, user),
            const VSpacer(height: 24),
            _buildContactSection(context, user),
            const VSpacer(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AuthUser user) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 0,
        color: context.theme.colorScheme.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: context.theme.colorScheme.primary,
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: user.pictureUrl ?? '',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(
                      Symbols.person,
                      size: 40,
                      color: context.theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              const VSpacer(height: 16),
              Text(
                user.name.isNotEmpty
                    ? user.name
                    : LocaleKeys.noInformation.tr(),
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const VSpacer(height: 8),
              Text(
                user.email,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (user.roles.isNotEmpty) ...[
                const VSpacer(height: 12),
                Wrap(
                  spacing: 8,
                  children: user.roles
                      .map(
                        (role) => Chip(
                          label: Text(role.name),
                          backgroundColor:
                              context.theme.colorScheme.secondaryContainer,
                          labelStyle: TextStyle(
                            color:
                                context.theme.colorScheme.onSecondaryContainer,
                            fontSize: 12,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, AuthUser user) {
    return Card(
      elevation: 0,
      color: context.theme.colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.information.tr(),
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const VSpacer(height: 16),
            if (user.contactPerson != null &&
                user.contactPerson!.isNotEmpty) ...[
              _buildInfoTile(
                context,
                icon: Symbols.phone,
                title: LocaleKeys.contactPerson.tr(),
                value: user.contactPerson!,
              ),
              const VSpacer(height: 12),
            ],
            if (user.placeOfBirth != null && user.placeOfBirth!.isNotEmpty) ...[
              _buildInfoTile(
                context,
                icon: Symbols.location_on,
                title: LocaleKeys.placeOfBirth.tr(),
                value: user.placeOfBirth!,
              ),
              const VSpacer(height: 12),
            ],
            if (user.description != null && user.description!.isNotEmpty) ...[
              _buildInfoTile(
                context,
                icon: Symbols.info,
                title: LocaleKeys.description.tr(),
                value: user.description!,
              ),
            ],
            if (user.subscribersCount != null) ...[
              const VSpacer(height: 12),
              _buildInfoTile(
                context,
                icon: Symbols.group,
                title: LocaleKeys.subscribers.tr(),
                value: '${user.subscribersCount} ${LocaleKeys.followers.tr()}',
              ),
            ],
            if (user.kajianCount != null) ...[
              const VSpacer(height: 12),
              _buildInfoTile(
                context,
                icon: Symbols.menu_book,
                title: LocaleKeys.kajianCount.tr(),
                value: '${user.kajianCount} ${LocaleKeys.kajianText.tr()}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context, AuthUser user) {
    final hasContacts =
        (user.facebookLink != null && user.facebookLink!.isNotEmpty) ||
            (user.instagramLink != null && user.instagramLink!.isNotEmpty) ||
            (user.youtubeLink != null && user.youtubeLink!.isNotEmpty) ||
            (user.tiktokLink != null && user.tiktokLink!.isNotEmpty);

    if (!hasContacts) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      color: context.theme.colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.socialMedia.tr(),
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const VSpacer(height: 16),
            if (user.facebookLink != null && user.facebookLink!.isNotEmpty)
              _buildContactTile(
                context,
                icon: Symbols.language,
                title: LocaleKeys.facebook.tr(),
                value: user.facebookLink!,
                onTap: () => _launchUrl(user.facebookLink!),
              ),
            if (user.instagramLink != null &&
                user.instagramLink!.isNotEmpty) ...[
              const VSpacer(height: 8),
              _buildContactTile(
                context,
                icon: Symbols.camera_alt,
                title: LocaleKeys.instagram.tr(),
                value: user.instagramLink!,
                onTap: () => _launchUrl(user.instagramLink!),
              ),
            ],
            if (user.youtubeLink != null && user.youtubeLink!.isNotEmpty) ...[
              const VSpacer(height: 8),
              _buildContactTile(
                context,
                icon: Symbols.play_circle,
                title: LocaleKeys.youtube.tr(),
                value: user.youtubeLink!,
                onTap: () => _launchUrl(user.youtubeLink!),
              ),
            ],
            if (user.tiktokLink != null && user.tiktokLink!.isNotEmpty) ...[
              const VSpacer(height: 8),
              _buildContactTile(
                context,
                icon: Symbols.music_note,
                title: LocaleKeys.tiktok.tr(),
                value: user.tiktokLink!,
                onTap: () => _launchUrl(user.tiktokLink!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: context.theme.colorScheme.primary,
        ),
        const HSpacer(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const VSpacer(height: 4),
              Text(
                value,
                style: context.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: context.theme.colorScheme.primary,
            ),
            const HSpacer(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const VSpacer(height: 4),
                  Text(
                    value,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.theme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Symbols.open_in_new,
              size: 16,
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnauthenticatedView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 0,
          color: context.theme.colorScheme.surfaceContainer,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Symbols.person_off,
                  size: 64,
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
                const VSpacer(height: 16),
                Text(
                  LocaleKeys.notLoggedIn.tr(),
                  style: context.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const VSpacer(height: 8),
                Text(
                  LocaleKeys.pleaseLoginToViewProfile.tr(),
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const VSpacer(height: 24),
                FilledButton.icon(
                  onPressed: () => context.goNamed(RootRouter.loginRoute.name),
                  icon: const Icon(Symbols.login),
                  label: Text(LocaleKeys.login.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 0,
          color: context.theme.colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Symbols.error,
                  size: 64,
                  color: context.theme.colorScheme.onErrorContainer,
                ),
                const VSpacer(height: 16),
                Text(
                  LocaleKeys.errorLoadingProfile.tr(),
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.theme.colorScheme.onErrorContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
                const VSpacer(height: 8),
                Text(
                  message,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.theme.colorScheme.onErrorContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
                const VSpacer(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthGetMeRequested());
                  },
                  icon: const Icon(Symbols.refresh),
                  label: Text(LocaleKeys.retry.tr()),
                  style: FilledButton.styleFrom(
                    backgroundColor: context.theme.colorScheme.onErrorContainer,
                    foregroundColor: context.theme.colorScheme.errorContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
