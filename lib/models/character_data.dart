/// 角色数据模型
class CharacterData {
  final String surname;
  final String givenName;
  final String fullName; // 姓+名
  final String rootElement;
  final String rootPurity;
  final double purityRate;

  // 六维
  final int con, spi, qi, dao, ins, bon;

  // 当前修为
  final int realmIndex; // 0-based
  final int layer;      // 1-based, 1-9
  final int xpPercent;  // 0-100

  // 货币
  final int spiritStones;

  // 离线
  final int lastSaveTs; // 毫秒时间戳

  CharacterData({
    required this.surname,
    required this.givenName,
    required this.rootElement,
    required this.rootPurity,
    required this.purityRate,
    required this.con,
    required this.spi,
    required this.qi,
    required this.dao,
    required this.ins,
    required this.bon,
    this.realmIndex = 0,
    this.layer = 1,
    this.xpPercent = 0,
    this.spiritStones = 5,
    this.lastSaveTs = 0,
  }) : fullName = '$surname$givenName';

  factory CharacterData.fromJson(Map<String, dynamic> json) {
    return CharacterData(
      surname: json['surname'] as String,
      givenName: json['givenName'] as String,
      rootElement: json['rootElement'] as String,
      rootPurity: json['rootPurity'] as String,
      purityRate: (json['purityRate'] as num).toDouble(),
      con: json['con'] as int,
      spi: json['spi'] as int,
      qi: json['qi'] as int,
      dao: json['dao'] as int,
      ins: json['ins'] as int,
      bon: json['bon'] as int,
      realmIndex: json['realmIndex'] as int? ?? 0,
      layer: json['layer'] as int? ?? 1,
      xpPercent: json['xpPercent'] as int? ?? 0,
      spiritStones: json['spiritStones'] as int? ?? 5,
      lastSaveTs: json['lastSaveTs'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'surname': surname,
    'givenName': givenName,
    'rootElement': rootElement,
    'rootPurity': rootPurity,
    'purityRate': purityRate,
    'con': con, 'spi': spi, 'qi': qi,
    'dao': dao, 'ins': ins, 'bon': bon,
    'realmIndex': realmIndex,
    'layer': layer,
    'xpPercent': xpPercent,
    'spiritStones': spiritStones,
    'lastSaveTs': lastSaveTs,
  };

  static const List<String> realms = [
    '炼气期', '筑基期', '金丹期', '元婴期', '化神期', '合体期',
    '大乘期', '渡劫期', '飞升期', '地仙境', '天仙境', '真仙境',
    '玄仙境', '金仙境', '太乙境', '大罗境', '混元境', '鸿蒙境',
    '混沌境', '主宰境', '虚空境', '造化境', '道祖境', '永恒境',
  ];

  String get realmName => realms[realmIndex];

  static const int maxLayers = 9;

  CharacterData copyWith({
    String? surname, String? givenName,
    String? rootElement, String? rootPurity, double? purityRate,
    int? con, int? spi, int? qi, int? dao, int? ins, int? bon,
    int? realmIndex, int? layer, int? xpPercent,
    int? spiritStones, int? lastSaveTs,
  }) {
    return CharacterData(
      surname: surname ?? this.surname,
      givenName: givenName ?? this.givenName,
      rootElement: rootElement ?? this.rootElement,
      rootPurity: rootPurity ?? this.rootPurity,
      purityRate: purityRate ?? this.purityRate,
      con: con ?? this.con,
      spi: spi ?? this.spi,
      qi: qi ?? this.qi,
      dao: dao ?? this.dao,
      ins: ins ?? this.ins,
      bon: bon ?? this.bon,
      realmIndex: realmIndex ?? this.realmIndex,
      layer: layer ?? this.layer,
      xpPercent: xpPercent ?? this.xpPercent,
      spiritStones: spiritStones ?? this.spiritStones,
      lastSaveTs: lastSaveTs ?? this.lastSaveTs,
    );
  }
}
