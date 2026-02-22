import 'dart:math';
import 'package:flutter/foundation.dart';

/// AI Natural Language Processing Engine — Features 26-35
/// Voice commands, conversational AI, and natural language automation.
///
/// Features:
/// 26. Voice command processing
/// 27. Natural language device control
/// 28. Conversational AI assistant
/// 29. Smart home status summarization
/// 30. Alert message generation
/// 31. Context-aware responses
/// 32. Multi-language support
/// 33. Sentiment analysis for user feedback
/// 34. Voice-activated scenes
/// 35. Natural language scheduling

class AINLPEngine extends ChangeNotifier {
  final Random _random = Random();
  bool _isInitialized = false;
  final List<Map<String, dynamic>> _conversationHistory = [];
  String _currentLanguage = 'en';

  bool get isInitialized => _isInitialized;
  String get currentLanguage => _currentLanguage;
  List<Map<String, dynamic>> get conversationHistory =>
      List.unmodifiable(_conversationHistory);

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'lights_on': 'Turning on the lights',
      'lights_off': 'Turning off the lights',
      'temp_set': 'Setting temperature to',
      'status': 'Here\'s your home status',
      'greeting': 'Hello! How can I help you with your smart home?',
      'goodbye': 'Goodbye! Stay comfortable!',
      'not_understood': 'I\'m not sure I understand. Could you rephrase that?',
    },
    'es': {
      'lights_on': 'Encendiendo las luces',
      'lights_off': 'Apagando las luces',
      'temp_set': 'Ajustando la temperatura a',
      'status': 'Aquí está el estado de tu hogar',
      'greeting': '¡Hola! ¿Cómo puedo ayudarte con tu hogar inteligente?',
      'goodbye': '¡Adiós! ¡Mantente cómodo!',
      'not_understood': 'No estoy seguro de entender. ¿Podrías reformularlo?',
    },
    'fr': {
      'lights_on': 'Allumer les lumières',
      'lights_off': 'Éteindre les lumières',
      'temp_set': 'Réglage de la température à',
      'status': 'Voici l\'état de votre maison',
      'greeting': 'Bonjour! Comment puis-je vous aider avec votre maison intelligente?',
      'goodbye': 'Au revoir! Restez confortable!',
      'not_understood': 'Je ne suis pas sûr de comprendre. Pourriez-vous reformuler?',
    },
    'de': {
      'lights_on': 'Lichter einschalten',
      'lights_off': 'Lichter ausschalten',
      'temp_set': 'Temperatur einstellen auf',
      'status': 'Hier ist Ihr Hausstatus',
      'greeting': 'Hallo! Wie kann ich Ihnen mit Ihrem Smart Home helfen?',
      'goodbye': 'Auf Wiedersehen! Bleiben Sie bequem!',
      'not_understood': 'Ich bin mir nicht sicher, ob ich das verstehe. Könnten Sie es umformulieren?',
    },
    'hi': {
      'lights_on': 'लाइट्स चालू कर रहा हूँ',
      'lights_off': 'लाइट्स बंद कर रहा हूँ',
      'temp_set': 'तापमान सेट कर रहा हूँ',
      'status': 'यहां आपके घर की स्थिति है',
      'greeting': 'नमस्ते! मैं आपके स्मार्ट होम में कैसे मदद कर सकता हूँ?',
      'goodbye': 'अलविदा! आरामदायक रहें!',
      'not_understood': 'मुझे समझ नहीं आया। कृपया दोबारा कहें।',
    },
    'te': {
      'lights_on': 'లైట్లు ఆన్ చేస్తున్నాను',
      'lights_off': 'లైట్లు ఆఫ్ చేస్తున్నాను',
      'temp_set': 'ఉష్ణోగ్రత సెట్ చేస్తున్నాను',
      'status': 'మీ ఇంటి స్థితి ఇక్కడ ఉంది',
      'greeting': 'నమస్కారం! మీ స్మార్ట్ హోమ్‌లో నేను ఎలా సహాయం చేయగలను?',
      'goodbye': 'వీడ్కోలు! సుఖంగా ఉండండి!',
      'not_understood': 'నాకు అర్థం కాలేదు. దయచేసి మళ్లీ చెప్పండి.',
    },
  };

  // Intent patterns for NLP
  static const _intentPatterns = {
    'turn_on': ['turn on', 'switch on', 'enable', 'activate', 'start', 'open'],
    'turn_off': ['turn off', 'switch off', 'disable', 'deactivate', 'stop', 'close'],
    'set_temperature': ['set temp', 'temperature to', 'make it', 'set to', 'degrees'],
    'status': ['status', 'how is', 'what\'s', 'tell me', 'report', 'show me'],
    'scene': ['scene', 'movie mode', 'party mode', 'sleep mode', 'morning', 'evening', 'night', 'romantic'],
    'schedule': ['schedule', 'at', 'every', 'daily', 'tomorrow', 'tonight', 'set alarm', 'remind'],
    'brightness': ['dim', 'bright', 'brightness', 'darker', 'lighter'],
    'color': ['color', 'colour', 'red', 'blue', 'green', 'warm', 'cool', 'white'],
    'lock': ['lock', 'unlock', 'secure', 'unsecure'],
    'music': ['play', 'music', 'song', 'volume', 'mute', 'unmute'],
  };

  // Device name mapping
  static const _deviceAliases = {
    'living room light': 'living_room_light',
    'bedroom light': 'bedroom_light',
    'kitchen light': 'kitchen_light',
    'bathroom light': 'bathroom_light',
    'ac': 'air_conditioner',
    'air conditioner': 'air_conditioner',
    'fan': 'ceiling_fan',
    'tv': 'television',
    'television': 'television',
    'door': 'front_door',
    'garage': 'garage_door',
    'heater': 'water_heater',
    'camera': 'security_camera',
    'all lights': 'all_lights',
    'everything': 'all_devices',
  };

  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;
    notifyListeners();
  }

  // ─── Feature 26: Voice Command Processing ─────────────────────────

  Map<String, dynamic> processVoiceCommand(String rawInput) {
    final input = rawInput.toLowerCase().trim();
    final tokens = input.split(RegExp(r'\s+'));

    // Extract intent
    String? detectedIntent;
    double intentConfidence = 0;

    for (final entry in _intentPatterns.entries) {
      for (final pattern in entry.value) {
        if (input.contains(pattern)) {
          final confidence = pattern.split(' ').length / tokens.length;
          if (confidence > intentConfidence) {
            detectedIntent = entry.key;
            intentConfidence = min(0.99, 0.7 + confidence * 0.3);
          }
        }
      }
    }

    // Extract device
    String? detectedDevice;
    for (final entry in _deviceAliases.entries) {
      if (input.contains(entry.key)) {
        detectedDevice = entry.value;
        break;
      }
    }

    // Extract numeric value
    double? numericValue;
    final numMatch = RegExp(r'(\d+\.?\d*)').firstMatch(input);
    if (numMatch != null) {
      numericValue = double.tryParse(numMatch.group(1)!);
    }

    return {
      'raw_input': rawInput,
      'processed': true,
      'intent': detectedIntent ?? 'unknown',
      'intent_confidence': double.parse(intentConfidence.toStringAsFixed(2)),
      'device': detectedDevice,
      'value': numericValue,
      'tokens': tokens,
      'response': _generateResponse(detectedIntent, detectedDevice, numericValue),
      'action_executed': detectedIntent != null && detectedDevice != null,
      'processing_time_ms': 15 + _random.nextInt(20),
    };
  }

  String _generateResponse(String? intent, String? device, double? value) {
    final t = _translations[_currentLanguage] ?? _translations['en']!;
    if (intent == null) return t['not_understood']!;

    final deviceName = device?.replaceAll('_', ' ') ?? 'device';

    switch (intent) {
      case 'turn_on':
        return '${t['lights_on']!.replaceAll('lights', deviceName)} ✓';
      case 'turn_off':
        return '${t['lights_off']!.replaceAll('lights', deviceName)} ✓';
      case 'set_temperature':
        return '${t['temp_set']} ${value?.round() ?? 24}°C ✓';
      case 'status':
        return t['status']!;
      default:
        return 'Processing $intent for $deviceName...';
    }
  }

  // ─── Feature 27: Natural Language Device Control ───────────────────

  Map<String, dynamic> naturalLanguageControl(String command) {
    final parsed = processVoiceCommand(command);
    final intent = parsed['intent'] as String;
    final device = parsed['device'] as String?;
    final value = parsed['value'] as double?;

    final actions = <Map<String, dynamic>>[];

    if (intent == 'turn_on' && device != null) {
      if (device == 'all_lights') {
        actions.addAll([
          {'device': 'living_room_light', 'action': 'ON', 'status': 'executed'},
          {'device': 'bedroom_light', 'action': 'ON', 'status': 'executed'},
          {'device': 'kitchen_light', 'action': 'ON', 'status': 'executed'},
          {'device': 'bathroom_light', 'action': 'ON', 'status': 'executed'},
        ]);
      } else {
        actions.add({'device': device, 'action': 'ON', 'status': 'executed'});
      }
    } else if (intent == 'turn_off' && device != null) {
      actions.add({'device': device, 'action': 'OFF', 'status': 'executed'});
    } else if (intent == 'set_temperature') {
      actions.add({
        'device': 'air_conditioner',
        'action': 'SET_TEMP',
        'value': value ?? 24,
        'status': 'executed',
      });
    } else if (intent == 'brightness') {
      actions.add({
        'device': device ?? 'all_lights',
        'action': 'SET_BRIGHTNESS',
        'value': value ?? 70,
        'status': 'executed',
      });
    }

    return {
      'command': command,
      'understood': intent != 'unknown',
      'actions': actions,
      'total_actions': actions.length,
      'all_successful': actions.every((a) => a['status'] == 'executed'),
      'response_text': parsed['response'],
      'alternative_interpretations': intent == 'unknown'
          ? [
              'Did you mean "Turn on the living room light"?',
              'Did you mean "Set temperature to 24"?',
              'Did you mean "Show home status"?',
            ]
          : [],
    };
  }

  // ─── Feature 28: Conversational AI Assistant ──────────────────────

  Map<String, dynamic> chat(String userMessage) {
    final input = userMessage.toLowerCase().trim();
    final t = _translations[_currentLanguage] ?? _translations['en']!;

    String response;
    String category;
    Map<String, dynamic>? actionTaken;

    // Greeting detection
    if (RegExp(r'\b(hi|hello|hey|good morning|good evening|namaste)\b').hasMatch(input)) {
      response = t['greeting']!;
      category = 'greeting';
    }
    // Farewell
    else if (RegExp(r'\b(bye|goodbye|good night|see you|thanks)\b').hasMatch(input)) {
      response = t['goodbye']!;
      category = 'farewell';
    }
    // Status inquiry
    else if (RegExp(r'\b(status|how|what|show|tell|report)\b').hasMatch(input)) {
      response = _generateStatusSummary();
      category = 'status_inquiry';
    }
    // Energy question
    else if (RegExp(r'\b(energy|power|electric|bill|usage|consume|cost)\b').hasMatch(input)) {
      response = _generateEnergyResponse();
      category = 'energy_inquiry';
    }
    // Device control attempt
    else if (RegExp(r'\b(turn|switch|set|dim|bright|lock|open|close)\b').hasMatch(input)) {
      final controlResult = naturalLanguageControl(userMessage);
      response = controlResult['response_text'] as String;
      category = 'device_control';
      actionTaken = controlResult;
    }
    // Weather related
    else if (RegExp(r'\b(weather|rain|temperature outside|forecast)\b').hasMatch(input)) {
      response = 'Current conditions: ${22 + _random.nextInt(10)}°C, '
          '${['Sunny', 'Partly Cloudy', 'Clear', 'Overcast'][_random.nextInt(4)]}. '
          'Indoor temp is comfortable at ${24 + _random.nextInt(3)}°C.';
      category = 'weather';
    }
    // Suggestion request
    else if (RegExp(r'\b(suggest|recommend|idea|help|optimize|improve)\b').hasMatch(input)) {
      response = _generateSuggestionResponse();
      category = 'suggestions';
    }
    // Default
    else {
      response = t['not_understood']!;
      category = 'unknown';
    }

    final entry = {
      'user_message': userMessage,
      'ai_response': response,
      'category': category,
      'timestamp': DateTime.now().toIso8601String(),
      'action_taken': actionTaken,
      'confidence': category == 'unknown' ? 0.3 : 0.85 + _random.nextDouble() * 0.1,
      'language': _currentLanguage,
    };

    _conversationHistory.add(entry);
    notifyListeners();

    return entry;
  }

  String _generateStatusSummary() {
    return 'Your home is running smoothly. Temperature: ${23 + _random.nextInt(4)}°C, '
        'Humidity: ${45 + _random.nextInt(15)}%, '
        '${3 + _random.nextInt(5)} devices active, '
        'Energy usage today: ${8 + _random.nextInt(12)} kWh, '
        'All sensors normal, security system armed.';
  }

  String _generateEnergyResponse() {
    final todayKwh = 8 + _random.nextInt(12);
    final avgKwh = 15;
    final comparison = todayKwh < avgKwh ? 'below' : 'above';
    return 'Today\'s energy usage: $todayKwh kWh ($comparison your ${avgKwh} kWh daily average). '
        'Top consumers: AC (${3 + _random.nextInt(3)} kWh), '
        'Water Heater (${2 + _random.nextInt(2)} kWh), '
        'Lighting (${1 + _random.nextInt(2)} kWh). '
        'Estimated bill this month: ₹${1200 + _random.nextInt(800)}.';
  }

  String _generateSuggestionResponse() {
    final suggestions = [
      'Try scheduling your AC to turn off 30 minutes before you usually wake up — the room stays cool and you save energy.',
      'I noticed lights were left on in empty rooms 3 times this week. Want me to auto-turn-off lights when rooms are empty?',
      'Your water heater runs during peak hours. Shifting it to off-peak could save ₹150/month.',
      'Consider setting up a "Goodnight" scene to turn off all lights and lock doors with one command.',
      'Your energy usage drops 20% on days with natural ventilation. Today\'s weather is ideal for open windows!',
    ];
    return suggestions[_random.nextInt(suggestions.length)];
  }

  // ─── Feature 29: Smart Home Status Summarization ──────────────────

  Map<String, dynamic> generateStatusSummary() {
    final criticalAlerts = _random.nextInt(2);
    final warnings = _random.nextInt(3);

    return {
      'summary_text': _generateStatusSummary(),
      'detailed_status': {
        'climate': {
          'temperature': '${23 + _random.nextInt(4)}°C',
          'humidity': '${45 + _random.nextInt(15)}%',
          'air_quality_index': 40 + _random.nextInt(40),
          'ac_status': _random.nextBool() ? 'ON (24°C)' : 'OFF',
        },
        'energy': {
          'current_draw_watts': 800 + _random.nextInt(1500),
          'today_kwh': 8 + _random.nextInt(12),
          'solar_generation_kwh': 2 + _random.nextInt(5),
          'grid_status': 'connected',
        },
        'security': {
          'alarm': 'armed',
          'cameras': 'all online',
          'doors': 'all locked',
          'last_motion': '${_random.nextInt(30)} minutes ago (Kitchen)',
        },
        'devices': {
          'total': 15 + _random.nextInt(5),
          'online': 14 + _random.nextInt(5),
          'offline': _random.nextInt(2),
          'active': 3 + _random.nextInt(5),
        },
      },
      'alerts': {
        'critical': criticalAlerts,
        'warnings': warnings,
        'info': 1 + _random.nextInt(3),
      },
      'health_score': 90 + _random.nextInt(8),
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  // ─── Feature 30: Alert Message Generation ─────────────────────────

  Map<String, dynamic> generateAlertMessage(String alertType, Map<String, dynamic> data) {
    String title;
    String message;
    String priority;
    String emoji;

    switch (alertType) {
      case 'high_temperature':
        title = 'Temperature Alert';
        message = 'Temperature in ${data['room'] ?? 'Home'} has reached ${data['value'] ?? 32}°C, '
            'which is ${((data['value'] as num?) ?? 32).toInt() - 28}°C above comfort zone.';
        priority = 'high';
        emoji = '🌡️';
        break;
      case 'power_surge':
        title = 'Power Surge Detected';
        message = 'Voltage spike of ${data['voltage'] ?? 280}V detected. '
            'Surge protector ${data['protected'] == true ? 'activated' : 'NOT activated'}.';
        priority = 'critical';
        emoji = '⚡';
        break;
      case 'water_leak':
        title = 'Water Leak Warning';
        message = 'Unusual water flow detected in ${data['zone'] ?? 'kitchen'}. '
            'Estimated ${data['rate'] ?? 2} L/h continuous flow for ${data['hours'] ?? 3} hours.';
        priority = 'high';
        emoji = '💧';
        break;
      case 'security_breach':
        title = 'Security Alert';
        message = 'Unexpected motion detected at ${data['location'] ?? 'front door'} '
            'while home is in AWAY mode.';
        priority = 'critical';
        emoji = '🚨';
        break;
      case 'device_offline':
        title = 'Device Offline';
        message = '${data['device'] ?? 'Smart Camera'} has gone offline. '
            'Last seen ${data['last_seen'] ?? '15 minutes'} ago.';
        priority = 'medium';
        emoji = '📡';
        break;
      default:
        title = 'Smart Home Notification';
        message = data['message'] as String? ?? 'An event requires your attention.';
        priority = 'low';
        emoji = 'ℹ️';
    }

    return {
      'title': '$emoji $title',
      'message': message,
      'priority': priority,
      'alert_type': alertType,
      'actionable': priority == 'critical' || priority == 'high',
      'suggested_actions': _suggestAlertActions(alertType),
      'auto_action_taken': _getAutoAction(alertType),
      'timestamp': DateTime.now().toIso8601String(),
      'ttl_minutes': priority == 'critical' ? 0 : priority == 'high' ? 30 : 120,
    };
  }

  List<String> _suggestAlertActions(String alertType) {
    switch (alertType) {
      case 'high_temperature':
        return ['Turn on AC', 'Open windows', 'Check thermostat'];
      case 'power_surge':
        return ['Check appliances', 'Call electrician', 'Review surge log'];
      case 'water_leak':
        return ['Shut off water valve', 'Check pipes', 'Call plumber'];
      case 'security_breach':
        return ['View camera', 'Call police', 'Trigger alarm'];
      default:
        return ['Acknowledge', 'Dismiss'];
    }
  }

  String? _getAutoAction(String alertType) {
    switch (alertType) {
      case 'power_surge':
        return 'Surge protector activated automatically';
      case 'security_breach':
        return 'Camera recording started, outdoor lights activated';
      case 'water_leak':
        return 'Smart valve closure initiated';
      default:
        return null;
    }
  }

  // ─── Feature 31: Context-Aware Responses ──────────────────────────

  Map<String, dynamic> getContextAwareResponse(String query) {
    final hour = DateTime.now().hour;
    final timeOfDay = hour < 6
        ? 'night'
        : hour < 12
            ? 'morning'
            : hour < 17
                ? 'afternoon'
                : hour < 21
                    ? 'evening'
                    : 'night';

    final isWeekend = DateTime.now().weekday >= 6;
    final context = {
      'time_of_day': timeOfDay,
      'is_weekend': isWeekend,
      'current_temp': 24 + _random.nextInt(6),
      'people_home': 1 + _random.nextInt(4),
      'devices_active': 3 + _random.nextInt(5),
    };

    String response;
    List<String> contextFactors = [];

    if (query.toLowerCase().contains('goodnight') || query.toLowerCase().contains('good night')) {
      response = 'Goodnight! I\'ll set up your sleep environment: '
          'Turning off living room lights, setting bedroom AC to 22°C, '
          'arming security system, and enabling Do Not Disturb mode.';
      contextFactors = ['time_of_day=night', 'sleep_routine'];
    } else if (query.toLowerCase().contains('good morning') || query.toLowerCase().contains('wake up')) {
      response = 'Good morning! Opening bedroom curtains, '
          'starting coffee maker, setting lights to energizing mode (5000K), '
          'and here\'s your morning briefing: ${_generateStatusSummary()}';
      contextFactors = ['time_of_day=morning', 'wake_routine'];
    } else if (query.toLowerCase().contains('i\'m leaving') || query.toLowerCase().contains('going out')) {
      response = 'Have a great ${isWeekend ? 'weekend outing' : 'day'}! '
          'I\'ll switch to Away mode: All lights off, AC set to eco mode (28°C), '
          'security cameras armed, and robot vacuum starting its cycle.';
      contextFactors = ['departure_detected', 'away_mode'];
    } else if (query.toLowerCase().contains('i\'m home') || query.toLowerCase().contains('i\'m back')) {
      response = 'Welcome home! Setting up your $timeOfDay preferences: '
          'Lights to ${timeOfDay == 'evening' ? 'warm (3000K)' : 'bright (4500K)'}, '
          'AC to ${context['current_temp']}°C, disarming security.';
      contextFactors = ['arrival_detected', 'home_mode', 'time_preference=$timeOfDay'];
    } else {
      response = _generateStatusSummary();
      contextFactors = ['general_query'];
    }

    return {
      'query': query,
      'response': response,
      'context_used': context,
      'context_factors': contextFactors,
      'personalized': true,
      'response_type': 'context_aware',
    };
  }

  // ─── Feature 32: Multi-Language Support ───────────────────────────

  Map<String, dynamic> setLanguage(String languageCode) {
    final supported = _translations.keys.toList();
    if (supported.contains(languageCode)) {
      _currentLanguage = languageCode;
      notifyListeners();
      return {
        'success': true,
        'language': languageCode,
        'greeting': _translations[languageCode]!['greeting'],
        'supported_languages': supported,
      };
    }
    return {
      'success': false,
      'error': 'Language "$languageCode" not supported',
      'supported_languages': supported,
    };
  }

  Map<String, dynamic> getSupportedLanguages() {
    return {
      'languages': [
        {'code': 'en', 'name': 'English', 'native': 'English'},
        {'code': 'es', 'name': 'Spanish', 'native': 'Español'},
        {'code': 'fr', 'name': 'French', 'native': 'Français'},
        {'code': 'de', 'name': 'German', 'native': 'Deutsch'},
        {'code': 'hi', 'name': 'Hindi', 'native': 'हिन्दी'},
        {'code': 'te', 'name': 'Telugu', 'native': 'తెలుగు'},
      ],
      'current': _currentLanguage,
    };
  }

  // ─── Feature 33: Sentiment Analysis ───────────────────────────────

  Map<String, dynamic> analyzeSentiment(String text) {
    final input = text.toLowerCase();
    double score = 0; // -1 to 1
    final keywords = <String>[];

    // Positive words
    final positiveWords = ['great', 'good', 'love', 'amazing', 'perfect', 'awesome', 'excellent', 'wonderful', 'happy', 'comfortable', 'nice', 'best'];
    // Negative words
    final negativeWords = ['bad', 'terrible', 'hate', 'awful', 'horrible', 'annoying', 'frustrated', 'broken', 'hot', 'cold', 'noisy', 'worst', 'uncomfortable'];

    for (final word in positiveWords) {
      if (input.contains(word)) {
        score += 0.3;
        keywords.add('+$word');
      }
    }
    for (final word in negativeWords) {
      if (input.contains(word)) {
        score -= 0.3;
        keywords.add('-$word');
      }
    }

    // Negation handling
    if (input.contains('not ') || input.contains('don\'t') || input.contains('doesn\'t')) {
      score = -score * 0.7;
      keywords.add('negation_detected');
    }

    score = score.clamp(-1.0, 1.0);

    String sentiment;
    if (score > 0.3) {
      sentiment = 'positive';
    } else if (score < -0.3) {
      sentiment = 'negative';
    } else {
      sentiment = 'neutral';
    }

    return {
      'text': text,
      'sentiment': sentiment,
      'score': double.parse(score.toStringAsFixed(2)),
      'keywords': keywords,
      'action_needed': sentiment == 'negative',
      'suggested_response': sentiment == 'negative'
          ? 'I\'m sorry you\'re not satisfied. Let me help resolve this issue.'
          : sentiment == 'positive'
              ? 'Glad everything is working well!'
              : 'How can I improve your experience?',
      'feedback_category': _categorizeFeedback(input),
    };
  }

  String _categorizeFeedback(String input) {
    if (input.contains(RegExp(r'temp|hot|cold|ac|heat'))) return 'climate_comfort';
    if (input.contains(RegExp(r'light|dark|bright|dim'))) return 'lighting';
    if (input.contains(RegExp(r'noise|loud|quiet|sound'))) return 'noise';
    if (input.contains(RegExp(r'slow|fast|delay|lag'))) return 'performance';
    if (input.contains(RegExp(r'hard|confus|difficult|easy'))) return 'usability';
    return 'general';
  }

  // ─── Feature 34: Voice-Activated Scenes ───────────────────────────

  Map<String, dynamic> activateSceneByVoice(String voiceInput) {
    final input = voiceInput.toLowerCase();
    Map<String, dynamic>? matchedScene;

    final scenes = [
      {
        'name': 'Movie Night',
        'triggers': ['movie', 'cinema', 'film', 'watch'],
        'actions': [
          {'device': 'living_room_light', 'action': 'dim', 'value': 10},
          {'device': 'television', 'action': 'ON'},
          {'device': 'curtains', 'action': 'close'},
          {'device': 'ac', 'action': 'set', 'value': 23},
        ],
        'response': 'Movie mode activated! Lights dimmed, TV on, curtains closed.',
      },
      {
        'name': 'Morning Routine',
        'triggers': ['morning', 'wake up', 'sunrise', 'get up'],
        'actions': [
          {'device': 'bedroom_light', 'action': 'ON', 'brightness': 70, 'color_temp': 5000},
          {'device': 'curtains', 'action': 'open'},
          {'device': 'coffee_maker', 'action': 'ON'},
          {'device': 'bathroom_heater', 'action': 'ON'},
        ],
        'response': 'Good morning! Lights on, curtains opening, coffee brewing.',
      },
      {
        'name': 'Romantic Evening',
        'triggers': ['romantic', 'date night', 'dinner', 'candle'],
        'actions': [
          {'device': 'living_room_light', 'action': 'dim', 'value': 20, 'color': 'warm'},
          {'device': 'dining_light', 'action': 'dim', 'value': 30, 'color': 'warm'},
          {'device': 'music_system', 'action': 'play', 'playlist': 'romantic'},
        ],
        'response': 'Romantic mode! Warm dim lights and soft music playing.',
      },
      {
        'name': 'Party Mode',
        'triggers': ['party', 'dance', 'celebration', 'fun'],
        'actions': [
          {'device': 'all_lights', 'action': 'color_cycle'},
          {'device': 'music_system', 'action': 'play', 'playlist': 'party', 'volume': 80},
          {'device': 'ac', 'action': 'set', 'value': 21},
        ],
        'response': 'Party mode on! Lights cycling, music pumping, AC cooling!',
      },
      {
        'name': 'Sleep Mode',
        'triggers': ['sleep', 'bedtime', 'night', 'goodnight'],
        'actions': [
          {'device': 'all_lights', 'action': 'OFF'},
          {'device': 'bedroom_light', 'action': 'night_light', 'value': 5},
          {'device': 'ac', 'action': 'set', 'value': 24},
          {'device': 'security', 'action': 'arm'},
          {'device': 'all_doors', 'action': 'lock'},
        ],
        'response': 'Goodnight! All secured, lights off, bedroom night light on, AC set to 24°C.',
      },
      {
        'name': 'Work From Home',
        'triggers': ['work', 'office', 'focus', 'study', 'concentrate'],
        'actions': [
          {'device': 'study_light', 'action': 'ON', 'brightness': 100, 'color_temp': 5500},
          {'device': 'music_system', 'action': 'play', 'playlist': 'focus', 'volume': 20},
          {'device': 'notifications', 'action': 'dnd'},
        ],
        'response': 'Focus mode! Bright task lighting, ambient focus music, notifications silenced.',
      },
    ];

    for (final scene in scenes) {
      for (final trigger in scene['triggers'] as List<String>) {
        if (input.contains(trigger)) {
          matchedScene = scene;
          break;
        }
      }
      if (matchedScene != null) break;
    }

    if (matchedScene != null) {
      return {
        'scene_activated': true,
        'scene_name': matchedScene['name'],
        'actions': matchedScene['actions'],
        'response': matchedScene['response'],
        'confidence': 0.92,
        'voice_input': voiceInput,
      };
    }

    return {
      'scene_activated': false,
      'response': 'I didn\'t recognize a scene from your command. Available scenes: '
          '${scenes.map((s) => s['name']).join(', ')}',
      'available_scenes': scenes.map((s) => s['name']).toList(),
      'voice_input': voiceInput,
    };
  }

  // ─── Feature 35: Natural Language Scheduling ──────────────────────

  Map<String, dynamic> parseSchedule(String naturalLanguageInput) {
    final input = naturalLanguageInput.toLowerCase();
    final now = DateTime.now();

    // Time extraction
    DateTime? scheduledTime;
    String? recurrence;

    if (input.contains('tomorrow')) {
      scheduledTime = DateTime(now.year, now.month, now.day + 1);
    } else if (input.contains('tonight')) {
      scheduledTime = DateTime(now.year, now.month, now.day, 22, 0);
    } else if (input.contains('in the morning')) {
      scheduledTime = DateTime(now.year, now.month, now.day + 1, 7, 0);
    }

    // Time of day extraction
    final timeMatch = RegExp(r'at (\d{1,2})(?::(\d{2}))?\s*(am|pm)?').firstMatch(input);
    if (timeMatch != null) {
      int hour = int.parse(timeMatch.group(1)!);
      final minute = int.tryParse(timeMatch.group(2) ?? '0') ?? 0;
      final ampm = timeMatch.group(3);
      if (ampm == 'pm' && hour < 12) hour += 12;
      if (ampm == 'am' && hour == 12) hour = 0;
      scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
    }

    // Recurrence extraction
    if (input.contains('every day') || input.contains('daily')) {
      recurrence = 'daily';
    } else if (input.contains('weekday') || input.contains('monday to friday')) {
      recurrence = 'weekdays';
    } else if (input.contains('weekend')) {
      recurrence = 'weekends';
    } else if (input.contains('every week') || input.contains('weekly')) {
      recurrence = 'weekly';
    }

    // Action extraction
    final action = processVoiceCommand(input);

    return {
      'input': naturalLanguageInput,
      'parsed': {
        'scheduled_time': scheduledTime?.toIso8601String(),
        'recurrence': recurrence,
        'action': action['intent'],
        'device': action['device'],
        'value': action['value'],
      },
      'human_readable': scheduledTime != null
          ? '${action['intent']} ${action['device'] ?? 'device'} at '
              '${scheduledTime.hour}:${scheduledTime.minute.toString().padLeft(2, '0')}'
              '${recurrence != null ? ' ($recurrence)' : ''}'
          : 'Could not parse time from input',
      'success': scheduledTime != null && action['intent'] != 'unknown',
      'confirmation_needed': true,
      'confirmation_message': scheduledTime != null
          ? 'I\'ll ${action['intent']} ${action['device'] ?? 'the device'} at '
              '${scheduledTime.hour}:${scheduledTime.minute.toString().padLeft(2, '0')}'
              '${recurrence != null ? ' $recurrence' : ''}. Confirm?'
          : 'I couldn\'t understand the schedule. Please try again with a time like "at 7 PM" or "tomorrow morning".',
    };
  }

  void clearConversation() {
    _conversationHistory.clear();
    notifyListeners();
  }
}
