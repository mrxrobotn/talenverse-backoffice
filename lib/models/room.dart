class Transform {
  final Rotation rotation;
  final Translation translation;
  final Scale3D scale3D;

  Transform({
    required this.rotation,
    required this.translation,
    required this.scale3D,
  });

  factory Transform.fromJson(Map<String, dynamic> json) {
    return Transform(
      rotation: Rotation.fromJson(json['rotation']),
      translation: Translation.fromJson(json['translation']),
      scale3D: Scale3D.fromJson(json['scale3D']),
    );
  }

  Map<String, dynamic> toJson() => {
    'rotation': rotation.toJson(),
    'translation': translation.toJson(),
    'scale3D': scale3D.toJson(),
  };
}

class Rotation {
  final double x, y, z, w;

  Rotation({
    required this.x,
    required this.y,
    required this.z,
    required this.w,
  });

  factory Rotation.fromJson(Map<String, dynamic> json) => Rotation(
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    z: (json['z'] as num).toDouble(),
    w: (json['w'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'z': z,
    'w': w,
  };
}

class Translation {
  final double x, y, z;

  Translation({
    required this.x,
    required this.y,
    required this.z,
  });

  factory Translation.fromJson(Map<String, dynamic> json) => Translation(
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    z: (json['z'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'z': z,
  };
}

class Scale3D {
  final double x, y, z;

  Scale3D({
    required this.x,
    required this.y,
    required this.z,
  });

  factory Scale3D.fromJson(Map<String, dynamic> json) => Scale3D(
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    z: (json['z'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'z': z,
  };
}

class Asset {
  final String assetId;
  final String? mediaId;
  final String type;
  final Transform transform;
  final bool interactable;

  Asset({
    required this.assetId,
    this.mediaId,
    required this.type,
    required this.transform,
    required this.interactable,
  });

  factory Asset.fromJson(Map<String, dynamic> json) => Asset(
    assetId: json['assetId'],
    mediaId: json['mediaId'],
    type: json['type'],
    transform: Transform.fromJson(json['transform']),
    interactable: json['interactable'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'assetId': assetId,
    'mediaId': mediaId,
    'type': type,
    'transform': transform.toJson(),
    'interactable': interactable,
  };
}

class Room {
  final String id; // <-- Add this
  final String ownerEpicGamesId;
  final String roomNumber;
  bool approved;
  final List<Asset> assets;

  Room({
    required this.id, // <-- Include here
    required this.ownerEpicGamesId,
    required this.roomNumber,
    required this.approved,
    required this.assets,
  });

  factory Room.fromJson(Map<String, dynamic> json) => Room(
    id: json['_id'],
    ownerEpicGamesId: json['owner_epicGamesId'],
    roomNumber: json['room_number'],
    approved: json['approved'] ?? false,
    assets: (json['assets'] as List)
        .map((e) => Asset.fromJson(e))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'owner_epicGamesId': ownerEpicGamesId,
    'room_number': roomNumber,
    'approved': approved,
    'assets': assets.map((e) => e.toJson()).toList(),
  };
}
