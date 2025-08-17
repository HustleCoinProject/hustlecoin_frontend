import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hustlecoin/leaderboard.dart';
import 'home_screen.dart';
import 'signup.dart';
import 'shop.dart';
import 'quiz.dart';
import 'edit_profile.dart';
import 'start.dart';
import 'login.dart';
import 'land_map.dart';
import 'app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hustle Coin',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.angolaBlack,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home:
          LandMapScreen(), // LeaderboardScreen(), // StartScreen(), // EditProfileScreen(), // QuizScreen(), // ShopScreen(), // SignUpScreen(), // HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
