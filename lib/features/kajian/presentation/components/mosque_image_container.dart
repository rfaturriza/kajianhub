import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:quranku/core/constants/asset_constants.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';

class MosqueImageContainer extends StatelessWidget {
  final String imageUrl;
  final String? distanceInKm;
  final double width;
  final double height;

  const MosqueImageContainer({
    super.key,
    required this.imageUrl,
    this.distanceInKm,
    this.width = 100,
    this.height = 110,
  });

  @override
  Widget build(BuildContext context) {
    var imageUrl = this.imageUrl;
    if (imageUrl.isEmpty) {
      imageUrl = AssetConst.mosqueDummyImageUrl;
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Stack(
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (distanceInKm != null && distanceInKm!.isNotEmpty) ...[
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surfaceContainer,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: Text(
                  distanceInKm != null ? '$distanceInKm Km' : '',
                  style: context.theme.textTheme.labelSmall?.copyWith(
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: Center(
          child: Icon(
            Icons.error,
            color: context.theme.colorScheme.error,
          ),
        ),
      ),
    );
  }
}
