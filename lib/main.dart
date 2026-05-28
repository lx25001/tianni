import 'package:flutter/material.dart';
import 'theme/colors.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/character_select_page.dart';
import 'pages/create_character_page.dart';
import 'pages/game_page.dart';

void main() {
  runApp(const TianniApp());
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
            page = const LoginPage();
            break;
          case '/register':
            page = const RegisterPage();
            break;
          case '/characters':
            page = const CharacterSelectPage();
            break;
          case '/create-character':
            page = const CreateCharacterPage();
            break;
          case '/game':
            page = const GamePage();
            break;
          default:
            page = const LoginPage();
        }
        return MaterialPageRoute(builder: (_) => page);
      },
    );
  }
}
