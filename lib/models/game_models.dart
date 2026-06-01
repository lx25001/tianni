/// 地图数据模型

/// 出口 — 从一个房间到另一个房间的方向
class Exit {
  final String dir;         // n/s/e/w/ne/nw/se/sw/u/d
  final String label;       // 北/南/东/西/东北/西北/东南/西南
  final String toRoom;      // 目标房间 ID
  final String toName;      // 目标房间名称
  final bool crossRegion;   // 是否跨区域
  final String? portal;     // 跨区域通道名

  const Exit({
    required this.dir,
    required this.label,
    required this.toRoom,
    required this.toName,
    this.crossRegion = false,
    this.portal,
  });

  factory Exit.fromJson(Map<String, dynamic> json) => Exit(
    dir: json['dir'] as String,
    label: json['label'] as String,
    toRoom: json['toRoom'] as String? ?? json['to_room'] as String,
    toName: json['toName'] as String? ?? json['to_name'] as String,
    crossRegion: json['crossRegion'] as bool? ?? false,
    portal: json['portal'] as String?,
  );
}

/// 房间信息
class RoomInfo {
  final String id;
  final String name;
  final String region;
  final String type;       // plain/mountain/cave/city/ruin

  const RoomInfo({
    required this.id,
    required this.name,
    required this.region,
    this.type = 'plain',
  });
}

/// 当前位置
class CurrentPosition {
  final String roomId;
  final String roomName;
  final String region;

  const CurrentPosition({
    required this.roomId,
    required this.roomName,
    required this.region,
  });

  factory CurrentPosition.fromJson(Map<String, dynamic> json) => CurrentPosition(
    roomId: json['roomId'] as String? ?? json['room_id'] as String,
    roomName: json['roomName'] as String? ?? json['room_name'] as String,
    region: json['region'] as String,
  );
}

/// 地图节点（Painter 用）
class MapNode {
  final String roomId;
  final String roomName;
  final String region;
  final bool isCurrent;

  const MapNode({
    required this.roomId,
    required this.roomName,
    required this.region,
    this.isCurrent = false,
  });
}

/// 移动后返回的完整位置数据
class PositionData {
  final CurrentPosition current;
  final List<Exit> exits;
  final List<MapNode> mapNodes;

  const PositionData({
    required this.current,
    required this.exits,
    required this.mapNodes,
  });

  factory PositionData.fromJson(Map<String, dynamic> json) => PositionData(
    current: CurrentPosition.fromJson(json['current'] as Map<String, dynamic>),
    exits: (json['exits'] as List).map((e) => Exit.fromJson(e as Map<String, dynamic>)).toList(),
    mapNodes: (json['mapNodes'] as List? ?? (json['map_nodes'] as List))
        .map((n) => MapNode(
              roomId: n['roomId'] as String? ?? n['room_id'] as String,
              roomName: n['roomName'] as String? ?? n['room_name'] as String,
              region: n['region'] as String,
              isCurrent: n['isCurrent'] as bool? ?? false,
            ))
        .toList(),
  );
}
