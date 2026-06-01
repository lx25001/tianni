import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 时辰信息
class Shichen {
  final int index;    // 0-11
  final String name;
  final String element;
  final String period;
  final double yangRatio;

  const Shichen({
    required this.index,
    required this.name,
    required this.element,
    required this.period,
    required this.yangRatio,
  });

  static const List<Shichen> all = [
    Shichen(index: 0, name: '子时', element: '水', period: '深夜', yangRatio: 0.0),
    Shichen(index: 1, name: '丑时', element: '土', period: '凌晨', yangRatio: 0.1),
    Shichen(index: 2, name: '寅时', element: '木', period: '黎明前', yangRatio: 0.25),
    Shichen(index: 3, name: '卯时', element: '木', period: '日出', yangRatio: 0.45),
    Shichen(index: 4, name: '辰时', element: '土', period: '早晨', yangRatio: 0.6),
    Shichen(index: 5, name: '巳时', element: '火', period: '上午', yangRatio: 0.75),
    Shichen(index: 6, name: '午时', element: '火', period: '正午', yangRatio: 1.0),
    Shichen(index: 7, name: '未时', element: '土', period: '下午', yangRatio: 0.8),
    Shichen(index: 8, name: '申时', element: '金', period: '傍晚', yangRatio: 0.55),
    Shichen(index: 9, name: '酉时', element: '金', period: '日落', yangRatio: 0.4),
    Shichen(index: 10, name: '戌时', element: '土', period: '入夜', yangRatio: 0.2),
    Shichen(index: 11, name: '亥时', element: '水', period: '夜晚', yangRatio: 0.05),
  ];
}

/// 节日定义（按天逆历月日，360天/年）
class Festival {
  final int month;
  final int day;
  final String name;
  final String desc;

  const Festival({
    required this.month,
    required this.day,
    required this.name,
    required this.desc,
  });

  static const List<Festival> all = [
    Festival(month: 1, day: 1, name: '元日', desc: '天逆历新年伊始，万物更新'),
    Festival(month: 1, day: 15, name: '上元', desc: '元宵灯火，团圆之夜'),
    Festival(month: 2, day: 2, name: '龙抬头', desc: '春龙昂首，农耕伊始'),
    Festival(month: 3, day: 5, name: '清明', desc: '祭祖踏青，缅怀先人'),
    Festival(month: 4, day: 8, name: '佛诞', desc: '佛祖诞辰，普度众生'),
    Festival(month: 5, day: 5, name: '端午', desc: '龙舟竞渡，驱邪避疫'),
    Festival(month: 6, day: 6, name: '天贶', desc: '晒经曝书，灵气充盈'),
    Festival(month: 7, day: 7, name: '七夕', desc: '牛郎织女，鹊桥相会'),
    Festival(month: 7, day: 15, name: '中元', desc: '鬼门大开，阴气弥漫'),
    Festival(month: 8, day: 15, name: '中秋', desc: '月圆人圆，丹桂飘香'),
    Festival(month: 9, day: 9, name: '重阳', desc: '登高望远，敬老祈福'),
    Festival(month: 10, day: 15, name: '下元', desc: '水官解厄，消灾祈福'),
    Festival(month: 11, day: 22, name: '冬至', desc: '阴极阳生，一阳来复'),
    Festival(month: 12, day: 23, name: '祭灶', desc: '灶神上天，言人间善恶'),
    Festival(month: 12, day: 30, name: '除夕', desc: '辞旧迎新，除旧布新'),
  ];

  static Festival? find(int month, int day) {
    try {
      return all.firstWhere((f) => f.month == month && f.day == day);
    } catch (_) {
      return null;
    }
  }
}

/// 游戏时间状态
class GameTime {
  final int year;
  final int month;
  final int day;
  final int dayOfYear;
  final Shichen shichen;
  final String season;
  final Festival? festival;

  const GameTime({
    required this.year,
    required this.month,
    required this.day,
    required this.dayOfYear,
    required this.shichen,
    required this.season,
    this.festival,
  });

  static const _seasons = ['春', '夏', '秋', '冬'];

  factory GameTime.fromRealSeconds(int realSec) {
    final gameDays = realSec ~/ 240;
    final year = 1 + gameDays ~/ 360;
    final dayOfYear = gameDays % 360;
    final month = 1 + dayOfYear ~/ 30;
    final day = 1 + dayOfYear % 30;
    final season = _seasons[(month - 1) ~/ 3 % 4];
    final secOfDay = realSec % 240;
    final si = (secOfDay ~/ 20) % 12;
    final festival = Festival.find(month, day);

    return GameTime(
      year: year,
      month: month,
      day: day,
      dayOfYear: dayOfYear,
      shichen: Shichen.all[si],
      season: season,
      festival: festival,
    );
  }

  String get formatted => '天逆${year}年 ${month}月${day}日 · $season · ${shichen.name}';
}

/// GameClock Notifier — 持久化 + 实时更新
class GameClock extends StateNotifier<GameTime> {
  static const _keyEpochMs = 'game_epoch_ms';
  static final DateTime _realEpoch = DateTime(2025, 1, 1, 6, 0, 0); // UTC+8 午时起点
  Timer? _timer;

  GameClock() : super(_nowFromEpoch(_realEpoch)) {
    _restore();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = _now();
    });
  }

  /// 首次启动时保存 epoch，后续从持久化读取
  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMs = prefs.getInt(_keyEpochMs);
    if (savedMs == null) {
      // 首次启动：记录当前真实时间为 epoch
      await prefs.setInt(_keyEpochMs, DateTime.now().millisecondsSinceEpoch);
      // 定位到 1月1日 午时(6): 基础偏移 = 6 × 20s = 120s
      // 初始显示即时更新
    }
  }

  GameTime _now() {
    // 从持久化的 epoch 计算偏移
    // 使用一个简单的静态变量缓存
    return _nowFromEpoch(_realEpoch);
  }

  static int? _cachedEpochMs;
  static GameTime _nowFromEpoch(DateTime fallback) {
    final epochMs = _cachedEpochMs ?? fallback.millisecondsSinceEpoch;
    final realSec = (DateTime.now().millisecondsSinceEpoch - epochMs) ~/ 1000;
    // 偏移 120s 使初始时刻为午时（第6个时辰）
    return GameTime.fromRealSeconds(realSec + 120);
  }

  /// 应在 Provider 创建后调用一次，加载持久化 epoch
  static Future<void> initEpoch() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedEpochMs = prefs.getInt(_keyEpochMs);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// 先初始化 epoch，再提供
final gameClockProvider = StateNotifierProvider<GameClock, GameTime>((ref) {
  return GameClock();
});
