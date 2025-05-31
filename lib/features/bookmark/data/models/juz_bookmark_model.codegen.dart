import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/juz_bookmark.codegen.dart';

part 'juz_bookmark_model.codegen.freezed.dart';

part 'juz_bookmark_model.codegen.g.dart';

@freezed
abstract class JuzBookmarkModel with _$JuzBookmarkModel {
  const factory JuzBookmarkModel({
    required String name,
    required int number,
    required String description,
  }) = _JuzBookmarkModel;

  const JuzBookmarkModel._();

  factory JuzBookmarkModel.fromJson(Map<String, dynamic> json) =>
      _$JuzBookmarkModelFromJson(json);

  factory JuzBookmarkModel.fromEntity(JuzBookmark entity) => JuzBookmarkModel(
        name: entity.name,
        number: entity.number,
        description: entity.description,
      );

  JuzBookmark toEntity() => JuzBookmark(
        name: name,
        number: number,
        description: description,
      );
}
