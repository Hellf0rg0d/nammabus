import 'package:flutter/material.dart';

enum AppLanguage { english, kannada, hindi }

class Localization {
  static final ValueNotifier<AppLanguage> appLanguageNotifier =
      ValueNotifier(AppLanguage.english);

  static final Map<AppLanguage, Map<String, String>> _localizedValues = {
    AppLanguage.english: {
      'source': 'Source',
      'destination': 'Destination',
      'search': 'SEARCH',
      'select_time': 'Select Time',
      'bus_details': 'Bus Details',
      'starting_from': 'STARTING FROM',
      'departure_time': 'DEPARTURE TIME',
      'distance': 'DISTANCE',
      'total_trips': 'TOTAL TRIPS',
      'next_trip_same': 'NEXT TRIP (SAME BUS)',
      'next_bus_any': 'NEXT BUS (ANY BUS)',
      'scheduled': 'SCHEDULED',
      'no_more_buses': 'No more buses today',
      'no_more_trips': 'No more trips today',
      'route_details': 'Route Details',
      'bus': 'BUS',
      'start_point': 'Start Point',
      'end_point': 'End Point',
      'no_buses_found': 'No buses found for this route.',
      'search_for_buses': 'Search for buses by Source & Destination',
      'available_schedules': 'AVAILABLE SCHEDULES',
      'found': 'FOUND',
      'live_status': 'Live Status',
      'almost_there': 'Almost There',
      'mid_journey': 'Mid-Journey',
      'just_started': 'Just Started',
      'completed': 'Completed',
      'est_arrival': 'Est. Arrival',
      'progress': 'Progress',
      'home': 'Home',
      'status_active': 'Active',
      'status_scheduled': 'Scheduled',
      'status_completed': 'Completed',
      'time_elapsed': 'Elapsed',
      'time_remaining': 'Remaining',
      'starts_in': 'Starts in',
      'arrived_ago': 'Arrived',
      'search_hint': 'Enter Bus No or Destination',
    },
    AppLanguage.kannada: {
      'source': 'ಮೂಲ',
      'destination': 'ಗಮ್ಯಸ್ಥಾನ',
      'search': 'ಹುಡುಕಿ',
      'select_time': 'ಸಮಯ ಆಯ್ಕೆಮಾಡಿ',
      'bus_details': 'ಬಸ್ ವಿವರಗಳು',
      'starting_from': 'ಇಂದ ಪ್ರಾರಂಭ',
      'departure_time': 'ಹೊರಡುವ ಸಮಯ',
      'distance': 'ದೂರ',
      'total_trips': 'ಒಟ್ಟು ಟ್ರಿಪ್‌ಗಳು',
      'next_trip_same': 'ಮುಂದಿನ ಟ್ರಿಪ್ (ಅದೇ ಬಸ್)',
      'next_bus_any': 'ಮುಂದಿನ ಬಸ್ (ಯಾವುದೇ ಬಸ್)',
      'scheduled': 'ನಿಗದಿಪಡಿಸಲಾಗಿದೆ',
      'no_more_buses': 'ಇಂದು ಇನ್ನು ಬಸ್‌ಗಳಿಲ್ಲ',
      'no_more_trips': 'ಇಂದು ಇನ್ನು ಟ್ರಿಪ್‌ಗಳಿಲ್ಲ',
      'route_details': 'ಮಾರ್ಗ ವಿವರಗಳು',
      'bus': 'ಬಸ್',
      'start_point': 'ಪ್ರಾರಂಭದ ಸ್ಥಳ',
      'end_point': 'ಅಂತ್ಯದ ಸ್ಥಳ',
      'no_buses_found': 'ಈ ಮಾರ್ಗದಲ್ಲಿ ಯಾವುದೇ ಬಸ್‌ಗಳಿಲ್ಲ.',
      'search_for_buses': 'ಮೂಲ ಮತ್ತು ಗಮ್ಯಸ್ಥಾನದ ಮೂಲಕ ಬಸ್‌ಗಳನ್ನು ಹುಡುಕಿ',
      'available_schedules': 'ಲಭ್ಯವಿರುವ ವೇಳಾಪಟ್ಟಿಗಳು',
      'found': 'ಕಂಡುಬಂದಿದೆ',
      'live_status': 'ಲೈವ್ ಸ್ಥಿತಿ',
      'almost_there': 'ತಲುಪಲಿದೆ',
      'mid_journey': 'ಮಧ್ಯ ಪ್ರಯಾಣ',
      'just_started': 'ಈಗಷ್ಟೇ ಪ್ರಾರಂಭವಾಗಿದೆ',
      'completed': 'ಪೂರ್ಣಗೊಂಡಿದೆ',
      'est_arrival': 'ಅಂದಾಜು ಆಗಮನ',
      'progress': 'ಪ್ರಗತಿ',
      'home': 'ಮುಖಪುಟ',
      'status_active': 'ಸಕ್ರಿಯ',
      'status_scheduled': 'ನಿಗದಿಪಡಿಸಲಾಗಿದೆ',
      'status_completed': 'ಪೂರ್ಣಗೊಂಡಿದೆ',
      'time_elapsed': 'ಕಳೆದ ಸಮಯ',
      'time_remaining': 'ಉಳಿದ ಸಮಯ',
      'starts_in': 'ಪ್ರಾರಂಭವಾಗುತ್ತದೆ',
      'arrived_ago': 'ತಲುಪಿದೆ',
      'search_hint': 'ಬಸ್ ಸಂಖ್ಯೆ ಅಥವಾ ಗಮ್ಯಸ್ಥಾನವನ್ನು ನಮೂದಿಸಿ',
    },
    AppLanguage.hindi: {
      'source': 'स्रोत',
      'destination': 'गंतव्य',
      'search': 'खोजें',
      'select_time': 'समय चुनें',
      'bus_details': 'बस विवरण',
      'starting_from': 'शुरुआत',
      'departure_time': 'प्रस्थान समय',
      'distance': 'दूरी',
      'total_trips': 'कुल यात्राएं',
      'next_trip_same': 'अगली यात्रा (वही बस)',
      'next_bus_any': 'अगली बस (कोई भी बस)',
      'scheduled': 'अनुसूचित',
      'no_more_buses': 'आज और बसें नहीं हैं',
      'no_more_trips': 'आज और यात्राएं नहीं हैं',
      'route_details': 'मार्ग विवरण',
      'bus': 'बस',
      'start_point': 'प्रारंभ बिंदु',
      'end_point': 'अंतिम बिंदु',
      'no_buses_found': 'इस मार्ग के लिए कोई बस नहीं मिली।',
      'search_for_buses': 'स्रोत और गंतव्य द्वारा बसें खोजें',
      'available_schedules': 'उपलब्ध कार्यक्रम',
      'found': 'मिला',
      'live_status': 'लाइव स्थिति',
      'almost_there': 'पहुंचने वाला है',
      'mid_journey': 'मध्य यात्रा',
      'just_started': 'अभी शुरू हुआ',
      'completed': 'पूरा हुआ',
      'est_arrival': 'अनुमानित आगमन',
      'progress': 'प्रगति',
      'home': 'होम',
      'status_active': 'सक्रिय',
      'status_scheduled': 'अनुसूचित',
      'status_completed': 'पूरा हुआ',
      'time_elapsed': 'बीता समय',
      'time_remaining': 'शेष समय',
      'starts_in': 'शुरू होगा',
      'arrived_ago': 'पहुँच गया',
      'search_hint': 'बस नंबर या गंतव्य दर्ज करें',
    },
  };

  static String getStr(String key) {
    return _localizedValues[appLanguageNotifier.value]?[key] ?? key;
  }

  static void toggleLanguage() {
    final current = appLanguageNotifier.value;
    if (current == AppLanguage.english) {
      appLanguageNotifier.value = AppLanguage.kannada;
    } else if (current == AppLanguage.kannada) {
      appLanguageNotifier.value = AppLanguage.hindi;
    } else {
      appLanguageNotifier.value = AppLanguage.english;
    }
  }

  static String getLanguageName() {
    switch (appLanguageNotifier.value) {
      case AppLanguage.english:
        return 'EN';
      case AppLanguage.kannada:
        return 'KN';
      case AppLanguage.hindi:
        return 'HI';
    }
  }
}
