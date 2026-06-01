# 天逆 — 文字修仙游戏

纯单机文字修仙游戏，Flutter 框架，SQLite/Isar 本地存储。24 大境界，回合制战斗，洞府建造，炼丹炼器，NPC 关系网络。

## 文档体系

| 文档 | 内容 |
|------|------|
| [GAME_PLAN.md](docs/GAME_PLAN.md) | **总规划**：系统全景 / 菜单架构 / 数据库设计 / 实现优先级 |
| [SYSTEMS.md](docs/SYSTEMS.md) | **数值与公式**：修炼算法 / 灵根 / 战斗 Rating / 死亡惩罚 / 叙事消耗 |
| [DESIGN.md](docs/DESIGN.md) | **玩法设计**：52 章世界观 → 琅琊台 / 黑市 / 禁术 / 因果 / 虚空游商 |
| [ITEM_SYSTEM.md](docs/ITEM_SYSTEM.md) | **物品系统**：分类×品阶 / JSON 模型 / 背包 / 掉落表 / 8 品阶色 |
| [CAVE_ABODE_DESIGN.md](docs/CAVE_ABODE_DESIGN.md) | **洞府系统**：双阶段解锁 / 灵脉 / 灵田 / 悟道室 / 阵法 / 日志 |
| [UTILITY_AI_NPC.md](docs/UTILITY_AI_NPC.md) | **效用 AI**：NPC 自主决策 / 需求条 / 性格 / 情感 / 修炼 / 社交 |
| [WORLD_EVOLUTION.md](docs/WORLD_EVOLUTION.md) | **世界演化**：乱世开局 / 三阶段演化 / T2 宏观数据云 / JIT 惰性追溯 / LLM 编年史 |
| [DEV_ROADMAP.md](docs/DEV_ROADMAP.md) | **开发蓝图**：P0-P7 全模块优先级 / 依赖关系 / LLM 接入时机 / 工时估算 |

## 技术栈

- **框架**：Flutter + Riverpod
- **存储**：SQLite（sqflite）+ Isar/Hive（背包复杂对象）
- **字体**：Google Fonts（Ma Shan Zheng / Liu Jian Mao Cao）

## 快速开始

```bash
flutter pub get
flutter run
```
