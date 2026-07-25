import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/environment.dart';
import '../../../core/services/local_cache_service.dart';
import '../../../core/theme/locale_provider.dart';
import '../../auth/application/auth_provider.dart';
import '../../chat/application/conversations_provider.dart';
import '../../chat/data/chat_repository.dart';
import '../../chat/data/firestore_chat_repository.dart';
import '../../chat/data/local_chat_repository.dart';
import '../../diagnosis/application/diagnosis_provider.dart';
import '../../plants/application/plants_provider.dart';
import '../../reminders/application/reminder_provider.dart';
import 'settings_provider.dart';

/// Builds a portable JSON export of everything the app stores for the user
/// (profile, conversations + messages, diagnoses, plants, reminders). Used by
/// the "Download my data" action to satisfy data-portability expectations.
class DataExporter {
  DataExporter(this._ref);

  final Ref _ref;

  ChatRepository _chatRepoFor(String chatId) {
    final user = _ref.read(currentUserProvider);
    if (!Environment.isDemo && user != null) {
      return FirestoreChatRepository(uid: user.uid, chatId: chatId);
    }
    return LocalChatRepository(_ref.read(localCacheServiceProvider),
        chatId: chatId);
  }

  Future<String> buildJson() async {
    final user = _ref.read(currentUserProvider);

    final conversationsMeta =
        await _ref.read(conversationsRepositoryProvider).list();
    final List<Map<String, dynamic>> conversations = [];
    for (final c in conversationsMeta) {
      final messages = await _chatRepoFor(c.id).loadMessages();
      conversations.add({
        'id': c.id,
        'title': c.title,
        'messages': messages
            .map((m) => {
                  'role': m.role.name,
                  'text': m.text,
                  'createdAt': m.createdAt.toIso8601String(),
                })
            .toList(),
      });
    }

    final diagnoses = await _ref.read(diagnosisRepositoryProvider).load();
    final plants = await _ref.read(plantsRepositoryProvider).load();
    final reminders = _ref.read(reminderControllerProvider);

    final Map<String, dynamic> export = {
      'app': 'PlantSense AI',
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': {
        'uid': user?.uid,
        'email': user?.email,
        'displayName': user?.displayName,
        'locale': _ref.read(localeProvider)?.languageCode,
        'unitSystem': _ref.read(unitSystemProvider).id,
      },
      'conversations': conversations,
      'diagnoses': diagnoses
          .map((d) => {
                ...d.toMap(),
                'createdAt': d.createdAt?.toIso8601String(),
              })
          .toList(),
      'plants': plants.map((p) => p.toMap()).toList(),
      'reminders': reminders.map((r) => r.toMap()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(export);
  }
}

final dataExporterProvider = Provider<DataExporter>((ref) => DataExporter(ref));
