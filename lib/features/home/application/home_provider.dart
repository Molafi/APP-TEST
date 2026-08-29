import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom-navigation tab indices. The order here must match the IndexedStack
/// children and NavigationBar destinations in home_screen.dart.
class HomeTab {
  const HomeTab._();
  static const int chat = 0;
  static const int diagnose = 1;
  static const int georesearch = 2;
  static const int weather = 3;
  static const int profile = 4;
}

/// Currently selected bottom-nav tab. Kept in state so tapping the weather chip
/// can switch tabs from anywhere.
final homeTabProvider = StateProvider<int>((ref) => HomeTab.chat);

/// A pending prompt handed from a diagnosis "Ask follow-up" action to the chat
/// tab. Consumed (set back to null) by the chat screen once applied.
final chatFollowUpProvider = StateProvider<String?>((ref) => null);
