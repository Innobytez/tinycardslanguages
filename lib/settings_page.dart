import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinycards/language_changer.dart';
import 'package:tinycards/statistics_changer.dart';
import 'package:tinycards/theme_changer.dart';
import 'package:tinycards/overlay_changer.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:tinycards/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:android_intent/android_intent.dart';
import 'startupsound_changer.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:tinycards/custom_loading_spinner.dart';

class SettingsScreen extends StatefulWidget {
  final PageController pageController;
  final int pageIndex;

  const SettingsScreen({
    super.key,
    required this.pageController,
    required this.pageIndex,
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  List<ProductDetails> _products = [];
  bool _isPendingDialogShowing = false; // Define a variable to track if the pending dialog is showing

  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = InAppPurchase.instance.purchaseStream;
    purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onError: (error) {
      // handle error here.
    });
    _initializeInAppPurchase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: Padding(
        padding: const EdgeInsets.only(top: 30.0, bottom: 0.0),
        child: Stack(
          children: <Widget>[
            buildBackButton(context),
            _buildSettingsContainer(context),
          ],
        ),
      ),
    );
  }

  // Check if the current language uses OpenSans font
  bool isFontOpenSans(BuildContext context) {
    return [
      'Greek', 'Russian', 'Mandarin', 'Hebrew', 'Hindi', 'Bengali', 'Japanese', 'Korean', 'Arabic', 
      'Thai', 'Tamil', 'Telugu', 'Kannada', 'Malayalam', 'Sinhala', 'Amharic', 'Georgian', 'Khmer',
      'Lao', 'Myanmar (Burmese)', 'Yiddish', 'Gujarati', 'Urdu', 'Pashto', 'Farsi', 'Ukrainian', 
      'Cyrillic', 'Afrikaans', 'Albanian', 'Armenian', 'Azerbaijani', 'Basque', 'Belarusian',
      'Bosnian', 'Bulgarian', 'Catalan', 'Cebuano', 'Chichewa', 'Corsican', 'Croatian', 'Czech', 
      'Danish', 'Dutch', 'Esperanto', 'Estonian', 'Filipino', 'Finnish', 'Frisian', 'Galician',
      'Haitian Creole', 'Hausa', 'Hawaiian', 'Hmong', 'Hungarian', 'Icelandic', 'Igbo', 'Indonesian',
      'Irish', 'Javanese', 'Kazakh', 'Kurdish (Kurmanji)', 'Kyrgyz', 'Latin', 'Latvian', 'Lithuanian',
      'Luxembourgish', 'Macedonian', 'Malagasy', 'Malay', 'Maori', 'Marathi', 'Mongolian', 'Nepali',
      'Norwegian', 'Polish', 'Portuguese', 'Punjabi', 'Romanian', 'Samoan', 'Scots Gaelic', 'Serbian',
      'Sesotho', 'Shona', 'Sindhi', 'Slovak', 'Slovenian', 'Somali', 'Sundanese', 'Swahili', 'Swedish',
      'Tajik', 'Uzbek', 'Vietnamese', 'Welsh', 'Xhosa', 'Yoruba', 'Zulu'
    ].contains(Provider.of<LanguageChanger>(context).currentLanguage['language']);
  }

  Positioned buildBackButton(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 30.0, bottom: 0.0),
              child: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: InkWell(
                    onTap: () {
                      if (Provider.of<OverlayChanger>(context, listen: false).isVibrationOn) {
                        HapticFeedback.heavyImpact();
                      }
                      widget.pageController.animateToPage(
                        widget.pageIndex,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Center(
                      child: buildBackText(context),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  SizedBox buildBackText(BuildContext context) {
    bool isOpenSans = isFontOpenSans(context);
    return SizedBox(
      height: 90,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: isOpenSans ? const EdgeInsets.only(bottom: 12.0) : const EdgeInsets.all(0),
          child: Text(
            backWord[Provider.of<LanguageChanger>(context).currentLanguage['language']] ?? 'BACK',
            style: TextStyle(
              fontSize: 70,
              fontFamily: isOpenSans ? 'OpenSans' : 'Kapra',
              color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Positioned _buildSettingsContainer(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color backgroundColor = isDarkMode ? Colors.black : Colors.white;
    Color backgroundTextColor = isDarkMode ? Colors.white : Colors.black;

    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      bottom: 85,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListView(
          padding: const EdgeInsets.only(top: 4.0),
          children: <Widget>[
            _buildSwitchListTile(
              context,
              'Swipe Animations',
              Provider.of<OverlayChanger>(context).isOverlayOn,
              Provider.of<OverlayChanger>(context, listen: false).toggleOverlay,
              backgroundTextColor,
            ),
            _buildSwitchListTile(
              context,
              'Haptic Feedback',
              Provider.of<OverlayChanger>(context).isVibrationOn,
              Provider.of<OverlayChanger>(context, listen: false).toggleVibration,
              backgroundTextColor,
            ),
            _buildSwitchListTile(
              context,
              'Startup Sound',
              Provider.of<StartupSoundChanger>(context).isStartupSoundOn as bool,
              Provider.of<StartupSoundChanger>(context, listen: false).toggleStartupSound,
              backgroundTextColor,
            ),
            _buildSwitchListTile(
              context,
              'Dark Mode',
              Provider.of<ThemeChanger>(context).isDarkModeOn,
              Provider.of<ThemeChanger>(context, listen: false).toggleDarkMode,
              backgroundTextColor,
            ),
            _buildSwitchListTile(
              context,
              'Flip Card Faces',
              Provider.of<StatisticsData>(context).isCardFaceFlipped,
              Provider.of<StatisticsData>(context, listen: false).toggleCardFaceFlipped,
              backgroundTextColor,
            ),
            _buildLanguageListTile(context, backgroundColor, backgroundTextColor),
            _buildDownloadVoicesListTile(context, backgroundColor, backgroundTextColor),
            _buildResetStatisticsListTile(context, backgroundColor, backgroundTextColor),
            _buildSuggestionsListTile(context, backgroundColor, backgroundTextColor),
            _buildDonateListTile(context, backgroundColor, backgroundTextColor),
          ],
        ),
      ),
    );
  }

  SwitchListTile _buildSwitchListTile(
    BuildContext context,
    String title,
    bool value,
    Function onChanged,
    Color backgroundTextColor,
  ) {
    String currentLanguage = Provider.of<LanguageChanger>(context).currentLanguage['language'] ?? 'English';

    // Translate titles based on current language
    String translatedTitle;
    switch (title) {
      case 'Swipe Animations':
        translatedTitle = swipeAnimationsWord[currentLanguage] ?? 'Swipe Animations';
        break;
      case 'Haptic Feedback':
        translatedTitle = hapticFeedbackWord[currentLanguage] ?? 'Haptic Feedback';
        break;
      case 'Startup Sound':
        translatedTitle = startupSoundWord[currentLanguage] ?? 'Startup Sound';
        break;  
      case 'Dark Mode':
        translatedTitle = darkModeWord[currentLanguage] ?? 'Dark Mode';
        break;
      case 'Flip Card Faces':
        translatedTitle = flipCardFacesWord[currentLanguage] ?? 'Flip Card Faces';
        break;
      default:
        translatedTitle = title;
    }

    // Determine font family
    String fontFamily = isFontOpenSans(context) ? 'OpenSansCondensed' : 'Kapra';

    return SwitchListTile(
      title: Text(
        translatedTitle,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: isFontOpenSans(context) ? 28 : 36,
        ),
      ),
      value: value,
      activeColor: backgroundTextColor,
      inactiveThumbColor: backgroundTextColor,
      onChanged: (bool value) {
        onChanged(value);
        if (Provider.of<OverlayChanger>(context, listen: false).isVibrationOn) {
          HapticFeedback.mediumImpact();
        }
      },
    );
  }

  InkWell _buildLanguageListTile(BuildContext context, Color backgroundColor, Color backgroundTextColor) {
    String currentLanguage = Provider.of<LanguageChanger>(context).currentLanguage['language'] ?? 'English';
    String fontFamily = isFontOpenSans(context) ? 'OpenSansCondensed' : 'Kapra';

    return InkWell(
      onTap: () {
        if (Provider.of<OverlayChanger>(context, listen: false).isVibrationOn) {
          HapticFeedback.mediumImpact();
        }
        showModalBottomSheet(
          context: context,
          builder: (BuildContext bc) {
            return ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
              child: _buildLanguageList(context, backgroundColor, backgroundTextColor),
            );
          },
        );
      },
      child: ListTile(
        title: Text(
          appLanguageWord[currentLanguage] ?? 'App Language',
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: isFontOpenSans(context) ? 28 : 36,
          ),
        ),
        trailing: Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: backgroundTextColor,
                width: 2.0,
              ),
              shape: BoxShape.rectangle,
            ),
            child: Image.asset(
              Provider.of<LanguageChanger>(context).currentLanguage['flag']!,
              width: 37,
              height: 24,
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }

  ListView _buildLanguageList(BuildContext context, Color backgroundColor, Color backgroundTextColor) {
    List<Map<String, String>> languages = _getLanguages(context);
    Map<String, String> currentLanguage = Provider.of<LanguageChanger>(context).currentLanguage;

    return ListView.separated(
      padding: const EdgeInsets.only(top: 1.0, bottom: 8.0),
      separatorBuilder: (context, index) => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              backgroundColor,
              backgroundTextColor,
              backgroundTextColor,
              backgroundColor
            ],
            stops: const [0.0, 0.2, 0.80, 1.0],
          ),
        ),
      ),
      itemCount: languages.length,
      itemBuilder: (context, index) {
        var lang = languages[index];
        bool isSelected = currentLanguage['language'] == lang['language'];

        return SizedBox(
          height: 70,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (Provider.of<OverlayChanger>(context, listen: false).isVibrationOn) {
                  HapticFeedback.lightImpact();
                }
                Provider.of<LanguageChanger>(context, listen: false).changeLanguage(lang);
                Navigator.pop(context);
              },
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(25.0, 8.0, 25.0, 10.0),
                leading: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: backgroundTextColor,
                      width: 1.0,
                    ),
                    shape: BoxShape.rectangle,
                  ),
                  child: Image.asset(
                    lang['flag']!,
                    width: 37,
                    height: 24,
                    fit: BoxFit.fill,
                  ),
                ),
                title: Text(
                  _getTranslatedLanguageName(lang['language']!),
                  style: TextStyle(color: backgroundTextColor),
                ),
                trailing: isSelected
                    ? Padding(
                        padding: const EdgeInsets.only(right: 25.0),
                        child: Icon(Icons.check, color: backgroundTextColor),
                      )
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }

  String _getTranslatedLanguageName(String language) => {
    'English': englishWord['English'] ?? language, 'French': frenchWord['French'] ?? language, 'German': germanWord['German'] ?? language, 'Greek': greekWord['Greek'] ?? language, 'Italian': italianWord['Italian'] ?? language, 'Russian': russianWord['Russian'] ?? language, 'Spanish': spanishWord['Spanish'] ?? language, 'Afrikaans': afrikaansWord['Afrikaans'] ?? language, 'Albanian': albanianWord['Albanian'] ?? language, 'Amharic': amharicWord['Amharic'] ?? language, 'Arabic': arabicWord['Arabic'] ?? language, 'Armenian': armenianWord['Armenian'] ?? language, 'Azerbaijani': azerbaijaniWord['Azerbaijani'] ?? language, 'Basque': basqueWord['Basque'] ?? language, 'Belarusian': belarusianWord['Belarusian'] ?? language, 'Bengali': bengaliWord['Bengali'] ?? language, 'Bosnian': bosnianWord['Bosnian'] ?? language, 'Bulgarian': bulgarianWord['Bulgarian'] ?? language, 'Catalan': catalanWord['Catalan'] ?? language, 'Cebuano': cebuanoWord['Cebuano'] ?? language, 'Chichewa': chichewaWord['Chichewa'] ?? language, 'Chinese': chineseWord['Chinese'] ?? language, 'Corsican': corsicanWord['Corsican'] ?? language, 'Croatian': croatianWord['Croatian'] ?? language, 'Czech': czechWord['Czech'] ?? language, 'Danish': danishWord['Danish'] ?? language, 'Dutch': dutchWord['Dutch'] ?? language, 'Esperanto': esperantoWord['Esperanto'] ?? language, 'Estonian': estonianWord['Estonian'] ?? language, 'Filipino': filipinoWord['Filipino'] ?? language, 'Finnish': finnishWord['Finnish'] ?? language, 'Frisian': frisianWord['Frisian'] ?? language, 'Galician': galicianWord['Galician'] ?? language, 'Georgian': georgianWord['Georgian'] ?? language, 'Gujarati': gujaratiWord['Gujarati'] ?? language, 'Haitian Creole': haitianCreoleWord['Haitian Creole'] ?? language, 'Hausa': hausaWord['Hausa'] ?? language, 'Hawaiian': hawaiianWord['Hawaiian'] ?? language, 'Hebrew': hebrewWord['Hebrew'] ?? language, 'Hindi': hindiWord['Hindi'] ?? language, 'Hmong': hmongWord['Hmong'] ?? language, 'Hungarian': hungarianWord['Hungarian'] ?? language, 'Icelandic': icelandicWord['Icelandic'] ?? language, 'Igbo': igboWord['Igbo'] ?? language, 'Indonesian': indonesianWord['Indonesian'] ?? language, 'Irish': irishWord['Irish'] ?? language, 'Japanese': japaneseWord['Japanese'] ?? language, 'Javanese': javaneseWord['Javanese'] ?? language, 'Kannada': kannadaWord['Kannada'] ?? language, 'Kazakh': kazakhWord['Kazakh'] ?? language, 'Khmer': khmerWord['Khmer'] ?? language, 'Korean': koreanWord['Korean'] ?? language, 'Kurdish (Kurmanji)': kurdishWord['Kurdish (Kurmanji)'] ?? language, 'Kyrgyz': kyrgyzWord['Kyrgyz'] ?? language, 'Lao': laoWord['Lao'] ?? language, 'Latin': latinWord['Latin'] ?? language, 'Latvian': latvianWord['Latvian'] ?? language, 'Lithuanian': lithuanianWord['Lithuanian'] ?? language, 'Luxembourgish': luxembourgishWord['Luxembourgish'] ?? language, 'Macedonian': macedonianWord['Macedonian'] ?? language, 'Malagasy': malagasyWord['Malagasy'] ?? language, 'Malay': malayWord['Malay'] ?? language, 'Malayalam': malayalamWord['Malayalam'] ?? language, 'Maltese': malteseWord['Maltese'] ?? language, 'Maori': maoriWord['Maori'] ?? language, 'Marathi': marathiWord['Marathi'] ?? language, 'Mongolian': mongolianWord['Mongolian'] ?? language, 'Myanmar (Burmese)': myanmarWord['Myanmar (Burmese)'] ?? language, 'Nepali': nepaliWord['Nepali'] ?? language, 'Norwegian': norwegianWord['Norwegian'] ?? language, 'Pashto': pashtoWord['Pashto'] ?? language, 'Persian': persianWord['Persian'] ?? language, 'Polish': polishWord['Polish'] ?? language, 'Portuguese': portugueseWord['Portuguese'] ?? language, 'Punjabi': punjabiWord['Punjabi'] ?? language, 'Romanian': romanianWord['Romanian'] ?? language, 'Samoan': samoanWord['Samoan'] ?? language, 'Scots Gaelic': scotsWord['Scots Gaelic'] ?? language, 'Serbian': serbianWord['Serbian'] ?? language, 'Sesotho': sesothoWord['Sesotho'] ?? language, 'Shona': shonaWord['Shona'] ?? language, 'Sindhi': sindhiWord['Sindhi'] ?? language, 'Sinhala': sinhalaWord['Sinhala'] ?? language, 'Slovak': slovakWord['Slovak'] ?? language, 'Slovenian': slovenianWord['Slovenian'] ?? language, 'Somali': somaliWord['Somali'] ?? language, 'Sundanese': sundaneseWord['Sundanese'] ?? language, 'Swahili': swahiliWord['Swahili'] ?? language, 'Swedish': swedishWord['Swedish'] ?? language, 'Tajik': tajikWord['Tajik'] ?? language, 'Tamil': tamilWord['Tamil'] ?? language, 'Telugu': teluguWord['Telugu'] ?? language, 'Thai': thaiWord['Thai'] ?? language, 'Turkish': turkishWord['Turkish'] ?? language, 'Ukrainian': ukrainianWord['Ukrainian'] ?? language, 'Urdu': urduWord['Urdu'] ?? language, 'Uzbek': uzbekWord['Uzbek'] ?? language, 'Vietnamese': vietnameseWord['Vietnamese'] ?? language, 'Welsh': welshWord['Welsh'] ?? language, 'Xhosa': xhosaWord['Xhosa'] ?? language, 'Yiddish': yiddishWord['Yiddish'] ?? language, 'Yoruba': yorubaWord['Yoruba'] ?? language, 'Zulu': zuluWord['Zulu'] ?? language
  }[language] ?? language;

  List<Map<String, String>> _getLanguages(BuildContext context) {
    final languages = [
      {'flag': 'assets/flags/za.png', 'language': 'Afrikaans'},
      {'flag': 'assets/flags/al.png', 'language': 'Albanian'},
      {'flag': 'assets/flags/et.png', 'language': 'Amharic'},
      {'flag': 'assets/flags/ae.png', 'language': 'Arabic'},
      {'flag': 'assets/flags/am.png', 'language': 'Armenian'},
      {'flag': 'assets/flags/az.png', 'language': 'Azerbaijani'},
      {'flag': 'assets/flags/es.png', 'language': 'Basque'},
      {'flag': 'assets/flags/by.png', 'language': 'Belarusian'},
      {'flag': 'assets/flags/bd.png', 'language': 'Bengali'},
      {'flag': 'assets/flags/ba.png', 'language': 'Bosnian'},
      {'flag': 'assets/flags/bg.png', 'language': 'Bulgarian'},
      {'flag': 'assets/flags/es.png', 'language': 'Catalan'},
      {'flag': 'assets/flags/ph.png', 'language': 'Cebuano'},
      {'flag': 'assets/flags/mw.png', 'language': 'Chichewa'},
      {'flag': 'assets/flags/cn.png', 'language': 'Chinese'},
      {'flag': 'assets/flags/fr.png', 'language': 'Corsican'},
      {'flag': 'assets/flags/hr.png', 'language': 'Croatian'},
      {'flag': 'assets/flags/cz.png', 'language': 'Czech'},
      {'flag': 'assets/flags/dk.png', 'language': 'Danish'},
      {'flag': 'assets/flags/nl.png', 'language': 'Dutch'},
      {'flag': 'assets/flags/us.png', 'language': 'English'},
      {'flag': 'assets/flags/esp.png', 'language': 'Esperanto'},
      {'flag': 'assets/flags/ee.png', 'language': 'Estonian'},
      {'flag': 'assets/flags/ph.png', 'language': 'Filipino'},
      {'flag': 'assets/flags/fi.png', 'language': 'Finnish'},
      {'flag': 'assets/flags/fr.png', 'language': 'French'},
      {'flag': 'assets/flags/nl.png', 'language': 'Frisian'},
      {'flag': 'assets/flags/es.png', 'language': 'Galician'},
      {'flag': 'assets/flags/ge.png', 'language': 'Georgian'},
      {'flag': 'assets/flags/de.png', 'language': 'German'},
      {'flag': 'assets/flags/gr.png', 'language': 'Greek'},
      {'flag': 'assets/flags/in.png', 'language': 'Gujarati'},
      {'flag': 'assets/flags/ht.png', 'language': 'Haitian Creole'},
      {'flag': 'assets/flags/ng.png', 'language': 'Hausa'},
      {'flag': 'assets/flags/us.png', 'language': 'Hawaiian'},
      {'flag': 'assets/flags/il.png', 'language': 'Hebrew'},
      {'flag': 'assets/flags/in.png', 'language': 'Hindi'},
      {'flag': 'assets/flags/cn.png', 'language': 'Hmong'},
      {'flag': 'assets/flags/hu.png', 'language': 'Hungarian'},
      {'flag': 'assets/flags/is.png', 'language': 'Icelandic'},
      {'flag': 'assets/flags/ng.png', 'language': 'Igbo'},
      {'flag': 'assets/flags/id.png', 'language': 'Indonesian'},
      {'flag': 'assets/flags/ie.png', 'language': 'Irish'},
      {'flag': 'assets/flags/it.png', 'language': 'Italian'},
      {'flag': 'assets/flags/jp.png', 'language': 'Japanese'},
      {'flag': 'assets/flags/id.png', 'language': 'Javanese'},
      {'flag': 'assets/flags/in.png', 'language': 'Kannada'},
      {'flag': 'assets/flags/kz.png', 'language': 'Kazakh'},
      {'flag': 'assets/flags/kh.png', 'language': 'Khmer'},
      {'flag': 'assets/flags/kr.png', 'language': 'Korean'},
      {'flag': 'assets/flags/iq.png', 'language': 'Kurdish (Kurmanji)'},
      {'flag': 'assets/flags/kg.png', 'language': 'Kyrgyz'},
      {'flag': 'assets/flags/la.png', 'language': 'Lao'},
      {'flag': 'assets/flags/va.png', 'language': 'Latin'},
      {'flag': 'assets/flags/lv.png', 'language': 'Latvian'},
      {'flag': 'assets/flags/lt.png', 'language': 'Lithuanian'},
      {'flag': 'assets/flags/lu.png', 'language': 'Luxembourgish'},
      {'flag': 'assets/flags/mk.png', 'language': 'Macedonian'},
      {'flag': 'assets/flags/mg.png', 'language': 'Malagasy'},
      {'flag': 'assets/flags/my.png', 'language': 'Malay'},
      {'flag': 'assets/flags/in.png', 'language': 'Malayalam'},
      {'flag': 'assets/flags/mt.png', 'language': 'Maltese'},
      {'flag': 'assets/flags/nz.png', 'language': 'Maori'},
      {'flag': 'assets/flags/in.png', 'language': 'Marathi'},
      {'flag': 'assets/flags/mn.png', 'language': 'Mongolian'},
      {'flag': 'assets/flags/mm.png', 'language': 'Myanmar (Burmese)'},
      {'flag': 'assets/flags/np.png', 'language': 'Nepali'},
      {'flag': 'assets/flags/no.png', 'language': 'Norwegian'},
      {'flag': 'assets/flags/af.png', 'language': 'Pashto'},
      {'flag': 'assets/flags/ir.png', 'language': 'Persian'},
      {'flag': 'assets/flags/pl.png', 'language': 'Polish'},
      {'flag': 'assets/flags/pt.png', 'language': 'Portuguese'},
      {'flag': 'assets/flags/in.png', 'language': 'Punjabi'},
      {'flag': 'assets/flags/ro.png', 'language': 'Romanian'},
      {'flag': 'assets/flags/ru.png', 'language': 'Russian'},
      {'flag': 'assets/flags/ws.png', 'language': 'Samoan'},
      {'flag': 'assets/flags/gb-sct.png', 'language': 'Scots Gaelic'},
      {'flag': 'assets/flags/rs.png', 'language': 'Serbian'},
      {'flag': 'assets/flags/ls.png', 'language': 'Sesotho'},
      {'flag': 'assets/flags/zw.png', 'language': 'Shona'},
      {'flag': 'assets/flags/pk.png', 'language': 'Sindhi'},
      {'flag': 'assets/flags/lk.png', 'language': 'Sinhala'},
      {'flag': 'assets/flags/sk.png', 'language': 'Slovak'},
      {'flag': 'assets/flags/si.png', 'language': 'Slovenian'},
      {'flag': 'assets/flags/so.png', 'language': 'Somali'},
      {'flag': 'assets/flags/id.png', 'language': 'Sundanese'},
      {'flag': 'assets/flags/tz.png', 'language': 'Swahili'},
      {'flag': 'assets/flags/se.png', 'language': 'Swedish'},
      {'flag': 'assets/flags/tj.png', 'language': 'Tajik'},
      {'flag': 'assets/flags/in.png', 'language': 'Tamil'},
      {'flag': 'assets/flags/in.png', 'language': 'Telugu'},
      {'flag': 'assets/flags/th.png', 'language': 'Thai'},
      {'flag': 'assets/flags/tr.png', 'language': 'Turkish'},
      {'flag': 'assets/flags/ua.png', 'language': 'Ukrainian'},
      {'flag': 'assets/flags/pk.png', 'language': 'Urdu'},
      {'flag': 'assets/flags/uz.png', 'language': 'Uzbek'},
      {'flag': 'assets/flags/vn.png', 'language': 'Vietnamese'},
      {'flag': 'assets/flags/gb-wls.png', 'language': 'Welsh'},
      {'flag': 'assets/flags/za.png', 'language': 'Xhosa'},
      {'flag': 'assets/flags/il.png', 'language': 'Yiddish'},
      {'flag': 'assets/flags/ng.png', 'language': 'Yoruba'},
      {'flag': 'assets/flags/za.png', 'language': 'Zulu'},
    ];

    languages.sort((a, b) {
      final translatedA = _getTranslatedLanguageName(a['language']!);
      final translatedB = _getTranslatedLanguageName(b['language']!);
      return translatedA.compareTo(translatedB);
    });

    return languages;
  }

  void _initializeInAppPurchase() async {
    const Set<String> ids = {
      'tinycardslanguages_smalldonation',
      'tinycardslanguages_mediumdonation',
      'tinycardslanguages_largedonation'
    };
    final ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    if (response.error != null) {
      // Handle the error appropriately.
      print(response.error);
    } else {
      setState(() {
        _products = response.productDetails;
      });
    }
  }

void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
  for (final PurchaseDetails purchase in purchaseDetailsList) {
    if (purchase.status == PurchaseStatus.pending) {
      if (mounted) {
        _isPendingDialogShowing = true;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    purchasePendingWord[Provider.of<LanguageChanger>(context, listen: false).currentLanguage['language']] ?? 'Purchase Pending...',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: CustomLoadingSpinner(), // Use the custom loading spinner here
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      _isPendingDialogShowing = false; // Update the variable when dismissing the dialog
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                        borderRadius: BorderRadius.circular(15), // More pronounced rounded corners
                      ),
                      child: Text(
                        backWord[Provider.of<LanguageChanger>(context, listen: false).currentLanguage['language']] ?? 'Back',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    } else if (purchase.status == PurchaseStatus.error) {
      if (_isPendingDialogShowing && mounted) {
        Navigator.of(context).pop();
        _isPendingDialogShowing = false; // Update the variable when dismissing the dialog
      }
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    transactionErrorWord[Provider.of<LanguageChanger>(context, listen: false).currentLanguage['language']] ?? 'Transaction Error',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 10), // Add some space between the text and the icon
                  Icon(Icons.error, color: Colors.red, size: 50),
                ],
              ),
            );
          },
        );
      }
    } else if (purchase.status == PurchaseStatus.purchased) {
      if (_isPendingDialogShowing && mounted) {
        Navigator.of(context).pop();
        _isPendingDialogShowing = false; // Update the variable when dismissing the dialog
      }
      if (mounted) {
        _deliverProduct(purchase);
      }
    }

    if (purchase.pendingCompletePurchase) {
      _iap.completePurchase(purchase);
    }
  }
}



  void _deliverProduct(PurchaseDetails purchaseDetails) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                thankYouWord[Provider.of<LanguageChanger>(context, listen: false).currentLanguage['language']] ?? 'Thank you so much!',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 10), // Add some space between the text and the icon
              Icon(Icons.favorite, color: Colors.red, size: 100),
            ],
          ),
        );
      },
    );
  }


  void _handleDonation(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: true);
  }

  InkWell _buildDonateListTile(BuildContext context, Color backgroundColor, Color backgroundTextColor) {
    String currentLanguage = Provider.of<LanguageChanger>(context).currentLanguage['language'] ?? 'English';
    String fontFamily = isFontOpenSans(context) ? 'OpenSansCondensed' : 'Kapra';

    return InkWell(
      onTap: () {
        if (Provider.of<OverlayChanger>(context, listen: false).isVibrationOn) {
          HapticFeedback.mediumImpact();
        }
        showModalBottomSheet(
          context: context,
          builder: (BuildContext bc) {
            return ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
              child: _buildDonationList(context, backgroundColor, backgroundTextColor),
            );
          },
        );
      },
      child: ListTile(
        title: Text(
          donateWord[currentLanguage] ?? 'Donate',
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: isFontOpenSans(context) ? 28 : 36,
          ),
        ),
        trailing: const Padding(
          padding: EdgeInsets.only(right: 14.0),
          child: Icon(Icons.attach_money, size: 36),
        ),
      ),
    );
  }

  Widget _buildDonationList(BuildContext context, Color backgroundColor, Color backgroundTextColor) {
    String currentLanguage = Provider.of<LanguageChanger>(context).currentLanguage['language'] ?? 'English';

    ProductDetails? smallDonationProduct;
    ProductDetails? mediumDonationProduct;
    ProductDetails? largeDonationProduct;

    try {
      smallDonationProduct = _products.firstWhere((product) => product.id == 'tinycardslanguages_smalldonation');
      mediumDonationProduct = _products.firstWhere((product) => product.id == 'tinycardslanguages_mediumdonation');
      largeDonationProduct = _products.firstWhere((product) => product.id == 'tinycardslanguages_largedonation');
    } catch (e) {
      // If any product is not found, show the loading spinner
      return Center(
        child: CustomLoadingSpinner(),
      );
    }

    List<ProductDetails?> orderedProducts = [
      smallDonationProduct,
      mediumDonationProduct,
      largeDonationProduct,
    ];

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(7.0),
          child: ListTile(
            title: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: noOneLikesAds[currentLanguage] ?? 'No-one likes ads, subscriptions or paywalls...',
                    style: TextStyle(color: backgroundTextColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  TextSpan(
                    text: '\n\n', // New line added here
                  ),
                  TextSpan(
                    text: considerDonation[currentLanguage] ?? 'If you find this app useful, please consider making a donation! I maintain this app by myself and any contribution, no matter how small, is greatly appreciated.',
                    style: TextStyle(color: backgroundTextColor, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
        ...orderedProducts.map((product) {
          if (product == null) {
            return Center(child: CustomLoadingSpinner());
          }

          var priceString = product.price.replaceAll(RegExp(r'[^\d.]'), '');
          var formattedPrice = NumberFormat.simpleCurrency(name: product.currencyCode).format(double.parse(priceString));

          IconData icon;
          if (product.id == 'tinycardslanguages_smalldonation') {
            icon = Icons.sentiment_satisfied;
          } else if (product.id == 'tinycardslanguages_mediumdonation') {
            icon = Icons.sentiment_satisfied_alt;
          } else {
            icon = Icons.sentiment_very_satisfied;
          }

          return Column(
            children: <Widget>[
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [backgroundColor, backgroundTextColor, backgroundTextColor, backgroundColor],
                    stops: const [0.0, 0.2, 0.80, 1.0],
                  ),
                ),
              ),
              SizedBox(
                height: 70,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (Provider.of<OverlayChanger>(context, listen: false).isVibrationOn) {
                        HapticFeedback.lightImpact();
                      }
                      _handleDonation(product);
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(25.0, 8.0, 25.0, 10.0),
                      leading: Icon(icon, color: backgroundTextColor),
                      title: Text('$formattedPrice - ${product.title}', style: TextStyle(color: backgroundTextColor)),
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [backgroundColor, backgroundTextColor, backgroundTextColor, backgroundColor],
              stops: const [0.0, 0.2, 0.80, 1.0],
            ),
          ),
        ),
      ],
    );
  }


  String capitalize(String str) {
    if (str.isEmpty) {
      return str;
    }
    return str[0].toUpperCase() + str.substring(1).toLowerCase();
  }

  InkWell _buildDownloadVoicesListTile(BuildContext context, Color backgroundColor, Color backgroundTextColor) {
    String currentLanguage = Provider.of<LanguageChanger>(context).currentLanguage['language'] ?? 'English';
    String fontFamily = isFontOpenSans(context) ? 'OpenSansCondensed' : 'Kapra';

    return InkWell(
      onTap: () async {
        if (Provider.of<OverlayChanger>(context, listen: false).isVibrationOn) {
          HapticFeedback.mediumImpact();
        }
        if (Platform.isAndroid) {
          const AndroidIntent intent = AndroidIntent(
            action: 'com.android.settings.TTS_SETTINGS',
          );
          if (await intent.canResolveActivity()) {
            await intent.launch();
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(unableToOpenSettings[currentLanguage] ?? 'Unable to open settings')),
              );
            }
          }
        } else if (Platform.isIOS) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(installVoicesTitle[currentLanguage] ?? 'Install Additional Voices'),
                content: Text(installVoicesContent[currentLanguage] ?? 'To install additional voices, please go to Settings > General > Accessibility > Speech > Voices on your iOS device.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      if (Provider.of<OverlayChanger>(context, listen: false).isVibrationOn) {
                        HapticFeedback.mediumImpact();
                      }
                      Navigator.of(context).pop();
                    },
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        capitalize(backWord[currentLanguage] ?? 'Back'),
                        style: TextStyle(color: backgroundTextColor),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (Provider.of<OverlayChanger>(context, listen: false).isVibrationOn) {
                        HapticFeedback.mediumImpact();
                      }
                      const url = 'App-Prefs:root=General&path=ACCESSIBILITY/SPEECH';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(unableToOpenSettings[currentLanguage] ?? 'Unable to open settings')),
                          );
                        }
                      }
                    },
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        openSettings[currentLanguage] ?? 'Open Settings',
                        style: TextStyle(color: backgroundTextColor),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }
      },
      child: ListTile(
        title: Text(
          downloadVoicesWord[currentLanguage] ?? 'Download Additional Voices',
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: isFontOpenSans(context) ? 28 : 36,
          ),
        ),
        trailing: const Padding(
          padding: EdgeInsets.only(right: 14.0),
          child: Icon(Icons.record_voice_over_outlined, size: 36),
        ),
      ),
    );
  }

  InkWell _buildResetStatisticsListTile(BuildContext context, Color backgroundColor, Color backgroundTextColor) {
    String currentLanguage = Provider.of<LanguageChanger>(context).currentLanguage['language'] ?? 'English';
    String fontFamily = isFontOpenSans(context) ? 'OpenSansCondensed' : 'Kapra';

    return InkWell(
      onTap: () async {
        if (Provider.of<OverlayChanger>(context, listen: false).isVibrationOn) {
          HapticFeedback.mediumImpact();
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Provider.of<StatisticsData>(context, listen: false).resetStatistics();

        // Navigate to the initial route
        Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      },
      child: ListTile(
        title: Text(
          resetWord[currentLanguage] ?? 'Reset Statistics',
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: isFontOpenSans(context) ? 28 : 36,
          ),
        ),
        trailing: const Padding(
          padding: EdgeInsets.only(right: 14.0),
          child: Icon(Icons.replay, size: 36),
        ),
      ),
    );
  }

  InkWell _buildSuggestionsListTile(BuildContext context, Color backgroundColor, Color backgroundTextColor) {
    String currentLanguage = Provider.of<LanguageChanger>(context).currentLanguage['language'] ?? 'English';
    String fontFamily = isFontOpenSans(context) ? 'OpenSansCondensed' : 'Kapra';

    return InkWell(
      onTap: () async {
        if (Provider.of<OverlayChanger>(context, listen: false).isVibrationOn) {
          HapticFeedback.mediumImpact();
        }
        _launchEmail();
      },
      child: ListTile(
        title: Text(
          suggestionWord[currentLanguage] ?? 'Send Suggestion',
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: isFontOpenSans(context) ? 28 : 36,
          ),
        ),
        trailing: const Padding(
          padding: EdgeInsets.only(right: 14.0),
          child: Icon(Icons.mail_outline, size: 36),
        ),
      ),
    );
  }

  void _launchEmail() async {
    if (Platform.isIOS) {
      final Uri params = Uri(
        scheme: 'mailto',
        path: 'contact@innobytez.com',
        query: 'subject=Suggestion%20for%20Tiny%20Cards:%20Languages',
      );

      String url = params.toString();
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } else if (Platform.isAndroid) {
      final Email email = Email(
        body: 'Email body',
        subject: 'Suggestion for Tiny Cards: Languages',
        recipients: ['contact@innobytez.com'],
      );

      try {
        await FlutterEmailSender.send(email);
      } catch (error) {
        if (error.toString().contains('not_available')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No email clients found on device.'),
            ),
          );
        } else {
          print('Could not send email: $error');
        }
      }
    }
  }
}
