import '../models/item_data.dart';
import '../services/item_registry.dart';

/// 背包槽位
class InventorySlot {
  final String itemId;
  int count;
  int slotIdx;

  InventorySlot({required this.itemId, this.count = 1, this.slotIdx = 0});

  ItemTemplate? get template => ItemRegistry.get(itemId);
  String get name => template?.name ?? '未知物品';
  ItemGrade get grade => template?.grade ?? ItemGrade.fan;
  ItemCategory get cat => template?.cat ?? ItemCategory.junk;
  bool get stackable => template?.stackable ?? true;
  int get stackMax => template?.stackMax ?? 999;
  int get value => (template?.value ?? 1) * count;

  Map<String, dynamic> toJson() => {'itemId': itemId, 'count': count, 'slotIdx': slotIdx};
  factory InventorySlot.fromJson(Map<String, dynamic> j) => InventorySlot(
        itemId: j['itemId'] as String,
        count: j['count'] as int? ?? 1,
        slotIdx: j['slotIdx'] as int? ?? 0,
      );
}

/// 背包
class Inventory {
  final int capacity;
  final List<InventorySlot?> slots;

  Inventory({this.capacity = 30}) : slots = List.filled(30, null);

  factory Inventory.fromSlotList(List<InventorySlot> slotList, {int capacity = 30}) {
    final inv = Inventory(capacity: capacity);
    for (final s in slotList) {
      if (s.slotIdx < inv.slots.length) {
        inv.slots[s.slotIdx] = s;
      } else {
        // 找一个空位
        final idx = inv.slots.indexWhere((s) => s == null);
        if (idx >= 0) {
          s.slotIdx = idx;
          inv.slots[idx] = s;
        }
      }
    }
    return inv;
  }

  int get usedSlots => slots.where((s) => s != null).length;
  int get freeSlots => capacity - usedSlots;

  /// 添加物品。优先堆叠到已有槽位。
  bool addItem(String itemId, int count) {
    final tmpl = ItemRegistry.get(itemId);
    if (tmpl == null) return false;

    int remaining = count;

    // 优先堆叠
    if (tmpl.stackable) {
      for (final slot in slots) {
        if (slot == null) continue;
        if (slot.itemId == itemId && slot.count < slot.stackMax) {
          final room = slot.stackMax - slot.count;
          final add = remaining < room ? remaining : room;
          slot.count += add;
          remaining -= add;
          if (remaining <= 0) return true;
        }
      }
    }

    // 新槽位
    while (remaining > 0) {
      final idx = slots.indexWhere((s) => s == null);
      if (idx < 0) return false; // 背包满
      final add = tmpl.stackable ? (remaining > tmpl.stackMax ? tmpl.stackMax : remaining) : 1;
      slots[idx] = InventorySlot(itemId: itemId, count: add, slotIdx: idx);
      remaining -= add;
    }
    return true;
  }

  /// 移除物品。优先从堆叠数少的槽位取。
  bool removeItem(String itemId, int count) {
    int remaining = count;
    for (final slot in slots) {
      if (slot == null || slot.itemId != itemId) continue;
      if (slot.count >= remaining) {
        slot.count -= remaining;
        if (slot.count <= 0) slots[slot.slotIdx] = null;
        return true;
      }
      remaining -= slot.count;
      slots[slot.slotIdx] = null;
    }
    return remaining <= 0;
  }

  int countItem(String itemId) {
    int c = 0;
    for (final slot in slots) {
      if (slot != null && slot.itemId == itemId) c += slot.count;
    }
    return c;
  }

  List<InventorySlot> toList() => slots.where((s) => s != null).cast<InventorySlot>().toList();
}
