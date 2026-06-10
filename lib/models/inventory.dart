import '../models/item_data.dart';
import '../services/item_registry.dart';

/// 背包槽位。
/// ⚠️ `data` 字段为 JSON 字符串，存放装备独立词条/耐久/绑定状态/法宝灵性等。
/// 同 itemId 的两把剑通过 data 区分（新品 vs 百战之刃）。
class InventorySlot {
  final String itemId;
  int count;
  int slotIdx;
  String? data; // JSON: {"affixes":[...],"durability":87,"bindType":"soul","kills":1000}

  InventorySlot({required this.itemId, this.count = 1, this.slotIdx = 0, this.data});

  ItemTemplate? get template => ItemRegistry.get(itemId);
  String get name => template?.name ?? '未知物品';
  ItemGrade get grade => template?.grade ?? ItemGrade.fan;
  ItemCategory get cat => template?.cat ?? ItemCategory.junk;
  bool get stackable => template?.stackable ?? true;
  int get stackMax => template?.stackMax ?? 999;
  int get value => (template?.value ?? 1) * count;

  Map<String, dynamic> toJson() => {'itemId': itemId, 'count': count, 'slotIdx': slotIdx, if (data != null) 'data': data};
  factory InventorySlot.fromJson(Map<String, dynamic> j) => InventorySlot(
        itemId: j['itemId'] as String,
        count: j['count'] as int? ?? 1,
        slotIdx: j['slotIdx'] as int? ?? 0,
        data: j['data'] as String?,
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
  /// [data] 装备/法宝的动态属性 JSON，传入后仅堆叠到 data 完全相同的槽位。
  bool addItem(String itemId, int count, {String? data}) {
    final tmpl = ItemRegistry.get(itemId);
    if (tmpl == null) return false;

    int remaining = count;

    // 优先堆叠（data 必须一致才算同一堆）
    if (tmpl.stackable) {
      for (final slot in slots) {
        if (slot == null) continue;
        if (slot.itemId == itemId && slot.data == data && slot.count < slot.stackMax) {
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
      slots[idx] = InventorySlot(itemId: itemId, count: add, slotIdx: idx, data: data);
      remaining -= add;
    }
    return true;
  }

  /// 移除物品（按 itemId）。优先从堆叠数少的槽位取。
  /// ⚠️ 不区分 data，删除带词条装备时请用 [removeItemBySlot] 精确删除。
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

  /// 按槽位精确删除（防误删极品装备）。
  bool removeItemBySlot(int slotIdx, int count) {
    if (slotIdx < 0 || slotIdx >= capacity) return false;
    final slot = slots[slotIdx];
    if (slot == null || slot.count < count) return false;
    slot.count -= count;
    if (slot.count <= 0) slots[slotIdx] = null;
    return true;
  }

  int countItem(String itemId) {
    int c = 0;
    for (final slot in slots) {
      if (slot != null && slot.itemId == itemId) c += slot.count;
    }
    return c;
  }

  List<InventorySlot> toList() => slots.where((s) => s != null).cast<InventorySlot>().toList();

  /// 返回深拷贝的新背包
  Inventory copy() {
    final inv = Inventory(capacity: capacity);
    for (final s in slots) {
      if (s == null) continue;
      inv.slots[s.slotIdx] = InventorySlot(itemId: s.itemId, count: s.count, slotIdx: s.slotIdx, data: s.data);
    }
    return inv;
  }

  /// 返回添加物品后的新背包（不可变风格）
  Inventory added(String itemId, int count, {String? data}) {
    final inv = copy();
    inv.addItem(itemId, count, data: data);
    return inv;
  }

  /// 返回移除物品后的新背包（不可变风格），(是否成功, 新背包)
  (bool, Inventory) removed(String itemId, int count) {
    final inv = copy();
    final ok = inv.removeItem(itemId, count);
    return (ok, inv);
  }

  /// 按槽位精确删除的不可变版
  (bool, Inventory) removedBySlot(int slotIdx, int count) {
    final inv = copy();
    final ok = inv.removeItemBySlot(slotIdx, count);
    return (ok, inv);
  }
}
