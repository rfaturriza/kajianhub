import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quranku/features/auth/presentation/bloc/auth_state.dart';

import '../../../../../core/constants/asset_constants.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({
    super.key,
    required this.onPressedMenu,
    required this.onPressedQibla,
    required this.onPressedAuth,
  });

  final void Function() onPressedMenu;
  final void Function() onPressedQibla;
  final void Function() onPressedAuth;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Image.asset(
        context.isDarkMode
            ? AssetConst.kajianHubTextLogoLight
            : AssetConst.kajianHubTextLogoDark,
        width: 100,
      ),
      elevation: 0,
      actions: [
        IconButton(
          onPressed: onPressedQibla,
          icon: Icon(
            Symbols.explore_rounded,
            color: context.theme.colorScheme.onSurface,
          ),
        ),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return IconButton(
                onPressed: onPressedAuth,
                icon: CircleAvatar(
                  radius: 16,
                  backgroundColor: context.theme.colorScheme.onSurface,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: state.user.pictureUrl ?? '',
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.theme.colorScheme.onSurface,
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Symbols.person,
                        size: 16,
                        color: context.theme.colorScheme.surface,
                      ),
                    ),
                  ),
                ),
              );
            }
            return IconButton(
              onPressed: onPressedAuth,
              icon: Icon(
                Symbols.login,
                color: context.theme.colorScheme.onSurface,
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
