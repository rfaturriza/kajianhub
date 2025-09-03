import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';

/// A reusable fullscreen image dialog that displays an image with zoom functionality
/// and an optional overlay text at the bottom
class FullscreenImageDialog extends StatelessWidget {
  final String imageUrl;
  final String? overlayText;

  const FullscreenImageDialog({
    super.key,
    required this.imageUrl,
    this.overlayText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
          child: Stack(
            children: [
              // Full screen image
              Center(
                child: GestureDetector(
                  onTap: () {}, // Prevent tap from bubbling up to dismiss
                  child: InteractiveViewer(
                    panEnabled: true,
                    boundaryMargin: const EdgeInsets.all(20),
                    minScale: 0.5,
                    maxScale: 3.0,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          color: context.theme.colorScheme.primary,
                        ),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Icon(
                          Icons.error,
                          color: context.theme.colorScheme.error,
                          size: 64,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Close button
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 20,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.surface
                          .withValues(alpha: 0.8),
                      border: Border.all(
                        color: context.theme.colorScheme.outline
                            .withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.close,
                      color: context.theme.colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                ),
              ),
              // Optional overlay text at bottom
              if (overlayText != null) ...[
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 20,
                  left: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: () {}, // Prevent tap from bubbling up to dismiss
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.surface
                            .withValues(alpha: 0.9),
                        border: Border.all(
                          color: context.theme.colorScheme.outline
                              .withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        overlayText!,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Utility function to show fullscreen image dialog
void showFullscreenImage(
  BuildContext context, {
  required String imageUrl,
  String? overlayText,
}) {
  showDialog(
    context: context,
    barrierColor: context.theme.colorScheme.surface.withValues(alpha: 0.9),
    builder: (BuildContext context) {
      return FullscreenImageDialog(
        imageUrl: imageUrl,
        overlayText: overlayText,
      );
    },
  );
}

extension DialogExtension on BuildContext {
  /// Show fullscreen image dialog with the given image URL and optional overlay text
  void showFullscreenImageDialog({
    required String imageUrl,
    String? overlayText,
  }) {
    showFullscreenImage(
      this,
      imageUrl: imageUrl,
      overlayText: overlayText,
    );
  }
}
