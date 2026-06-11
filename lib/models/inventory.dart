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
      // 防脏数据：仅当目标槽位为空才直接放入，否则找空位
      if (s.slotIdx < inv.slots.length && inv.slots[s.slotIdx] == null) {
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
  /// [返回] int: 无法放入背包的剩余数量（0 = 全部成功）。
  int addItem(String itemId, int count, {String? data}) {
    final tmpl = ItemRegistry.get(itemId);
    if (tmpl == null) return count;

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
          if (remaining <= 0) return 0;
        }
      }
    }

    // 新槽位
    while (remaining > 0) {
      final idx = slots.indexWhere((s) => s == null);
      if (idx < 0) break; // 背包满，跳出，剩余数量外抛
      final add = tmpl.stackable ? (remaining > tmpl.stackMax ? tmpl.stackMax : remaining) : 1;
      slots[idx] = InventorySlot(itemId: itemId, count: add, slotIdx: idx, data: data);
      remaining -= add;
    }
    return remaining;
  }

  /// 移除物品（按 itemId）。优先从堆叠数少的槽位取。
  /// ⚠️ 不区分 data，删除带词条装备时请用 [removeItemBySlot] 精确删除。
  bool removeItem(String itemId, int count) {
    // 原子性：总数不足则直接拒绝，不修改任何状态
    if (countItem(itemId) < count) return false;

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
    return true; // 走到这里说明一定扣完了
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

  /// 批量添加物品。在内存中一次结算，防并发覆盖。
  /// [返回] int: 总溢出的数量（0 = 全部成功）
  int addItems(List<({String itemId, int count, String? data})> items) {
    int totalLeft = 0;
    for (final item in items) {
      totalLeft += addItem(item.itemId, item.count, data: item.data);
    }
    return totalLeft;
  }

  /// 返回添加物品后的新背包（不可变风格）。
  /// [返回] (int 剩余未添加数量, Inventory 新背包)。left==0 表示全部成功。
  (int, Inventory) added(String itemId, int count, {String? data}) {
    final inv = copy();
    final left = inv.addItem(itemId, count, data: data);
    return (left, inv);
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

  /// 交换两个槽位的物品（用于 UI 拖拽整理）。
  bool swapSlots(int indexA, int indexB) {
    if (indexA < 0 || indexA >= capacity || indexB < 0 || indexB >= capacity) return false;
    if (indexA == indexB) return true;

    final temp = slots[indexA];
    slots[indexA] = slots[indexB];
    if (slots[indexA] != null) slots[indexA]!.slotIdx = indexA;
    slots[indexB] = temp;
    if (slots[indexB] != null) slots[indexB]!.slotIdx = indexB;
    return true;
  }

  /// 不可变版槽位交换
  Inventory swapped(int indexA, int indexB) {
    final inv = copy();
    inv.swapSlots(indexA, indexB);
    return inv;
  }

  /// 一键整理：消除空洞，合并同类项。
  void compact() {
    final allItems = slots.where((s) => s != null).cast<InventorySlot>().toList();

    // 先按 itemId 排序以便合并
    allItems.sort((a, b) => a.itemId.compareTo(b.itemId));

    // 清空背包
    for (int i = 0; i < capacity; i++) {
      slots[i] = null;
    }

    // 重新按序添加，自动填补空洞 + 合并未满堆叠
    for (final item in allItems) {
      addItem(item.itemId, item.count, data: item.data);
    }
  }

  /// 不可变版一键整理
  Inventory compacted() {
    final inv = copy();
    inv.compact();
    return inv;
  }
}
