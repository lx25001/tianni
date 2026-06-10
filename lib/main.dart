import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/colors.dart';
import 'providers/game_clock_provider.dart';
import 'services/character_storage.dart';
import 'services/item_registry.dart';
import 'pages/advisory_page.dart';
import 'pages/character_select_page.dart';
import 'pages/create_character_page.dart';
import 'pages/game_page.dart';

/// 零动画路由（防止页面跳转闪烁）
PageRoute<T> _noAnimRoute<T>(Widget page, RouteSettings settings) {
  return PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (_, __, ___) => page,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GameClock.initEpoch();
  await CharacterStorage.ensureInitialized();
  await ItemRegistry.init();
  runApp(const ProviderScope(child: TianniApp()));
}

class TianniApp extends StatelessWidget {
  const TianniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '天逆',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: TianniColors.bg,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return _noAnimRoute(const AdvisoryPage(), settings);
          case '/characters':
            return _noAnimRoute(CharacterSelectPage(), settings);
          case '/create-character':
            return _noAnimRoute(const CreateCharacterPage(), settings);
          case '/game':
            final slotIndex = settings.arguments as int? ?? 0;
            return _noAnimRoute(GamePage(slotIndex: slotIndex), settings);
          default:
            return _noAnimRoute(CharacterSelectPage(), settings);
        }
      },
    );
  }
}
