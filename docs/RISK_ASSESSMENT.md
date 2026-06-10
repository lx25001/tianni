# 风险与改进备忘录

---

## 一、数据层依赖脱节 🔴 高风险

### 现状
- `pubspec.yaml`：只有 `sqflite` + `shared_preferences`
- 设计文档规划：SQLite 结构数据 + Isar/Hive 存储背包复杂对象/动态词条/装备快照
- 当前背包实现：`inventory_slot` 表仅存 `itemId` + `count`，装备词条、耐久等全部缺失

### 风险
物品系统越往后补，重构成本越高。动态词条装备（寒铁剑耐久87→76→52）、NPC 记忆、物品使用历史这些非结构化数据，用关系型表硬套会导致：
- 频繁 `JSON` 字段序列化/反序列化
- 查询性能下降
- 移植到 NoSQL 时数据迁移复杂

### 对策
| 时间点 | 动作 |
|--------|------|
| **现在** | `pubspec.yaml` 添加 `hive` + `hive_flutter` + `hive_generator`（build_runner） |
| **P2** | `lib/services/hive_service.dart` — 初始化 HiveBox |
| **P2** | `lib/models/equip_snapshot.dart` — 带词条/耐久/绑定状态的装备快照，用 `@HiveType` 注解 |
| **P3** | 背包槽的 `data` 字段从 JSON string 迁移到 Hive reference |
| **P4** | NPC 记忆 / 物品生成历史全部入 Hive |

```yaml
# pubspec.yaml 新增
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.0
```

---

## 二、范围蔓延 🟡 中风险

### 现状
- `docs/SYSTEMS.md`：54 章节，含暗杀网络/情报黑市/梦境世界/道统争霸等
- `docs/DEV_ROADMAP.md`：P0-P7 分层，但 P5+ 之后没有工时预估
- 当前进度：P0 闭环跑通（修炼+存档+物品），P1 物品系统基本完成
- 战斗系统（气的博弈）尚未实现，但文档已设计了洞穴/战场/法宝/九层功防表

### 风险
高阶系统（夺舍、领域、道统）的诱惑会让开发偏离核心循环。没有战斗的修仙游戏没有验证价值，没有探索的修仙世界没有沉浸感。

### 对策
严格执行 P0→P7 顺序，**P2 战斗为硬阻断**：

```
✅ P0  角色/修炼/存档/物品基础
⬜ P1  物品系统完善（装备属性/耐久/使用效果接入修炼）
⬜ P2  战斗系统（气的博弈 / 九层攻防表 / 回合制核心）
⬜ P3  装备穿戴 + 属性重算 + 词条生效
⬜ P4  地图探索（资源采集 / NPC 对话 / 事件触发器）
⬜ P5  炼丹/炼器配方系统
⬜ P6  社交/宗门基础
⬜ P7  夺舍/领域/高阶玩法
```

**铁律**：前一层完成 MVP（最小可玩闭环）之前，拒绝讨论下一层的需求变更。

---

## 三、配置数据管理 🟡 中风险

### 现状
- `assets/data/items.json`：50 物品，手写 JSON，无校验
- `assets/data/starter_items.json`：初始物品，手写
- 丹药配方/装备属性/功法数据全部硬编码或散落在设计文档文字中

### 风险
物品数从 50→200→500 时，手写 JSON 的 `id` 冲突、字段遗漏、品阶标注错误会频繁发生。策划无法独立调整数值，必须依赖程序员改 JSON。

### 对策
| 阶段 | 方案 |
|------|------|
| **短期**（物品<200） | 手动维护 + `ItemRegistry.init()` 启动时校验：发现重复 id / 缺失字段 / realmRequired 越界 → 抛明确错误 |
| **中期**（物品200+） | Excel 表格（装备.xlsx / 丹药.xlsx）→ `dart run scripts/items_gen.dart` → 生成 `items.json`。表格设数据验证规则（品阶下拉、境界索引范围） |
| **长期** | 策划自服务：Electron 桌面工具 / Web 管理后台，直接编辑 SQLite 配置库，导出 JSON |

**立即执行**：在 `ItemRegistry.init()` 添加校验：

```dart
final ids = <String>{};
for (final e in list) {
  final id = e['id'] as String;
  if (ids.contains(id)) throw '重复物品ID: $id';
  ids.add(id);
  if (e['realmRequired'] is int && (e['realmRequired'] < 0 || e['realmRequired'] > 23)) 
    throw '$id: realmRequired 越界';
}
```

---

## 四、本地离线性能 🟡 中风险

### 现状
- `GameClockProvider`：全局每秒 tick，12 时辰轮转，15 节日检测
- 修炼面板：200ms tick，实时计算速率/突破/属性增长
- 地图系统：房间节点 + 移动，但 NPC/资源/事件全部 `MockData` 硬编码
- 「世界演化」「NPC 后台演算」在设计文档中存在，代码中完全未实现

### 风险
当加入真正的 NPC 系统（每个 NPC 有自己的功法/境界/行为树）和世界事件（妖兽潮/秘境开启/宗门战争）后，全部在线实时计算会导致：
- 手机 CPU 满载 → 耗电暴增
- 帧率下降 → UI 卡顿
- 离线超过 8 小时后进入游戏 → 需要补算海量状态

### 对策
严格采用「JIT 惰性追溯」模式——这是设计文档中已经提到的正确思路：

```
玩家交互时 → 检查最后交互时间 → 补算从那时到现在的状态差 → 缓存
```

| 系统 | 在线计算 | 离线补算 |
|------|---------|---------|
| 修炼 XP | 200ms tick | `上次保存时间 → now` 时间差 × 离线速率 × 0.6 |
| NPC 状态 | 仅当前房间 NPC 实时 | 其他 NPC：下次进入房间时补算 |
| 世界事件 | 仅活跃事件检查触发条件 | 事件进度 = `(now - triggerTime) × 速率` |
| 宗门/势力 | 玩家交互时快照 | 不实时演算，按固定周期 batch 更新 |

**实现优先级**：
1. 当前修炼系统已实现「在线 tick」，P2 补上「离线补算」→ `CultivationEngine.applyOffline(离开秒数)`
2. P4 地图 NPC 系统「仅在房间内激活」→ 离开房间后 NPC 进入惰性状态
3. P6 世界事件系统「触发时 JIT 补算」→ 永远不主动批量更新

---

## 总结

| 风险 | 等级 | 立即行动 |
|------|------|---------|
| NoSQL 缺失 | 🔴 | `pubspec.yaml` 加 Hive 依赖 |
| 范围蔓延 | 🟡 | P2 战斗前冻结其他需求 |
| 配置维护 | 🟡 | `ItemRegistry.init()` 加校验 |
| 离线性能 | 🟡 | P2 补上离线修炼补算 |

四个风险中前三个皆有即时可落地的代码改动，不需要大规模重构。第四个是架构原则，从现在开始每写一个新系统都遵从这个模式。
