// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tile_map.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TileMap _$TileMapFromJson(Map<String, dynamic> json) => TileMap(
      width: json['width'] as int,
      height: json['height'] as int,
      defaultFlags: json['defaultFlags'] as int? ?? 0,
      tiles: (json['tiles'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                int.parse(k),
                (e as Map<String, dynamic>).map(
                  (k, e) => MapEntry(int.parse(k), e as int),
                )),
          ) ??
          const {},
    );

Map<String, dynamic> _$TileMapToJson(TileMap instance) => <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'defaultFlags': instance.defaultFlags,
      'tiles': instance.tiles.map((k, e) =>
          MapEntry(k.toString(), e.map((k, e) => MapEntry(k.toString(), e)))),
    };
