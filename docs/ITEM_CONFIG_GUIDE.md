# 物品配置说明

## 配置文件清单

| 文件 | 用途 | 可修改 |
|------|------|--------|
| `assets/data/items.json` | 物品模板库（50+物品定义） | ✅ 可自由增删改 |
| `assets/data/starter_items.json` | 创建角色时赠送的初始物品 | ✅ 可调整数量/品种 |
| `lib/models/item_data.dart` | 物品数据模型 + 枚举 + 中文映射 | ⚠️ 改结构需同步JSON |

## items.json 结构

8 品阶：凡/良/灵/宝/珍/仙/圣/道  
6 分类：pills（丹药）/ mats（材料）/ equips（装备）/ talismans（符箓）/ skills（功法）/ junk（杂物）

### 通用字段

```json
{
  "id": "pill_qi_01",        // 唯一ID，格式：类型_名称_序号
  "name": "聚气丹",           // 显示名称
  "cat": "pill",             // 分类：pill/mat/equip/talisman/skill/junk
  "subCat": "修炼类",        // 子分类中文
  "grade": "fan",            // 品阶：fan/liang/ling/bao/zhen/xian/sheng/dao
  "desc": "描述文本",         // 物品描述
  "stackable": true,         // 是否可堆叠
  "stackMax": 99,            // 最大堆叠数（丹药99、装备1、材料999）
  "weight": 1,               // 重量
  "value": 10                // 基准灵石价格
}
```

### 丹药扩展字段

```json
{
  "cooldown": 30,            // 冷却时间（秒）
  "effects": [{              // 效果列表
    "type": "cultivateBoost", // 类型：cultivateBoost/heal/damage/restoreQi/...
    "value": 0.1,            // 效果数值
    "duration": 600          // 持续时间（秒），0=永久
  }],
  "toxicity": 1              // 毒性值
}
```

### 装备扩展字段

```json
{
  "equipSlot": "weapon",     // 装备槽：weapon/armor/accessory/artifact
  "baseStats": {
    "attack": 85,            // 基础属性
    "critRate": 0.05
  },
  "affixes": [{              // 词条
    "name": "锋锐",
    "type": "prefix",        // prefix/suffix
    "grade": "T3",           // T1-T5
    "effect": "基础攻击+15%",
    "value": 0.15
  }],
  "durability": 100,         // 当前耐久
  "maxDurability": 100       // 最大耐久
}
```

### 材料扩展字段

```json
{
  "properties": {            // 材料属性
    "element": "木",         // 五行
    "purity": 0.1            // 纯度
  }
}
```

### 功法扩展字段

```json
{
  "skillDimensions": {       // 六维加成
    "wu": 0.1,               // 武
    "pow": 0.05              // 力
  }
}
```

### 通用可选字段

```json
{
  "realmRequired": 2         // 使用/装备最低境界索引（0=炼气）
}
```

## starter_items.json 结构

```json
[
  {"itemId": "pill_qi_01",    "count": 3,  "reason": "新手修炼基础丹药"},
  {"itemId": "equip_sword_01","count": 1,  "reason": "凡铁锻造的基础武器"}
]
```

- `itemId` — 必须在 `items.json` 中存在
- `count` — 赠送数量
- `reason` — 注释说明，方便策划调整

## 效果类型枚举（effectLabel）

| 英文 key | 中文显示 |
|----------|---------|
| cultivateBoost | 修炼加速 |
| breakthroughBonus | 突破加成 |
| damage | 伤害 |
| heal | 生命回复 |
| restoreQi | 灵力回复 |
| reduceToxicity | 降低毒性 |
| burn | 灼烧 |
| slow | 减速 |
| defenseBoost | 防御提升 |
| teleport | 传送 |

## 属性字段枚举（statLabel）

| 英文 key | 中文显示 |
|----------|---------|
| attack | 攻击力 |
| defense | 防御力 |
| critRate | 暴击率 |
| magicResist | 法术抗性 |
| bagSlots | 储物格 |
| speed | 速度 |

## 添加新物品步骤

1. 编辑 `assets/data/items.json`，按品阶/分类插入新条目
2. 确保 `id` 不重复
3. 热重载即可生效，`ItemRegistry` 启动时自动加载

## 调整初始物品

1. 编辑 `assets/data/starter_items.json`
2. 修改 `itemId` 指向已有物品，调整 `count`
3. 新创建角色立即生效，已有角色不受影响
