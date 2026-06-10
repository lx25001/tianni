import 'inventory.dart';
import 'item_data.dart';
import '../services/item_registry.dart';

/// 角色身上的装备映射：equipType → InventorySlot
/// 例如 {'weapon': 寒铁剑, 'armor': 星辰法袍, 'accessory': null, 'artifact': null}
typedef EquipmentSlots = Map<String, InventorySlot?>;

/// 装备槽元数据
class EquipmentInfo {
  final String equipType; // weapon/armor/accessory/artifact
  final InventorySlot slot;

  EquipmentInfo({required this.equipType, required this.slot});

  ItemTemplate? get template => slot.template;
}

class Equipment {
  final int slot; // character slot
  final EquipmentSlots slots;

  static const defaultTypes = ['weapon', 'armor', 'accessory', 'artifact'];
  static const labels = {'weapon': '武器', 'armor': '防具', 'accessory': '饰品', 'artifact': '法宝'};

  Equipment({required this.slot, Map<String, InventorySlot?>? initSlots})
      : slots = initSlots ?? {for (final t in defaultTypes) t: null};

  /// 穿戴装备。返回被替换下来的旧装备（null 表示原槽位为空）。
  InventorySlot? equip(String equipType, InventorySlot item) {
    final old = slots[equipType];
    slots[equipType] = item;
    return old;
  }

  /// 卸下装备。返回卸下的装备。
  InventorySlot? unequip(String equipType) {
    final item = slots[equipType];
    slots[equipType] = null;
    return item;
  }

  List<EquipmentInfo> get equipped => slots.entries
      .where((e) => e.value != null)
      .map((e) => EquipmentInfo(equipType: e.key, slot: e.value!))
      .toList();

  /// 深拷贝
  Equipment copy() {
    final copySlots = <String, InventorySlot?>{};
    for (final e in slots.entries) {
      final s = e.value;
      copySlots[e.key] = s != null ? InventorySlot(itemId: s.itemId, count: s.count, slotIdx: s.slotIdx, data: s.data) : null;
    }
    return Equipment(slot: slot, initSlots: copySlots);
  }
}
