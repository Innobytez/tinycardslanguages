import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class LanguageChanger with ChangeNotifier {
  Map<String, String> _currentLanguage = {'flag': 'assets/flags/us.png', 'language': 'English', 'englishName': 'English'};

  LanguageChanger() {
    String deviceLanguage = ui.window.locale.languageCode;
    // Map device language to your language data
    Map<String, String>? defaultLanguage = _mapDeviceLanguageToDeviceLanguage(deviceLanguage);
    if (defaultLanguage != null) {
      _currentLanguage = defaultLanguage;
    }
  }

  Map<String, String> get currentLanguage => _currentLanguage;

  void changeLanguage(Map<String, String> newLanguage) {
    _currentLanguage = newLanguage;
    notifyListeners();
  }

  Map<String, String>? _mapDeviceLanguageToDeviceLanguage(String deviceLanguage) {
    // Map the device language to the currentLanguage
    switch (deviceLanguage) {
      case 'en':
        return {'flag': 'assets/flags/us.png', 'language': 'English', 'englishName': 'English'};
      case 'fr':
        return {'flag': 'assets/flags/fr.png', 'language': 'Français', 'englishName': 'French'};
      case 'de':
        return {'flag': 'assets/flags/de.png', 'language': 'Deutsch', 'englishName': 'German'};
      case 'el':
        return {'flag': 'assets/flags/gr.png', 'language': 'Ελληνικά', 'englishName': 'Greek'};
      case 'it':
        return {'flag': 'assets/flags/it.png', 'language': 'Italiano', 'englishName': 'Italian'};
      case 'ru':
        return {'flag': 'assets/flags/ru.png', 'language': 'Русский', 'englishName': 'Russian'};
      case 'es':
        return {'flag': 'assets/flags/es.png', 'language': 'Español', 'englishName': 'Spanish'};
      case 'af':
        return {'flag': 'assets/flags/za.png', 'language': 'Afrikaans', 'englishName': 'Afrikaans'};
      case 'sq':
        return {'flag': 'assets/flags/al.png', 'language': 'Shqip', 'englishName': 'Albanian'};
      case 'am':
        return {'flag': 'assets/flags/et.png', 'language': 'አማርኛ', 'englishName': 'Amharic'};
      case 'ar':
        return {'flag': 'assets/flags/ae.png', 'language': 'العربية', 'englishName': 'Arabic'};
      case 'hy':
        return {'flag': 'assets/flags/am.png', 'language': 'Հայերեն', 'englishName': 'Armenian'};
      case 'az':
        return {'flag': 'assets/flags/az.png', 'language': 'Azərbaycan', 'englishName': 'Azerbaijani'};
      case 'eu':
        return {'flag': 'assets/flags/es.png', 'language': 'Euskara', 'englishName': 'Basque'};
      case 'be':
        return {'flag': 'assets/flags/by.png', 'language': 'Беларуская', 'englishName': 'Belarusian'};
      case 'bn':
        return {'flag': 'assets/flags/bd.png', 'language': 'বাংলা', 'englishName': 'Bengali'};
      case 'bs':
        return {'flag': 'assets/flags/ba.png', 'language': 'Bosanski', 'englishName': 'Bosnian'};
      case 'bg':
        return {'flag': 'assets/flags/bg.png', 'language': 'Български', 'englishName': 'Bulgarian'};
      case 'ca':
        return {'flag': 'assets/flags/es.png', 'language': 'Català', 'englishName': 'Catalan'};
      case 'ceb':
        return {'flag': 'assets/flags/ph.png', 'language': 'Cebuano', 'englishName': 'Cebuano'};
      case 'ny':
        return {'flag': 'assets/flags/mw.png', 'language': 'Chichewa', 'englishName': 'Chichewa'};
      case 'zh':
        return {'flag': 'assets/flags/cn.png', 'language': '中文', 'englishName': 'Chinese'};
      case 'co':
        return {'flag': 'assets/flags/fr.png', 'language': 'Corsu', 'englishName': 'Corsican'};
      case 'hr':
        return {'flag': 'assets/flags/hr.png', 'language': 'Hrvatski', 'englishName': 'Croatian'};
      case 'cs':
        return {'flag': 'assets/flags/cz.png', 'language': 'Čeština', 'englishName': 'Czech'};
      case 'da':
        return {'flag': 'assets/flags/dk.png', 'language': 'Dansk', 'englishName': 'Danish'};
      case 'nl':
        return {'flag': 'assets/flags/nl.png', 'language': 'Nederlands', 'englishName': 'Dutch'};
      case 'eo':
        return {'flag': 'assets/flags/esp.png', 'language': 'Esperanto', 'englishName': 'Esperanto'};
      case 'et':
        return {'flag': 'assets/flags/ee.png', 'language': 'Eesti', 'englishName': 'Estonian'};
      case 'fil':
        return {'flag': 'assets/flags/ph.png', 'language': 'Filipino', 'englishName': 'Filipino'};
      case 'fi':
        return {'flag': 'assets/flags/fi.png', 'language': 'Suomi', 'englishName': 'Finnish'};
      case 'fy':
        return {'flag': 'assets/flags/nl.png', 'language': 'Frysk', 'englishName': 'Frisian'};
      case 'gl':
        return {'flag': 'assets/flags/es.png', 'language': 'Galego', 'englishName': 'Galician'};
      case 'ka':
        return {'flag': 'assets/flags/ge.png', 'language': 'ქართული', 'englishName': 'Georgian'};
      case 'gu':
        return {'flag': 'assets/flags/in.png', 'language': 'ગુજરાતી', 'englishName': 'Gujarati'};
      case 'ht':
        return {'flag': 'assets/flags/ht.png', 'language': 'Kreyòl Ayisyen', 'englishName': 'Haitian Creole'};
      case 'ha':
        return {'flag': 'assets/flags/ng.png', 'language': 'Hausa', 'englishName': 'Hausa'};
      case 'haw':
        return {'flag': 'assets/flags/us.png', 'language': 'ʻŌlelo Hawaiʻi', 'englishName': 'Hawaiian'};
      case 'he':
        return {'flag': 'assets/flags/il.png', 'language': 'עברית', 'englishName': 'Hebrew'};
      case 'hi':
        return {'flag': 'assets/flags/in.png', 'language': 'हिन्दी', 'englishName': 'Hindi'};
      case 'hmn':
        return {'flag': 'assets/flags/cn.png', 'language': 'Hmoob', 'englishName': 'Hmong'};
      case 'hu':
        return {'flag': 'assets/flags/hu.png', 'language': 'Magyar', 'englishName': 'Hungarian'};
      case 'is':
        return {'flag': 'assets/flags/is.png', 'language': 'Íslenska', 'englishName': 'Icelandic'};
      case 'ig':
        return {'flag': 'assets/flags/ng.png', 'language': 'Igbo', 'englishName': 'Igbo'};
      case 'id':
        return {'flag': 'assets/flags/id.png', 'language': 'Bahasa Indonesia', 'englishName': 'Indonesian'};
      case 'ga':
        return {'flag': 'assets/flags/ie.png', 'language': 'Gaeilge', 'englishName': 'Irish'};
      case 'ja':
        return {'flag': 'assets/flags/jp.png', 'language': '日本語', 'englishName': 'Japanese'};
      case 'jv':
        return {'flag': 'assets/flags/id.png', 'language': 'Basa Jawa', 'englishName': 'Javanese'};
      case 'kn':
        return {'flag': 'assets/flags/in.png', 'language': 'ಕನ್ನಡ', 'englishName': 'Kannada'};
      case 'kk':
        return {'flag': 'assets/flags/kz.png', 'language': 'Қазақ тілі', 'englishName': 'Kazakh'};
      case 'km':
        return {'flag': 'assets/flags/kh.png', 'language': 'ខ្មែរ', 'englishName': 'Khmer'};
      case 'ko':
        return {'flag': 'assets/flags/kr.png', 'language': '한국어', 'englishName': 'Korean'};
      case 'ku':
        return {'flag': 'assets/flags/iq.png', 'language': 'Kurdî (Kurmanji)', 'englishName': 'Kurdish (Kurmanji)'};
      case 'ky':
        return {'flag': 'assets/flags/kg.png', 'language': 'Кыргызча', 'englishName': 'Kyrgyz'};
      case 'lo':
        return {'flag': 'assets/flags/la.png', 'language': 'ລາວ', 'englishName': 'Lao'};
      case 'la':
        return {'flag': 'assets/flags/va.png', 'language': 'Latina', 'englishName': 'Latin'};
      case 'lv':
        return {'flag': 'assets/flags/lv.png', 'language': 'Latviešu', 'englishName': 'Latvian'};
      case 'lt':
        return {'flag': 'assets/flags/lt.png', 'language': 'Lietuvių', 'englishName': 'Lithuanian'};
      case 'lb':
        return {'flag': 'assets/flags/lu.png', 'language': 'Lëtzebuergesch', 'englishName': 'Luxembourgish'};
      case 'mk':
        return {'flag': 'assets/flags/mk.png', 'language': 'Македонски', 'englishName': 'Macedonian'};
      case 'mg':
        return {'flag': 'assets/flags/mg.png', 'language': 'Malagasy', 'englishName': 'Malagasy'};
      case 'ms':
        return {'flag': 'assets/flags/my.png', 'language': 'Bahasa Melayu', 'englishName': 'Malay'};
      case 'ml':
        return {'flag': 'assets/flags/in.png', 'language': 'മലയാളം', 'englishName': 'Malayalam'};
      case 'mt':
        return {'flag': 'assets/flags/mt.png', 'language': 'Malti', 'englishName': 'Maltese'};
      case 'mi':
        return {'flag': 'assets/flags/nz.png', 'language': 'Te Reo Māori', 'englishName': 'Maori'};
      case 'mr':
        return {'flag': 'assets/flags/in.png', 'language': 'मराठी', 'englishName': 'Marathi'};
      case 'mn':
        return {'flag': 'assets/flags/mn.png', 'language': 'Монгол', 'englishName': 'Mongolian'};
      case 'my':
        return {'flag': 'assets/flags/mm.png', 'language': 'ဗမာစာ', 'englishName': 'Myanmar (Burmese)'};
      case 'ne':
        return {'flag': 'assets/flags/np.png', 'language': 'नेपाली', 'englishName': 'Nepali'};
      case 'no':
        return {'flag': 'assets/flags/no.png', 'language': 'Norsk', 'englishName': 'Norwegian'};
      case 'ps':
        return {'flag': 'assets/flags/af.png', 'language': 'پښتو', 'englishName': 'Pashto'};
      case 'fa':
        return {'flag': 'assets/flags/ir.png', 'language': 'فارسی', 'englishName': 'Persian'};
      case 'pl':
        return {'flag': 'assets/flags/pl.png', 'language': 'Polski', 'englishName': 'Polish'};
      case 'pt':
        return {'flag': 'assets/flags/pt.png', 'language': 'Português', 'englishName': 'Portuguese'};
      case 'pa':
        return {'flag': 'assets/flags/in.png', 'language': 'ਪੰਜਾਬੀ', 'englishName': 'Punjabi'};
      case 'ro':
        return {'flag': 'assets/flags/ro.png', 'language': 'Română', 'englishName': 'Romanian'};
      case 'sm':
        return {'flag': 'assets/flags/ws.png', 'language': 'Gagana Sāmoa', 'englishName': 'Samoan'};
      case 'gd':
        return {'flag': 'assets/flags/gb-sct.png', 'language': 'Gàidhlig', 'englishName': 'Scots Gaelic'};
      case 'sr':
        return {'flag': 'assets/flags/rs.png', 'language': 'Српски', 'englishName': 'Serbian'};
      case 'st':
        return {'flag': 'assets/flags/ls.png', 'language': 'Sesotho', 'englishName': 'Sesotho'};
      case 'sn':
        return {'flag': 'assets/flags/zw.png', 'language': 'Shona', 'englishName': 'Shona'};
      case 'sd':
        return {'flag': 'assets/flags/pk.png', 'language': 'سنڌي', 'englishName': 'Sindhi'};
      case 'si':
        return {'flag': 'assets/flags/lk.png', 'language': 'සිංහල', 'englishName': 'Sinhala'};
      case 'sk':
        return {'flag': 'assets/flags/sk.png', 'language': 'Slovenčina', 'englishName': 'Slovak'};
      case 'sl':
        return {'flag': 'assets/flags/si.png', 'language': 'Slovenščina', 'englishName': 'Slovenian'};
      case 'so':
        return {'flag': 'assets/flags/so.png', 'language': 'Soomaali', 'englishName': 'Somali'};
      case 'su':
        return {'flag': 'assets/flags/id.png', 'language': 'Basa Sunda', 'englishName': 'Sundanese'};
      case 'sw':
        return {'flag': 'assets/flags/tz.png', 'language': 'Kiswahili', 'englishName': 'Swahili'};
      case 'sv':
        return {'flag': 'assets/flags/se.png', 'language': 'Svenska', 'englishName': 'Swedish'};
      case 'tg':
        return {'flag': 'assets/flags/tj.png', 'language': 'Тоҷикӣ', 'englishName': 'Tajik'};
      case 'ta':
        return {'flag': 'assets/flags/in.png', 'language': 'தமிழ்', 'englishName': 'Tamil'};
      case 'te':
        return {'flag': 'assets/flags/in.png', 'language': 'తెలుగు', 'englishName': 'Telugu'};
      case 'th':
        return {'flag': 'assets/flags/th.png', 'language': 'ไทย', 'englishName': 'Thai'};
      case 'tr':
        return {'flag': 'assets/flags/tr.png', 'language': 'Türkçe', 'englishName': 'Turkish'};
      case 'uk':
        return {'flag': 'assets/flags/ua.png', 'language': 'Українська', 'englishName': 'Ukrainian'};
      case 'ur':
        return {'flag': 'assets/flags/pk.png', 'language': 'اردو', 'englishName': 'Urdu'};
      case 'uz':
        return {'flag': 'assets/flags/uz.png', 'language': 'Oʻzbekcha', 'englishName': 'Uzbek'};
      case 'vi':
        return {'flag': 'assets/flags/vn.png', 'language': 'Tiếng Việt', 'englishName': 'Vietnamese'};
      case 'cy':
        return {'flag': 'assets/flags/gb-wls.png', 'language': 'Cymraeg', 'englishName': 'Welsh'};
      case 'xh':
        return {'flag': 'assets/flags/za.png', 'language': 'isiXhosa', 'englishName': 'Xhosa'};
      case 'yi':
        return {'flag': 'assets/flags/il.png', 'language': 'ייִדיש', 'englishName': 'Yiddish'};
      case 'yo':
        return {'flag': 'assets/flags/ng.png', 'language': 'Yorùbá', 'englishName': 'Yoruba'};
      case 'zu':
        return {'flag': 'assets/flags/za.png', 'language': 'isiZulu', 'englishName': 'Zulu'};
      default:
        return null;
    }
  }

}