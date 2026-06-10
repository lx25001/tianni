# P1 物品系统 — 实施计划

## 目标

储物面板从硬编码假数据 → 真实物品系统。创建角色送初始物品，修炼/采集/战斗获得物品入包，物品可查看详情/使用/丢弃。

---

## 第一步：物品数据模型 `lib/models/item_data.dart`

### 枚举定义

```dart
enum ItemCategory { pill, material, equipment, talisman, skillBook }

enum ItemGrade { mortal(0), good(1), spirit(2), treasure(3), rare(4), 
                 immortal(5), saint(6), dao(7);  // 凡良灵宝珍仙圣道
  final int tier;
  const ItemGrade(this.tier);
}
```

### ItemTemplate（模板，不可变）

```dart
class ItemTemplate {
  final String id;          // "pill_qi_01"
  final String name;        // "聚气丹"
  final ItemCategory category;
  final ItemGrade grade;
  final int maxStack;       // 丹药99，装备1，材料999
  final int? realmRequired; // 使用/装备最低境界索引
  final String desc;        // 物品描述

  // 丹药专用
  final List<ItemEffect>? effects;  // [{type:"restoreQi", value:50}]

  // 装备专用
  final EquipmentType? equipType;   // weapon/armor/accessory
  final Map<String, int>? baseStats; // {atk:10, def:5}

  // 功法专用
  final Map<String, double>? skillDimensions; // {pow:0.3, wu:0.2, ...}
}
```

### 颜色映射

```dart
static Color gradeColor(ItemGrade g) => switch (g) {
  mortal    -> Colors.grey,
  good      -> Colors.white,
  spirit    -> Colors.green,
  treasure  -> Colors.blue,
  rare      -> Colors.purple,
  immortal  -> Colors.amber,
  saint     -> Colors.orange,
  dao       -> Colors.red,
};
```

---

## 第二步：物品模板库 `assets/data/items.json`

50+ 物品，横跨 8 品阶：

### 丹药类（pill，10种）
```json
[
  {"id":"pill_qi_01", "name":"聚气丹", "grade":0, "category":"pill", "maxStack":99,
   "desc":"最基础的修炼丹药，略微提升灵气吸纳速度。", "effects":[{"type":"cultivateBoost","value":0.1,"duration":600}]},
  {"id":"pill_qi_02", "name":"凝气丹", "grade":1, "category":"pill", "realmRequired":0,
   "maxStack":99, "desc":"比聚气丹浓郁数倍，筑基期修士常用。", "effects":[{"type":"cultivateBoost","value":0.2,"duration":900}]},
  ...
]
```

### 材料类（material，15种）
```json
[
  {"id":"mat_herb_01", "name":"天灵草", "grade":0, "category":"material", "maxStack":999,
   "desc":"凡间常见的灵草，炼丹基本材料。"},
  {"id":"mat_ore_01", "name":"青石矿", "grade":0, "category":"material", "maxStack":999,
   "desc":"含微量灵气的矿石，炼器基础材料。"},
  ...
]
```

### 装备类（equipment，10种）
```json
[
  {"id":"equip_sword_01", "name":"铁剑", "grade":0, "category":"equipment", "equipType":"weapon",
   "maxStack":1, "baseStats":{"atk":8}, "desc":"一把普通的铁剑，凡铁锻造。"},
  {"id":"equip_robe_01", "name":"粗布道袍", "grade":0, "category":"equipment", "equipType":"armor",
   "maxStack":1, "baseStats":{"def":3}, "desc":"普通麻布缝制的道袍，聊胜于无。"},
  ...
]
```

### 符箓类（talisman，5种）
```json
[
  {"id":"talisman_fire_01", "name":"火符", "grade":0, "category":"talisman", "maxStack":20,
   "desc":"撕开释放一道火焰，对敌人造成少量伤害。", "effects":[{"type":"damage","value":30}]},
  ...
]
```

### 功法类（skillBook，3种）
```json
[
  {"id":"skill_01", "name":"引气入体诀", "grade":0, "category":"skillBook", "maxStack":1,
   "desc":"最入门的吐纳功法，引导天地灵气入体。", "skillDimensions":{"wu":0.1,"pow":0.05}},
  ...
]
```

---

## 第三步：物品注册表 `lib/services/item_registry.dart`

```dart
class ItemRegistry {
  static final Map<String, ItemTemplate> _items = {};

  static Future<void> init() async {
    final json = await rootBundle.loadString('assets/data/items.json');
    final list = jsonDecode(json) as List;
    for (final e in list) {
      final tmpl = ItemTemplate.fromJson(e);
      _items[tmpl.id] = tmpl;
    }
  }

  static ItemTemplate? get(String id) => _items[id];
  static List<ItemTemplate> get all => _items.values.toList();
  static List<ItemTemplate> byCategory(ItemCategory c) =>
      _items.values.where((t) => t.category == c).toList();
}
```

---

## 第四步：背包数据模型 `lib/models/inventory.dart`

### InventorySlot

```dart
class InventorySlot {
  final String itemId;
  int count;
  int slotIndex;
  String? data;  // JSON: 装备词条/耐久等动态属性

  ItemTemplate? get template => ItemRegistry.get(itemId);
}
```

### Inventory

```dart
class Inventory {
  final int capacity;  // 初始30，可通过储物袋扩容
  final List<InventorySlot?> slots; // 固定长度数组，空位为 null

  bool addItem(String itemId, int count);     // 堆叠优先，返回是否成功
  bool removeItem(String itemId, int count);  // 优先取堆叠少的
  int countItem(String itemId);               // 统计拥有数量
  void sortByGrade();                          // 按品阶排序
  void swapSlots(int a, int b);
}
```

### SQLite 建表

```sql
CREATE TABLE inventory_slot (
  id       INTEGER PRIMARY KEY AUTOINCREMENT,
  slot     INTEGER NOT NULL,
  item_id  TEXT NOT NULL,
  count    INTEGER NOT NULL DEFAULT 1,
  slot_idx INTEGER NOT NULL,
  data     TEXT
);
```

---

## 第五步：储物面板接入 `game_page.dart`

当前储物面板 `_BagPanel` 使用 `MockData.bagItems` 硬编码。替换流程：

1. 启动时 `ItemRegistry.init()` 加载物品模板
2. `CharacterStorage` 创建角色时赠送初始物品（聚气丹×3 + 铁剑×1 + 粗布道袍×1）
3. `_BagPanel` 读取 `InventoryDao.load(slot)` → 渲染真实物品网格
4. 物品格显示：名称（按品阶着色）+ 数量 + 点击弹详情
5. 详情弹窗：描述 + 品阶 + 使用/丢弃按钮

---

## 文件清单

| 文件 | 内容 | 新增/修改 |
|------|------|----------|
| `lib/models/item_data.dart` | ItemTemplate + 枚举 + fromJson | 新增 |
| `assets/data/items.json` | 50+ 物品模板 | 新增 |
| `lib/services/item_registry.dart` | 加载 + 查询 | 新增 |
| `lib/models/inventory.dart` | Inventory + InventorySlot | 新增 |
| `lib/services/inventory_dao.dart` | 背包 CRUD | 新增 |
| `lib/providers/inventory_provider.dart` | Riverpod 状态管理 | 新增 |
| `lib/pages/game_page.dart` | _BagPanel 接入真数据 | 修改 |
| `lib/main.dart` | ItemRegistry.init() | 修改 |
| `lib/services/database_service.dart` | inventory_slot 建表 | 修改 |

---

## 做完 P1 的验收标准

- [ ] 创建角色后背包自动获得初始物品（聚气丹×3 + 铁剑×1 + 粗布道袍×1）
- [ ] 储物面板显示真实物品，品阶颜色正确
- [ ] 点击物品弹出详情：名称/品阶/描述/数量
- [ ] 物品可丢弃（数量-1，归零时从背包移除）
- [ ] 重启后物品不丢失（SQLite 持久化）
- [ ] ItemRegistry 可按分类查询（为后续炼丹/炼器配方做准备）
