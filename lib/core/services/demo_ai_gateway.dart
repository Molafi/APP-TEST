import 'dart:convert';
import 'dart:math';

import 'ai_gateway.dart';

/// Canned, deterministic AI responses used when no AI provider is configured
/// (demo mode) or in tests. Produces valid diagnosis JSON when [jsonMode] is
/// requested, and a helpful structured plant-care answer otherwise. This keeps
/// the app fully usable without any credentials.
class DemoAiGateway extends AiGateway {
  DemoAiGateway([Random? random]) : _random = random ?? Random();

  final Random _random;

  @override
  Future<String> generate(AiRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (request.jsonMode) {
      return _demoDiagnosisJson(request);
    }
    return _demoChatAnswer(request);
  }

  @override
  Stream<String> generateStream(AiRequest request) async* {
    // Diagnosis (JSON) needs the whole document — emit once.
    if (request.jsonMode) {
      yield await generate(request);
      return;
    }
    // Simulate token-by-token streaming of the canned chat answer so the
    // streaming UI can be exercised in demo mode.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final String full = _demoChatAnswer(request);
    final List<String> words = full.split(' ');
    final StringBuffer acc = StringBuffer();
    for (int i = 0; i < words.length; i++) {
      acc.write(i == 0 ? words[i] : ' ${words[i]}');
      yield acc.toString();
      await Future<void>.delayed(const Duration(milliseconds: 18));
    }
  }

  String _demoChatAnswer(AiRequest request) {
    final String q = request.userText.toLowerCase();
    final bool hasImage = request.image != null;

    if (hasImage && q.trim().isEmpty) {
      return "I can see the image you shared. Could you tell me what's "
          "concerning you about this plant? For example, are the leaves "
          "discoloured, spotted, or wilting?\n\n"
          "_(Demo response — configure Groq for full AI analysis.)_";
    }

    String assessment;
    if (q.contains('yellow')) {
      assessment =
          'Yellowing leaves often point to overwatering, poor drainage, or a '
          'nitrogen deficiency. Check whether the soil stays soggy and whether '
          'lower or newer leaves are affected first.';
    } else if (q.contains('water') || q.contains('basil')) {
      assessment =
          'Most herbs like basil prefer consistently moist (not soggy) soil. '
          'Water when the top 2–3 cm feels dry — often every 2–3 days in warm '
          'weather.';
    } else if (q.contains('succulent') || q.contains('soil')) {
      assessment =
          'Succulents need fast-draining soil. A mix of potting soil with '
          'coarse sand or perlite (about 1:1) prevents root rot.';
    } else {
      assessment =
          'Thanks for your question. Based on general plant-care principles, '
          'here is some practical guidance you can adapt to your conditions.';
    }

    final String ctx = request.context['temperature'] != null
        ? '\n\nYour local conditions (${request.context['city'] ?? 'your area'}, '
            '${request.context['temperature']}) are factored into this advice.'
        : '';

    return '🌿 **Assessment**\n$assessment\n\n'
        '💊 **Recommended actions**\n'
        '- Adjust watering to match the plant\'s needs and your climate.\n'
        '- Ensure the pot drains freely and the plant gets appropriate light.\n\n'
        '🌱 **Prevention & ongoing care**\n'
        '- Check soil moisture before watering rather than on a fixed schedule.\n'
        '- Inspect leaves weekly for early signs of pests or disease.\n\n'
        '🛡️ **Safety notes**\n'
        '- Keep fertilizers and any treatments away from children and pets.$ctx\n\n'
        '_AI suggestions may be inaccurate. For serious issues, consult a '
        'qualified horticulturist or local agricultural authority._';
  }

  String _demoDiagnosisJson(AiRequest request) {
    // Occasionally simulate a poor-quality image to exercise that UI path.
    final bool poor = _random.nextInt(6) == 0;
    if (poor) {
      return const JsonEncoder.withIndent('  ').convert({
        'isPlantRelated': true,
        'imageQuality': 'poor',
        'plantName': null,
        'scientificName': null,
        'whatISee': 'The image is a little blurry, so I can\'t be certain.',
        'possibleIssues': [],
        'treatmentSteps': [],
        'preventionTips': [],
        'safetyNotes': [],
        'confidence': 'low',
        'needsMoreInformation': true,
        'followUpQuestions': [
          'Could you retake the photo in bright, indirect light?',
          'Please fill the frame with the affected leaf or area.'
        ],
        'disclaimer':
            'AI suggestions may be inaccurate and do not replace a qualified '
                'botanist or agricultural professional.'
      });
    }

    return const JsonEncoder.withIndent('  ').convert({
      'isPlantRelated': true,
      'imageQuality': 'good',
      'plantName': 'Common houseplant (demo)',
      'scientificName': null,
      'whatISee':
          'Several leaves show yellowing at the margins with a few small brown '
              'spots. Overall the plant looks otherwise upright.',
      'possibleIssues': [
        {
          'name': 'Overwatering / root stress',
          'likelihood': 'medium',
          'reason': 'Marginal yellowing is commonly linked to soggy soil.'
        },
        {
          'name': 'Nutrient deficiency',
          'likelihood': 'low',
          'reason': 'Uniform yellowing can indicate low nitrogen.'
        }
      ],
      'treatmentSteps': [
        'Let the top few centimetres of soil dry before watering again.',
        'Ensure the pot has drainage holes and empty any saucer.',
        'Remove severely affected leaves with clean scissors.'
      ],
      'preventionTips': [
        'Water based on soil moisture, not a fixed schedule.',
        'Provide bright, indirect light and good airflow.'
      ],
      'safetyNotes': [
        'If using any fertilizer, follow label rates and keep away from pets.'
      ],
      'confidence': 'medium',
      'needsMoreInformation': false,
      'followUpQuestions': [
        'How often are you currently watering this plant?'
      ],
      'disclaimer':
          'AI suggestions may be inaccurate and do not replace a qualified '
              'botanist, horticulturist or local agricultural authority. This is '
              'a demo response.'
    });
  }
}
