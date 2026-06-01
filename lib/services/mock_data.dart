import '../models/game_models.dart';

/// 本地 Mock 数据 — 迷雾山脉测试地图
class MockData {
  MockData._();

  static String currentRoom = 'room_misty_pass';

  /// 房间出口表
  static final Map<String, List<Exit>> _roomExits = {
    'room_misty_pass': const [
      Exit(dir: 'e', label: '东', toRoom: 'room_cloud_platform', toName: '云海平台'),
      Exit(dir: 'se', label: '东南', toRoom: 'room_ghost_valley', toName: '幽冥谷'),
      Exit(dir: 'sw', label: '西南', toRoom: 'room_ancient_forest', toName: '古树林'),
      Exit(dir: 'n', label: '北', toRoom: 'room_bone_cave', toName: '白骨洞'),
      Exit(dir: 'ne', label: '东北', toRoom: 'room_fairy_ruins', toName: '仙门遗址'),
    ],
    'room_cloud_platform': const [
      Exit(dir: 'w', label: '西', toRoom: 'room_misty_pass', toName: '迷雾山口'),
      Exit(dir: 's', label: '南', toRoom: 'room_cliff_edge', toName: '断崖边'),
      Exit(dir: 'ne', label: '东北', toRoom: 'room_fairy_ruins', toName: '仙门遗址', crossRegion: true, portal: '云中天梯'),
    ],
    'room_ghost_valley': const [
      Exit(dir: 'e', label: '东', toRoom: 'room_bone_cave', toName: '白骨洞'),
      Exit(dir: 'nw', label: '西北', toRoom: 'room_misty_pass', toName: '迷雾山口'),
      Exit(dir: 'se', label: '东南', toRoom: 'room_abyss', toName: '深渊底'),
    ],
    'room_bone_cave': const [
      Exit(dir: 'w', label: '西', toRoom: 'room_ghost_valley', toName: '幽冥谷'),
      Exit(dir: 's', label: '南', toRoom: 'room_misty_pass', toName: '迷雾山口'),
      Exit(dir: 'ne', label: '东北', toRoom: 'room_lava_cave', toName: '熔岩洞'),
    ],
    'room_ancient_forest': const [
      Exit(dir: 'ne', label: '东北', toRoom: 'room_misty_pass', toName: '迷雾山口'),
      Exit(dir: 's', label: '南', toRoom: 'room_abyss', toName: '深渊底'),
      Exit(dir: 'se', label: '东南', toRoom: 'room_geo_fire', toName: '地火裂缝'),
    ],
    'room_abyss': const [
      Exit(dir: 'n', label: '北', toRoom: 'room_ancient_forest', toName: '古树林'),
      Exit(dir: 'ne', label: '东北', toRoom: 'room_lava_cave', toName: '熔岩洞'),
      Exit(dir: 'nw', label: '西北', toRoom: 'room_ghost_valley', toName: '幽冥谷'),
      Exit(dir: 'e', label: '东', toRoom: 'room_geo_fire', toName: '地火裂缝'),
    ],
    'room_fairy_ruins': const [
      Exit(dir: 'sw', label: '西南', toRoom: 'room_misty_pass', toName: '迷雾山口'),
      Exit(dir: 'se', label: '东南', toRoom: 'room_lava_cave', toName: '熔岩洞'),
      Exit(dir: 'w', label: '西', toRoom: 'room_cloud_platform', toName: '云海平台'),
    ],
    'room_cliff_edge': const [
      Exit(dir: 'n', label: '北', toRoom: 'room_cloud_platform', toName: '云海平台'),
      Exit(dir: 'e', label: '东', toRoom: 'room_lava_cave', toName: '熔岩洞'),
    ],
    'room_lava_cave': const [
      Exit(dir: 'w', label: '西', toRoom: 'room_cliff_edge', toName: '断崖边'),
      Exit(dir: 'sw', label: '西南', toRoom: 'room_bone_cave', toName: '白骨洞'),
      Exit(dir: 'nw', label: '西北', toRoom: 'room_fairy_ruins', toName: '仙门遗址'),
      Exit(dir: 'e', label: '东', toRoom: 'room_abyss', toName: '深渊底'),
      Exit(dir: 'ne', label: '东北', toRoom: 'room_geo_fire', toName: '地火裂缝'),
    ],
    'room_geo_fire': const [
      Exit(dir: 'nw', label: '西北', toRoom: 'room_ancient_forest', toName: '古树林'),
      Exit(dir: 'sw', label: '西南', toRoom: 'room_lava_cave', toName: '熔岩洞'),
    ],
  };

  /// 房间信息表
  static final Map<String, RoomInfo> _roomInfo = {
    'room_misty_pass': const RoomInfo(id: 'room_misty_pass', name: '迷雾山口', region: '迷雾山脉', type: 'mountain'),
    'room_cloud_platform': const RoomInfo(id: 'room_cloud_platform', name: '云海平台', region: '迷雾山脉', type: 'plain'),
    'room_ghost_valley': const RoomInfo(id: 'room_ghost_valley', name: '幽冥谷', region: '迷雾山脉', type: 'cave'),
    'room_bone_cave': const RoomInfo(id: 'room_bone_cave', name: '白骨洞', region: '迷雾山脉', type: 'cave'),
    'room_ancient_forest': const RoomInfo(id: 'room_ancient_forest', name: '古树林', region: '迷雾山脉', type: 'plain'),
    'room_abyss': const RoomInfo(id: 'room_abyss', name: '深渊底', region: '迷雾山脉', type: 'cave'),
    'room_fairy_ruins': const RoomInfo(id: 'room_fairy_ruins', name: '仙门遗址', region: '迷雾山脉', type: 'ruin'),
    'room_cliff_edge': const RoomInfo(id: 'room_cliff_edge', name: '断崖边', region: '迷雾山脉', type: 'mountain'),
    'room_lava_cave': const RoomInfo(id: 'room_lava_cave', name: '熔岩洞', region: '迷雾山脉', type: 'cave'),
    'room_geo_fire': const RoomInfo(id: 'room_geo_fire', name: '地火裂缝', region: '迷雾山脉', type: 'cave'),
  };

  /// 获取指定房间的位置数据
  static PositionData mockPosition(String roomId) {
    final room = _roomInfo[roomId]!;
    final exits = _roomExits[roomId] ?? [];

    // 构建地图节点：当前房间 + 所有邻居（去重）
    final seen = <String>{};
    final nodes = <MapNode>[];

    // 当前节点
    seen.add(roomId);
    nodes.add(MapNode(roomId: roomId, roomName: room.name, region: room.region, isCurrent: true));

    // 邻居节点
    for (final exit in exits) {
      if (!seen.contains(exit.toRoom)) {
        seen.add(exit.toRoom);
        final neighbor = _roomInfo[exit.toRoom];
        if (neighbor != null) {
          nodes.add(MapNode(roomId: exit.toRoom, roomName: neighbor.name, region: neighbor.region));
        }
      }
    }

    return PositionData(
      current: CurrentPosition(roomId: room.id, roomName: room.name, region: room.region),
      exits: exits,
      mapNodes: nodes,
    );
  }

  /// 模拟移动
  static PositionData mockMove(String fromRoom, String direction) {
    final exits = _roomExits[fromRoom] ?? [];
    final exit = exits.firstWhere(
      (e) => e.dir == direction,
      orElse: () => throw Exception('该方向无路'),
    );
    currentRoom = exit.toRoom;
    return mockPosition(currentRoom);
  }

  /// 房间 NPC 数据
  static final Map<String, List<Map<String, String>>> _roomNPCs = {
    'room_misty_pass': [
      {'name': '守山道人', 'desc': '迷雾山口的守护者，神情淡漠'},
      {'name': '行脚商', 'desc': '背着大包袱的商贩，兜售丹药'},
    ],
    'room_cloud_platform': [
      {'name': '云端剑修', 'desc': '在此悟剑的白衣修士'},
    ],
    'room_ghost_valley': [
      {'name': '游魂', 'desc': '迷路的阴魂，喃喃自语'},
      {'name': '鬼修老者', 'desc': '在此地修炼邪术的黑袍人'},
    ],
    'room_bone_cave': [
      {'name': '白骨精', 'desc': '盘踞洞穴深处的妖物'},
    ],
    'room_ancient_forest': [
      {'name': '采药童子', 'desc': '在林中寻觅灵草的小道童'},
      {'name': '古树精魄', 'desc': '千年古树化出的灵体'},
    ],
    'room_abyss': [
      {'name': '深渊魔影', 'desc': '看不清面目的黑暗存在'},
    ],
    'room_fairy_ruins': [
      {'name': '遗迹守护灵', 'desc': '仙门覆灭后残留的执念'},
    ],
    'room_cliff_edge': [
      {'name': '断崖猎户', 'desc': '在此狩猎妖兽的散修'},
    ],
    'room_lava_cave': [
      {'name': '火鳞蟒', 'desc': '盘踞在熔岩中的巨蛇'},
      {'name': '炼器师', 'desc': '借地火淬炼法宝的红脸大汉'},
    ],
    'room_geo_fire': [
      {'name': '地火之灵', 'desc': '火焰中诞生的元素生物'},
    ],
  };

  /// 房间资源数据
  static final Map<String, List<Map<String, String>>> _roomResources = {
    'room_misty_pass': [
      {'name': '雾隐草', 'desc': '炼丹材料·凡品', 'color': '#7A9B6A'},
      {'name': '青石矿', 'desc': '炼器材料·凡品', 'color': '#8B8378'},
    ],
    'room_cloud_platform': [
      {'name': '云母石', 'desc': '炼器材料·良品', 'color': '#B8C8D8'},
      {'name': '朝阳露', 'desc': '炼丹引子·良品', 'color': '#FFE4A0'},
    ],
    'room_ghost_valley': [
      {'name': '阴魂珠', 'desc': '特殊材料·灵品', 'color': '#6B4E9B'},
    ],
    'room_bone_cave': [
      {'name': '兽骨', 'desc': '炼器材料·凡品', 'color': '#D4C4A8'},
      {'name': '磷火粉', 'desc': '炼丹辅料·凡品', 'color': '#7FC87F'},
    ],
    'room_ancient_forest': [
      {'name': '千年灵芝', 'desc': '炼丹材料·珍品', 'color': '#8B2252'},
      {'name': '灵泉水', 'desc': '炼丹引子·良品', 'color': '#5BC0DE'},
    ],
    'room_abyss': [
      {'name': '暗影结晶', 'desc': '特殊材料·灵品', 'color': '#3D1C5E'},
    ],
    'room_fairy_ruins': [
      {'name': '残碑碎片', 'desc': '功法残页材料', 'color': '#D4AF37'},
      {'name': '古仙玉', 'desc': '法宝材料·仙品', 'color': '#FFEEE0'},
    ],
    'room_cliff_edge': [
      {'name': '铁矿石', 'desc': '炼器材料·凡品', 'color': '#9B9B9B'},
      {'name': '鹰羽', 'desc': '符箓材料·良品', 'color': '#B8860B'},
    ],
    'room_lava_cave': [
      {'name': '火灵石', 'desc': '修炼材料·灵品', 'color': '#FF6347'},
      {'name': '熔岩精华', 'desc': '炼器淬火液·珍品', 'color': '#FF4500'},
    ],
    'room_geo_fire': [
      {'name': '地心火种', 'desc': '炼丹/炼器火源·仙品', 'color': '#FF0000'},
    ],
  };

  static List<Map<String, String>> getNPCs(String roomId) =>
      _roomNPCs[roomId] ?? [];
  static List<Map<String, String>> getResources(String roomId) =>
      _roomResources[roomId] ?? [];
}
