# 物品系统设计文档

## 目录

- [一、物品分类](#一物品分类)
- [二、品阶体系](#二品阶体系)
- [三、JSON 数据模型](#三json-数据模型)
- [四、物品模板示例](#四物品模板示例)
- [五、背包/储物系统](#五背包储物系统)
- [六、物品生成规则](#六物品生成规则)
- [七、与现有系统的集成](#七与现有系统的集成)
- [八、实现路线](#八实现路线)

---

## 前置：24 大境界速查

| idx | 境界 | 阶段 | 寿元(年) |
|-----|------|------|----------|
| 0 | 炼气期 | 凡尘 | 120 |
| 1 | 筑基期 | 凡尘 | 240 |
| 2 | 金丹期 | 凡尘 | 500 |
| 3 | 元婴期 | 凡尘 | 1,000 |
| 4 | 化神期 | 凡尘 | 2,000 |
| 5 | 合体期 | 凡尘 | 4,000 |
| 6 | 大乘期 | 凡尘 | 8,000 |
| 7 | 渡劫期 | 凡尘 | 16,000 |
| 8 | 飞升期 | 登仙 | 30,000 |
| 9 | 地仙境 | 登仙 | 60,000 |
| 10 | 天仙境 | 登仙 | 120,000 |
| 11 | 真仙境 | 登仙 | 250,000 |
| 12 | 玄仙境 | 登仙 | 500,000 |
| 13 | 金仙境 | 登仙 | 1,000,000 |
| 14 | 太乙境 | 道境 | 2,500,000 |
| 15 | 大罗境 | 道境 | 5,000,000 |
| 16 | 混元境 | 道境 | 10,000,000 |
| 17 | 鸿蒙境 | 道境 | 20,000,000 |
| 18 | 混沌境 | 道境 | 40,000,000 |
| 19 | 主宰境 | 道境 | 80,000,000 |
| 20 | 虚空境 | 道境 | 160,000,000 |
| 21 | 造化境 | 道境 | 320,000,000 |
| 22 | 道祖境 | 道境 | 650,000,000 |
| 23 | 永恒境 | 道境 | ∞ |

---

## 一、物品分类

| 一级分类 | cat 值 | 二级细分 | 说明 |
|----------|--------|----------|------|
| 装备 | `equip` | 武器/防具/饰品/法宝 | 可穿戴，有词条 |
| 丹药 | `pill` | 修炼类/战斗类/突破类/特殊类 | 消耗品，有时效 buff |
| 材料 | `mat` | 草药/矿石/兽材/灵石/特殊 | 炼丹/炼器原料 |
| 符箓 | `talisman` | 攻击符/防御符/辅助符/传送符 | 一次性消耗，无每回合使用上限 |
| 功法 | `skill` | 修炼功法/战斗功法/禁术 | 可学习，提供六维加成 |
| 杂物 | `junk` | 任务物品/古董/残页/容器 | 交易/任务用 |

---

## 二、品阶体系

8 阶品级，从低到高：

| 品阶 | grade | 色值 | 说明 |
|------|-------|------|------|
| 凡品 | `fan` | `#8B8378` 灰 | 随处可见，价值极低 |
| 良品 | `liang` | `#5B9A3F` 绿 | 稍有价值，常见于练气-筑基 |
| 灵品 | `ling` | `#4A90D9` 蓝 | 金丹期修士常用 |
| 宝品 | `bao` | `#9B6FD4` 紫 | 元婴-化神阶段 |
| 珍品 | `zhen` | `#FF8C00` 橙 | 稀有，大乘-渡劫 |
| 仙品 | `xian` | `#FFD700` 金 | 地仙-天仙用度 |
| 圣品 | `sheng` | `#FF5555` 红 | 太乙-大罗层次 |
| 道品 | `dao` | `#00FFFF` 青 | 传说级，仅存远古遗迹 |

---

## 三、JSON 数据模型

### 3.1 通用物品基类

```json
{
  "id": "item_misty_grass_001",
  "name": "雾隐草",
  "cat": "mat",
  "subCat": "草药",
  "grade": "fan",
  "desc": "生于迷雾山脉的低阶灵草，炼丹基础材料",
  "stackable": true,
  "stackMax": 999,
  "weight": 1,
  "value": 5,
  "properties": {
    "element": "木",
    "purity": 0.1
  }
}
```

### 3.2 丹药扩展

```json
{
  "id": "pill_build_base_001",
  "name": "筑基丹",
  "cat": "pill",
  "subCat": "突破类",
  "grade": "ling",
  "desc": "炼气九层修士突破筑基必备丹药，大幅提升突破成功率",
  "stackable": true,
  "stackMax": 99,
  "weight": 1,
  "value": 500,
  "cooldown": 3600,
  "effects": [
    {
      "type": "breakthrough_bonus",
      "target": "realm_0_to_1",
      "value": 0.3,
      "desc": "炼气→筑基突破成功率 +30%"
    }
  ],
  "duration": 0,
  "toxicity": 5
}
```

### 3.3 装备扩展

```json
{
  "id": "equip_cold_iron_sword_001",
  "name": "寒铁剑",
  "cat": "equip",
  "subCat": "武器",
  "grade": "bao",
  "desc": "以玄铁矿淬寒泉百炼而成，剑身泛着幽蓝寒光",
  "stackable": false,
  "stackMax": 1,
  "weight": 12,
  "value": 3500,
  "equipSlot": "weapon",
  "baseStats": {
    "attack": 85,
    "critRate": 0.05
  },
  "affixes": [
    {
      "name": "锋锐",
      "type": "prefix",
      "grade": "T3",
      "effect": "基础攻击 +15%",
      "value": 0.15
    },
    {
      "name": "冰冻",
      "type": "suffix",
      "grade": "T2",
      "effect": "命中时 20% 概率附加减速",
      "trigger": "on_hit",
      "procRate": 0.2,
      "debuff": "slow",
      "debuffValue": 0.2,
      "debuffDuration": 2
    }
  ],
  "bindType": "none",
  "durability": 100,
  "maxDurability": 100,
  "repairCost": 50
}
```

### 3.4 材料扩展

```json
{
  "id": "mat_fire_spirit_stone_001",
  "name": "火灵石",
  "cat": "mat",
  "subCat": "灵石",
  "grade": "liang",
  "desc": "蕴含火属性灵气的灵石，可用于修炼加速或炼器淬火",
  "stackable": true,
  "stackMax": 999,
  "weight": 1,
  "value": 200,
  "properties": {
    "element": "火",
    "energy": 500,
    "cultivateBonus": 1.5
  }
}
```

### 3.5 符箓扩展

```json
{
  "id": "talisman_fire_blast_001",
  "name": "烈火符",
  "cat": "talisman",
  "subCat": "攻击符",
  "grade": "ling",
  "desc": "注入火灵气的符纸，撕开即释放一道烈火",
  "stackable": true,
  "stackMax": 20,
  "weight": 1,
  "value": 120,
  "cooldown": 30,
  "effects": [
    {
      "type": "damage",
      "element": "火",
      "baseValue": 200,
      "scaling": "spi_0.3",
      "desc": "造成 200 + 神识×0.3 点火系伤害"
    },
    {
      "type": "burn",
      "procRate": 0.3,
      "duration": 3,
      "value": 0.03,
      "desc": "30% 概率附加灼烧（每回合 3% HP，3 回合）"
    }
  ]
}
```

### 3.6 功法物品

```json
{
  "id": "skill_tianni_sword_001",
  "name": "天逆剑诀残本",
  "cat": "skill",
  "subCat": "修炼功法",
  "grade": "bao",
  "desc": "天逆老人的剑道心得残篇，虽不完整仍蕴含凌厉剑意",
  "stackable": false,
  "stackMax": 1,
  "weight": 3,
  "value": 8000,
  "learnRequirement": {
    "minRealm": 0,
    "minLayer": 1,
    "element": "金",
    "costValue": 2000
  },
  "dimensions": {
    "pow": 18,
    "fin": 12,
    "for": 8,
    "mys": 10,
    "spd": 10,
    "com": 12
  },
  "totalPoints": 70
}
```

---

## 四、物品模板示例

### 12 件初始背包物品

```json
[
  {
    "id": "mat_sky_grass_001",
    "name": "天灵草",
    "cat": "mat",
    "subCat": "草药",
    "grade": "fan",
    "desc": "凡品灵草，随处可见",
    "stackable": true,
    "stackMax": 999,
    "weight": 1,
    "value": 5,
    "properties": { "element": "木" }
  },
  {
    "id": "mat_dark_iron_001",
    "name": "玄铁矿",
    "cat": "mat",
    "subCat": "矿石",
    "grade": "fan",
    "desc": "寻常矿石，炼器基础材料",
    "stackable": true,
    "stackMax": 999,
    "weight": 3,
    "value": 8,
    "properties": { "element": "金" }
  },
  {
    "id": "pill_build_001",
    "name": "筑基丹",
    "cat": "pill",
    "subCat": "突破类",
    "grade": "ling",
    "desc": "炼气九层突破筑基必备",
    "stackable": true,
    "stackMax": 99,
    "weight": 1,
    "value": 500,
    "effects": [{ "type": "breakthrough", "realmTarget": 1, "bonus": 0.30 }],
    "toxicity": 5
  },
  {
    "id": "talisman_evil_breaker_001",
    "name": "破邪符",
    "cat": "talisman",
    "subCat": "攻击符",
    "grade": "liang",
    "desc": "对阴魂类造成额外伤害",
    "stackable": true,
    "stackMax": 20,
    "weight": 1,
    "value": 80,
    "effects": [{ "type": "damage", "vsType": "undead", "multiplier": 2.0 }]
  },
  {
    "id": "equip_cold_iron_sword_001",
    "name": "寒铁剑",
    "cat": "equip",
    "subCat": "武器",
    "grade": "bao",
    "desc": "玄铁百炼，剑泛寒光",
    "stackable": false,
    "stackMax": 1,
    "weight": 12,
    "value": 3500,
    "equipSlot": "weapon",
    "baseStats": { "attack": 85 },
    "affixes": [{ "name": "锋锐", "type": "prefix", "grade": "T3", "value": 0.15 }],
    "durability": 100,
    "maxDurability": 100
  },
  {
    "id": "liquid_jade_001",
    "name": "玉液",
    "cat": "pill",
    "subCat": "修炼类",
    "grade": "ling",
    "desc": "修炼时服用，修炼速率 +50%，持续 30 分钟",
    "stackable": true,
    "stackMax": 99,
    "weight": 1,
    "value": 300,
    "effects": [{ "type": "cultivate_boost", "value": 0.5 }],
    "duration": 1800,
    "toxicity": 2
  },
  {
    "id": "mat_fire_stone_001",
    "name": "火灵石",
    "cat": "mat",
    "subCat": "灵石",
    "grade": "liang",
    "desc": "火属性灵石，修炼燃料",
    "stackable": true,
    "stackMax": 999,
    "weight": 1,
    "value": 200,
    "properties": { "element": "火", "energy": 500 }
  },
  {
    "id": "mat_beast_bone_001",
    "name": "兽骨",
    "cat": "mat",
    "subCat": "兽材",
    "grade": "fan",
    "desc": "妖兽骸骨，可研磨入药",
    "stackable": true,
    "stackMax": 999,
    "weight": 2,
    "value": 10
  },
  {
    "id": "mat_mist_grass_001",
    "name": "雾隐草",
    "cat": "mat",
    "subCat": "草药",
    "grade": "liang",
    "desc": "生于迷雾深处，炼丹良材",
    "stackable": true,
    "stackMax": 999,
    "weight": 1,
    "value": 30,
    "properties": { "element": "水" }
  },
  {
    "id": "pill_gather_qi_001",
    "name": "聚气丹",
    "cat": "pill",
    "subCat": "修炼类",
    "grade": "ling",
    "desc": "加速灵气积蓄，修炼速率 +20%，持续 10 分钟",
    "stackable": true,
    "stackMax": 99,
    "weight": 1,
    "value": 100,
    "effects": [{ "type": "cultivate_boost", "value": 0.2 }],
    "duration": 600,
    "toxicity": 3
  },
  {
    "id": "equip_iron_armor_001",
    "name": "铁甲衣",
    "cat": "equip",
    "subCat": "防具",
    "grade": "liang",
    "desc": "凡铁锻打的护甲，笨重但实用",
    "stackable": false,
    "stackMax": 1,
    "weight": 20,
    "value": 800,
    "equipSlot": "armor",
    "baseStats": { "defense": 45 },
    "durability": 80,
    "maxDurability": 80
  },
  {
    "id": "talisman_fire_001",
    "name": "烈火符",
    "cat": "talisman",
    "subCat": "攻击符",
    "grade": "ling",
    "desc": "烈火一击",
    "stackable": true,
    "stackMax": 20,
    "weight": 1,
    "value": 120,
    "effects": [{ "type": "damage", "element": "火", "baseValue": 200 }]
  }
]
```

---

## 五、背包/储物系统

### 5.1 数据结构

```dart
class Inventory {
  final int capacity;                    // 总容量（默认 50）
  final Map<String, InventorySlot> slots; // itemId → slot

  int get usedCount => slots.values.fold(0, (sum, s) => sum + s.count);
  int get freeCount => capacity - slots.length; // 已占用的不同物品数
}

class InventorySlot {
  final String itemId;
  int count;
}
```

### 5.2 操作

| 操作 | 说明 |
|------|------|
| `add(itemId, count)` | 添加物品，可堆叠则合并，不可堆叠占新槽 |
| `remove(itemId, count)` | 移除指定数量，归 0 则删槽 |
| `move(fromSlot, toSlot)` | 交换两个槽位 |
| `sort(by)` | 按品阶/分类/数量排序 |
| `use(itemId)` | 消耗品使用（丹药/符箓）|
| `equip(itemId)` | 装备物品到对应槽位 |
| `discard(itemId, count)` | 丢弃物品（弹出确认） |

### 5.3 持久化

背包数据与角色存档一起存储在 `CharacterStorage` (SharedPreferences) 中：

```json
{
  "inventory": {
    "capacity": 50,
    "slots": {
      "mat_sky_grass_001": { "itemId": "mat_sky_grass_001", "count": 156 },
      "pill_build_001": { "itemId": "pill_build_001", "count": 3 }
    }
  }
}
```

---

## 六、物品生成规则

### 6.1 掉落表（按 24 境界）

| 境界段 | 敌人/来源 | 品阶范围 | 掉落数量 | 稀有概率 |
|--------|-----------|----------|----------|----------|
| 0-1 (炼气-筑基) | 妖兽/散修 | 凡-良 | 1-3 | 良品 20% |
| 2-3 (金丹-元婴) | 妖王/魔修 | 良-灵 | 1-4 | 灵品 15% |
| 4-5 (化神-合体) | 大妖/邪修 | 灵-宝 | 2-5 | 宝品 10% |
| 6-7 (大乘-渡劫) | 天妖/魔尊 | 宝-珍 | 2-6 | 珍品 8% |
| 8-9 (飞升-地仙) | 仙兽/堕仙 | 宝-仙 | 2-6 | 仙品 5% |
| 10-13 (天仙-金仙) | 上古凶兽 | 珍-仙 | 3-7 | 仙品 8% |
| 14-17 (太乙-鸿蒙) | 混沌生物 | 仙-圣 | 2-5 | 圣品 3% |
| 18-23 (混沌-永恒) | 道之本源 | 圣-道 | 1-3 | 道品 1% |
| 秘境宝箱 (全等级) | 按秘境等级 | 灵-仙 | 1-3 | — |
| 远古遗迹 (全等级) | 固定 | 珍-道 | 1-2 | — |
| NPC 商店 | 按城镇等级 | 凡-珍 | 不限 | — |
| 炼丹/炼器产出 | 材料品阶+技能 | — | 1-10 | — |

### 6.2 随机词条生成

装备掉落时按品阶决定：

```
1. 确定品阶 → 词条数量 (1~5)
2. 随机选择前缀/后缀组合
3. 每个词条独立随机 T1-T5
4. 特殊品阶（仙/圣/道）固定词条保证最低 T3
```

### 6.3 物品数据源

- **静态模板**：`assets/data/items.json` — 物品定义（名称、分类、品阶、基础属性）
- **动态属性**：词条、耐久、绑定状态在掉落时随机生成
- **玩家物品**：存储于角色存档的 inventory 字段

---

## 七、与现有系统的集成

### 7.1 修炼系统

- 灵石作为修炼加速燃料（1x/2x/5x/10x 倍率）
- 丹药 buff 叠加进入修炼公式的 `丹药加成(P)` 因子
- 修炼类丹药有时效（duration），过期自动移除 buff

### 7.2 战斗系统

- 装备提供 `baseStats` + `affixes` 战斗加成
- 符箓可在战斗中消耗使用
- 丹药提供临时战斗 buff

### 7.3 炼丹/炼器

- 材料从背包消耗
- 产出物品加入背包
- 品阶取决于材料品阶 + 技能等级

### 7.4 地图/探索

- 房间资源数据 (MockData._roomResources) 与物品 template 对应
- 资源采集 → 物品加入背包

### 7.5 交易/NPC

- 物品 `value` 作为基准价格
- NPC 商店按品阶上架物品
- 玩家可出售背包物品

---

## 八、物品使用详解

### 8.1 各类物品使用行为

| 分类 | 使用结果 | 说明 |
|------|----------|------|
| **丹药** | 消耗 1 个，触发 effects，添加 buff/debuff 到角色 | 有 cooldown（同类丹药 CD 共享），叠加 toxicity |
| **符箓** | 消耗 1 个，立即触发 effects（战斗内外均可） | 一次性，无 CD，无回合使用上限。玩家若有 100 张烈火符，一回合内可全部撕开 |
| **装备** | 穿戴到对应槽位（替换旧装备，旧装备回背包） | 穿戴时校验 `requireRealm` / `requireLayer` |
| **功法** | 学习，转为角色的已学功法列表 | 学习后物品消失，功法进入功法面板 |
| **材料** | 不可直接使用 | 仅用于炼丹/炼器/任务交付 |
| **杂物** | 不可直接使用 | 部分可交付 NPC 任务 |
| **灵石** | 作为修炼加速燃料 | 通过修炼面板选择倍率消耗，不通过物品详情 |

### 8.2 丹药毒性机制

每次服用丹药增加 `toxicityAccumulated`：

```
toxicityAccumulated += pill.toxicity
dailyToxicityDecay = 5 + (境界系数 × 3)

当 toxicityAccumulated > 50: 修炼效率 -10%
当 toxicityAccumulated > 100: 修炼效率 -25%, HP 上限 -10%
当 toxicityAccumulated > 200: 修炼效率 -50%, 全属性 -20%, 随机负面效果
```

毒性的存在防止玩家无限磕药——需要"排毒期"。

### 8.3 装备槽位

| 槽位 | slot | 可穿戴 | 境界限制 |
|------|------|--------|----------|
| 武器 | `weapon` | 剑/刀/枪/弓/杖/扇 | 珍品以上需 `minRealm` |
| 防具 | `armor` | 衣/甲/袍/铠 | 同上 |
| 饰品 | `accessory` | 戒指/项链/玉佩 | 同上 |
| 法宝 | `artifact` | 炉/镜/印/幡/珠 | 金丹期（realm 2）解锁法宝槽 |

**法宝槽解锁**：金丹期之前仅 3 槽（武器/防具/饰品）。金丹期开启法宝槽，共 4 槽。

**境界穿戴限制**：珍品及以上装备有 `requireRealm` 字段。如一件仙品武器可能要求 `minRealm: 9`（地仙起步），低级修士无法穿戴高级装备。

---

## 九、物品绑定与交易

### 9.1 绑定类型

| bindType | 说明 | 触发条件 |
|----------|------|----------|
| `none` | 不绑定，可自由交易 | 默认 |
| `equip` | 装备后绑定 | 首次穿戴 |
| `pickup` | 拾取即绑定 | 从 boss/秘境获取 |
| `causal` | 因果绑定 | 本命法宝、自创功法——与神魂融为一体，无法丢弃/交易/摧毁 |

因果绑定物品不可丢弃、不可交易、不可摧毁。不是规则限制——是"你做不到"。本命法宝是你神魂的延伸，自创功法是你道的具现。要丢弃它们，等于放弃你自己。

### 9.2 物品价值公式

```
基准价值 = 品阶系数 × 基础值

品阶系数：
  凡=1, 良=3, 灵=10, 宝=30, 珍=100, 仙=400, 圣=1600, 道=8000

装备溢价 = 基准价值 × (1 + 词条数量 × 0.2) × 耐久度/最大耐久度
丹药溢价 = 基准价值 × (1 + effects.length × 0.1)
NPC 买入价 = 基准价值 × 0.4   (四折回收)
NPC 卖出价 = 基准价值 × 1.2   (溢价 20%)
```

---

## 十、背包扩展

| 扩展方式 | 容量增加 | 解锁条件 |
|----------|----------|----------|
| 初始 | 50 格 | 默认 |
| 储物袋·凡 | +20 格 (共 70) | 坊市购买，500 灵石，无境界要求 |
| 储物袋·良 | +30 格 (共 100) | 坊市购买，3000 灵石，筑基期+ |
| 储物袋·灵 | +50 格 (共 150) | 拍卖行，1 万灵石，金丹期+ |
| 储物戒·宝 | +80 格 (共 230) | 秘境掉落，元婴期+ |
| 储物戒·珍 | +120 格 (共 350) | 远古遗迹，化神期+ |
| 纳戒·仙 | +200 格 (共 550) | 宗门奖励，渡劫期+ |
| 纳戒·圣 | +300 格 (共 850) | 道境奇遇，太乙境+ |
| 虚空袋 | +500 格 (共 1350) | 造化境+专属，自行开辟虚空空间 |

每次扩容替换当前储物装备，旧的折价回收 30%。

---

## 十一、搜索/筛选/排序

### 11.1 搜索

- 匹配 `name` 字段（模糊匹配，大小写不敏感）
- 匹配 `desc` 字段
- 支持拼音首字母？→ 限于物品较少时暂不需要

### 11.2 筛选 Tab

| Tab | 对应 cat | 显示内容 |
|-----|----------|----------|
| 全部 | `*` | 所有物品 |
| 丹药 | `pill` | 修炼/战斗/突破/特殊 |
| 材料 | `mat` | 草药/矿石/兽材/灵石 |
| 装备 | `equip` | 武器/防具/饰品/法宝 |
| 符箓 | `talisman` | 所有符箓 |

### 11.3 排序方式

| 排序 | 逻辑 |
|------|------|
| 默认 | 按槽位顺序（玩家可手动拖动） |
| 品阶 | 道→凡 降序 |
| 数量 | 多→少 |
| 分类 | cat → subCat → grade |

### 11.4 批量操作

| 操作 | 触发 | 说明 |
|------|------|------|
| 批量出售 | 长按进入多选模式 | 勾选物品 → 一键出售给 NPC |
| 批量丢弃 | 多选模式 | 勾选 → 一键销毁（二次确认） |
| 一键整理 | 按钮 | 同 cat 物品相邻排列 + 品阶降序 |

---

## 十二、物品 ID 命名规范

```
{cat}_{descriptor}_{seq}

cat: equip / pill / mat / talisman / skill / junk
descriptor: 2-4 个英文词描述（如 cold_iron_sword）
seq: 3 位数字序号（001-999），按添加顺序递增

示例：
  equip_cold_iron_sword_001    → 寒铁剑
  pill_build_base_001          → 筑基丹
  mat_sky_grass_001            → 天灵草
  talisman_fire_blast_001      → 烈火符
```

---

## 十三、物品数据加载流程

```
应用启动
  → ItemRegistry.init()
    → 加载 assets/data/items.json
    → 解析为 Map<String, ItemTemplate>
    → 缓存到内存

角色加载
  → CharacterStorage.load()
    → 解析 inventory JSON
    → 按 itemId 从 ItemRegistry 查找模板
    → 构建 Inventory 对象（slot.itemId + slot.count）

物品操作
  → Inventory.add(itemId, count)
    → 查找模板：可堆叠？已有同 id 槽？容量够？
    → 更新 slots
  → Inventory.remove(itemId, count)
    → count ≤ 0 则删除槽位
  → 自动保存: 操作后 500ms debounce 写入 SharedPreferences
```

---

## 十四、与修炼系统接口

```dart
// 使用灵石加速修炼
bool useSpiritStone(int multiplier) {
  // multiplier: 1/2/5/10
  // 消耗: multiplier × 基础消耗 灵石/秒
  // 修炼速率 × multiplier
}

// 服用修炼丹药
void useCultivatePill(String itemId) {
  // 从背包移除 1 个
  // 添加 timed buff 到 CultivationEngine
  // 叠加 toxicity
}

// 服用突破丹药
void useBreakthroughPill(String itemId) {
  // 仅在突破大境界时可使用
  // bonus 叠加到突破成功率
}
```

---

## 十五、实现路线（更新）

| 阶段 | 内容 | 依赖 |
|------|------|------|
| **P0** | `lib/models/item_data.dart` — 物品数据模型 + `fromJson`/`toJson`（含 24 境界校验） | 无 |
| **P0** | `assets/data/items.json` — 物品模板库（50+ 物品，横跨凡-道品阶） | P0 model |
| **P1** | `lib/services/item_registry.dart` — 物品注册表（按 id 查询模板） | P0 |
| **P1** | `lib/models/inventory.dart` — 背包数据模型 + 增删改查 | P0 |
| **P2** | `lib/providers/inventory_provider.dart` — 背包 Riverpod 状态管理 | P1 |
| **P2** | 储物面板挂接真实数据（替换硬编码） | P2 |
| **P3** | 物品"使用"逻辑：丹药食用/符箓撕开（无上限）/装备穿戴/功法学习 | P2 |
| **P3** | 丹药毒性/CD 系统，装备 `requireRealm` 境界校验 | P3 |
| **P4** | 地图资源采集 → 物品入包 | P2 + 地图 |
| **P4** | 灵石消耗接入修炼面板 | P2 + 修炼 |
| **P5** | 装备穿戴/卸下 + 属性重算 + 法宝槽（金丹期解锁） | P2 |
| **P5** | 词条效果生效引擎（前后缀独立计算） | P5 |
| **P6** | 批量操作（出售/丢弃/整理） + 背包扩展（储物袋购买，按境界解锁） | P2 |
| **P7** | 炼丹/炼器配方 + 材料消耗 | P2 + 材料分类 |
| **P8** | 物品掉落系统（按 24 境界掉落表 + 词条随机） | P1 |
