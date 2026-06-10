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
        Widget page;
        switch (settings.name) {
          case '/':
            page = const AdvisoryPage();
            break;
          case '/characters':
            page = CharacterSelectPage();
            break;
          case '/create-character':
            page = const CreateCharacterPage();
            break;
          case '/game':
            final slotIndex = settings.arguments as int? ?? 0;
            page = GamePage(slotIndex: slotIndex);
            break;
          default:
            page = CharacterSelectPage();
        }
        return MaterialPageRoute(builder: (_) => page);
      },
    );
  }
}
