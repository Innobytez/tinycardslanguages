import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/services.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinycards/flashcard.dart';
import 'package:tinycards/flashcard_data.dart';
import 'package:tinycards/help_page.dart';
import 'package:tinycards/language_changer.dart';
import 'package:tinycards/overlay_changer.dart';
import 'package:tinycards/settings_page.dart';
import 'package:tinycards/constants.dart';
import 'package:tinycards/statistics_changer.dart';
import 'dart:ui';

String removeDiacritics(String str) {
  return diacriticsMap[str] ?? str;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool _languageSelected = false;
  // ignore: unused_field
  String _selectedLanguage = ''; // The selected language to be used in the flashcards - for some reason the dart analyzer says unused - but it definitely is used!
  String _displayLanguage = '';
  PageController pageController = PageController(initialPage: 1);
  late LanguageChanger _languageChanger;

  @override
  void initState() {
    super.initState();
    _languageChanger = Provider.of<LanguageChanger>(context, listen: false);
    _languageChanger.addListener(_languageChanged);
  }

  @override
  void dispose() {
    _languageChanger.removeListener(_languageChanged);
    super.dispose();
  }

  // Handles language change by resetting the selection state
  void _languageChanged() {
    setState(() {
      _languageSelected = false;
    });
  }

  // Handles horizontal drag update to navigate between pages
  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    pageController.position.moveTo(
      pageController.position.pixels - details.delta.dx,
    );
  }

  // Handles the end of a horizontal drag to navigate pages with inertia and velocity
  void _onHorizontalDragEnd(DragEndDetails details) {
    if (details.primaryVelocity! > 0 && pageController.page! > 0 && details.primaryVelocity! < 500) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (details.primaryVelocity! < 0 && pageController.page! < 2 && details.primaryVelocity! > -500) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView(
          controller: pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            SettingsScreen(pageController: pageController, pageIndex: 1),
            buildMainScreen(context),
            HelpScreen(pageController: pageController, pageIndex: 1),
          ],
        ),
        buildGestureDetector(left: true),
        buildGestureDetector(left: false),
      ],
    );
  }

  // Builds the main screen with settings, language, and help buttons
  Widget buildMainScreen(BuildContext context) {
    List<Map<String, String>> languages = getLanguages(context);
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color backgroundColor = isDarkMode ? Colors.black : Colors.white;
    Color backgroundTextColor = isDarkMode ? Colors.white : Colors.black;
    Color textColor = isDarkMode ? Colors.black : Colors.white;
    Color borderColor = isDarkMode ? Colors.black : Colors.white;
    Color iconColor = isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: mainColor,
      body: Padding(
        padding: const EdgeInsets.only(top: 30.0, bottom: 0.0),
        child: Stack(
          children: <Widget>[
            buildTopPositioned(context, textColor),
            buildBottomPositioned(context, iconColor),
            buildMiddlePositioned(context, languages, backgroundColor, backgroundTextColor, textColor, borderColor),
          ],
        ),
      ),
    );
  }

  // Builds the top positioned widget with the title text
  Positioned buildTopPositioned(BuildContext context, Color textColor) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: MediaQuery.of(context).size.height * 0.2,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Transform(
                transform: Matrix4.diagonal3Values(
                  constraints.maxWidth / 160,
                  constraints.maxHeight / 50,
                  1.0,
                ),
                alignment: FractionalOffset.center,
                child: Text(
                  'TINY CARDS',
                  style: TextStyle(
                    fontSize: 50,
                    fontFamily: 'Kapra',
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Builds the bottom positioned widget with settings, language, and help buttons
  Positioned buildBottomPositioned(BuildContext context, Color iconColor) {
    const double iconSize = 64.0;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildIconButton(context, Icons.settings, iconSize, iconColor, 0),
              buildLanguageButton(context, iconColor),
              buildIconButton(context, Icons.help, iconSize, iconColor, 2),
            ],
          );
        },
      ),
    );
  }

  // Builds an icon button with navigation functionality
  IconButton buildIconButton(BuildContext context, IconData icon, double iconSize, Color iconColor, int page) {
    return IconButton(
      icon: Icon(icon, size: iconSize, color: iconColor),
      onPressed: () {
        if (Provider.of<OverlayChanger>(context, listen: false).isVibrationOn) {
          HapticFeedback.mediumImpact();
        }
        pageController.animateToPage(
          page,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  // Builds the language selection button with dynamic text
  Expanded buildLanguageButton(BuildContext context, Color textColor) {
    bool isFontOpenSans = checkFontOpenSans(context);

    return Expanded(
      child: IconButton(
        icon: SizedBox(
          height: 90,
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: isFontOpenSans ? const EdgeInsets.all(0) : const EdgeInsets.only(top: 8.0),
              child: Text(
                removeDiacritics(
                  _languageSelected ? _displayLanguage :
                  languagesWord[Provider.of<LanguageChanger>(context).currentLanguage['language']] ?? 'LANGUAGES'
                ).toUpperCase(),
                style: TextStyle(
                  fontSize: 70,
                  fontFamily: isFontOpenSans ? 'OpenSansCondensed' : 'Kapra',
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        onPressed: () {
          if (_languageSelected) {
            if (Provider.of<OverlayChanger>(context, listen: false).isVibrationOn) {
              HapticFeedback.heavyImpact();
            }
            setState(() {
              _languageSelected = !_languageSelected;
            });
          }
        },
      ),
    );
  }

  // Checks if the current language requires the OpenSansCondensed font
  bool checkFontOpenSans(BuildContext context) {
    List<String> openSansLanguages = [
      'Greek', 'Azerbaijani', 'Russian', 'Mandarin', 'Hebrew', 'Hindi', 'Bengali', 'Japanese', 'Korean', 'Arabic', 
      'Thai', 'Tamil', 'Telugu', 'Kannada', 'Malayalam', 'Sinhala', 'Amharic', 'Georgian', 'Khmer',
      'Lao', 'Myanmar (Burmese)', 'Yiddish', 'Gujarati', 'Urdu', 'Pashto', 'Farsi', 'Ukrainian', 
      'Cyrillic', 'Afrikaans', 'Albanian', 'Armenian', 'Azerbaijani', 'Basque', 'Belarusian', 'Bosnian',
      'Bulgarian', 'Catalan', 'Cebuano', 'Chichewa', 'Corsican', 'Croatian', 'Czech', 'Danish', 'Dutch',
      'Esperanto', 'Estonian', 'Filipino', 'Finnish', 'Frisian', 'Galician', 'Haitian Creole', 'Hausa',
      'Hawaiian', 'Hmong', 'Hungarian', 'Icelandic', 'Igbo', 'Indonesian', 'Irish', 'Javanese', 'Kazakh',
      'Kurdish (Kurmanji)', 'Kyrgyz', 'Latin', 'Latvian', 'Lithuanian', 'Luxembourgish', 'Macedonian',
      'Malagasy', 'Malay', 'Maori', 'Marathi', 'Mongolian', 'Nepali', 'Norwegian', 'Polish', 'Portuguese',
      'Punjabi', 'Romanian', 'Samoan', 'Scots Gaelic', 'Serbian', 'Sesotho', 'Shona', 'Sindhi', 'Slovak',
      'Slovenian', 'Somali', 'Sundanese', 'Swahili', 'Swedish', 'Tajik', 'Ukrainian', 'Uzbek', 'Vietnamese',
      'Welsh', 'Xhosa', 'Yoruba', 'Zulu'
    ];

    return openSansLanguages.contains(Provider.of<LanguageChanger>(context).currentLanguage['language']);
  }

  // Builds the middle positioned widget with either the language list or flashcards
  Positioned buildMiddlePositioned(BuildContext context, List<Map<String, String>> languages, Color backgroundColor, Color backgroundTextColor, Color textColor, Color borderColor) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.15,
      left: 20,
      right: 20,
      bottom: 75,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _languageSelected ? 
          Flashcard(
            key: const ValueKey<int>(1),
            onDispose: (controllers) => disposeAnimationControllers(controllers), initialFlashcards: FlashcardData,
          ) 
        : buildLanguageList(context, languages, backgroundColor, backgroundTextColor, textColor, borderColor,
            key: const ValueKey<int>(2),
          ),
      ),
    );
  }

  // Disposes animation controllers when they are no longer needed
  void disposeAnimationControllers(List<AnimationController> controllers) {
    for (var controller in controllers) {
      controller.dispose();
    }
  }

  // Builds the language list widget with flags and learned cards count
  Padding buildLanguageList(BuildContext context, List<Map<String, String>> languages, Color backgroundColor, Color backgroundTextColor, Color textColor, Color borderColor, {Key? key}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: FutureBuilder<List<String>>(
        future: getSelectedLanguages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            List<String> selectedLanguages = snapshot.data ?? [];
            // Move all selected languages to the top of the list
            for (String selectedLanguage in selectedLanguages.reversed) {
              int selectedIndex = languages.indexWhere((lang) => lang['language'] == selectedLanguage);
              if (selectedIndex != -1) {
                Map<String, String> selectedLang = languages.removeAt(selectedIndex);
                languages.insert(0, selectedLang);
              }
            }
            return Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
                boxShadow: const [
                  BoxShadow(
                    offset: Offset(-5, -5),
                    blurRadius: 10,
                    color: Color.fromARGB(200, 108, 108, 108),
                    inset: true,
                  ),
                  BoxShadow(
                    offset: Offset(5, 5),
                    blurRadius: 10,
                    color: Color.fromARGB(200, 108, 108, 108),
                    inset: true,
                  ),
                  BoxShadow(
                    offset: Offset(-5, 5),
                    blurRadius: 10,
                    color: Color.fromARGB(200, 108, 108, 108),
                    inset: true,
                  ),
                  BoxShadow(
                    offset: Offset(5, -5),
                    blurRadius: 10,
                    color: Color.fromARGB(200, 108, 108, 108),
                    inset: true,
                  ),
                ],
              ),
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (OverscrollIndicatorNotification overscroll) {
                  overscroll.disallowIndicator();
                  return true;
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[Colors.transparent, backgroundColor, backgroundColor, Colors.transparent],
                        stops: [0.0, 0.02, 0.98, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: DefaultTextStyle(
                      style: TextStyle(color: textColor),
                      child: ListView.separated(
                        padding: const EdgeInsets.only(top: 5.0, bottom: 8.0),
                        separatorBuilder: (context, index) => buildSeparator(context, backgroundColor, backgroundTextColor),
                        itemCount: languages.length,
                        itemBuilder: (context, index) {
                          var lang = languages[index];
                          return buildLanguageItem(context, lang, backgroundTextColor);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            // Show a loading spinner while waiting for the selected language to load
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  // Builds the separator between language items
  Container buildSeparator(BuildContext context, Color backgroundColor, Color backgroundTextColor) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, backgroundTextColor, backgroundTextColor, Colors.transparent],
          stops: const [0.0, 0.1, 0.90, 1.0],
        ),
      ),
    );
  }

  // Builds a language item with flag and learned cards count
  SizedBox buildLanguageItem(BuildContext context, Map<String, String> lang, Color backgroundTextColor) {
    String language = lang['language']!.toLowerCase();
    return SizedBox(
      height: 70,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            if (Provider.of<OverlayChanger>(context, listen: false).isVibrationOn) {
              HapticFeedback.lightImpact();
            }

            setState(() {
              _languageSelected = true;
              _selectedLanguage = lang['language']!;
              _displayLanguage = lang['displayLanguage']!;
            });

            // Save selected language
            SharedPreferences prefs = await SharedPreferences.getInstance();
            List<String> selectedLanguages = prefs.getStringList('selectedLanguages') ?? [];
            selectedLanguages.remove(lang['language']!); // remove the selected language if it already exists
            selectedLanguages.insert(0, lang['language']!); // insert the selected language at the beginning
            await prefs.setStringList('selectedLanguages', selectedLanguages);
          },
          child: FutureBuilder(
            future: Provider.of<StatisticsData>(context, listen: false).loadLearnedCards(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(); // Show a loading spinner while waiting for the data to load
              } else if (snapshot.error != null) {
                return Text('Error: ${snapshot.error}'); // Show an error message if something went wrong
              } else {
                int learnedCardsCount = Provider.of<StatisticsData>(context).getLearnedCardsCount(language);
                return ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(25.0, 8.0, 0.0, 10.0),
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
                  title: Text(lang['displayLanguage']!, style: TextStyle(color: backgroundTextColor)),
                  trailing: learnedCardsCount > 0
                    ? Padding(
                        padding: const EdgeInsets.only(right: 25.0), // Add padding to the right side
                        child: Text(
                          '$learnedCardsCount/1000',
                          style: TextStyle(color: backgroundTextColor), // Use the same text style as the language title
                        ),
                      )
                    : null,
                );
              }
            },
          ),
        ),
      ),
    );
  }

  // Retrieves the list of selected languages from shared preferences
  Future<List<String>> getSelectedLanguages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('selectedLanguages') ?? [];
  }

List<Map<String, String>> getLanguages(BuildContext context) {
  String currentLanguage = Provider.of<LanguageChanger>(context).currentLanguage['language'] ?? 'English';

  List<Map<String, String>> languages = [
    {'flag': 'assets/flags/za.png', 'language': 'Afrikaans', 'displayLanguage': afrikaansWord[currentLanguage] ?? 'Afrikaans'},
    {'flag': 'assets/flags/al.png', 'language': 'Albanian', 'displayLanguage': albanianWord[currentLanguage] ?? 'Albanian'},
    {'flag': 'assets/flags/et.png', 'language': 'Amharic', 'displayLanguage': amharicWord[currentLanguage] ?? 'Amharic'},
    {'flag': 'assets/flags/ae.png', 'language': 'Arabic', 'displayLanguage': arabicWord[currentLanguage] ?? 'Arabic'},
    {'flag': 'assets/flags/am.png', 'language': 'Armenian', 'displayLanguage': armenianWord[currentLanguage] ?? 'Armenian'},
    {'flag': 'assets/flags/az.png', 'language': 'Azerbaijani', 'displayLanguage': azerbaijaniWord[currentLanguage] ?? 'Azerbaijani'},
    {'flag': 'assets/flags/es.png', 'language': 'Basque', 'displayLanguage': basqueWord[currentLanguage] ?? 'Basque'},
    {'flag': 'assets/flags/by.png', 'language': 'Belarusian', 'displayLanguage': belarusianWord[currentLanguage] ?? 'Belarusian'},
    {'flag': 'assets/flags/bd.png', 'language': 'Bengali', 'displayLanguage': bengaliWord[currentLanguage] ?? 'Bengali'},
    {'flag': 'assets/flags/ba.png', 'language': 'Bosnian', 'displayLanguage': bosnianWord[currentLanguage] ?? 'Bosnian'},
    {'flag': 'assets/flags/bg.png', 'language': 'Bulgarian', 'displayLanguage': bulgarianWord[currentLanguage] ?? 'Bulgarian'},
    {'flag': 'assets/flags/es.png', 'language': 'Catalan', 'displayLanguage': catalanWord[currentLanguage] ?? 'Catalan'},
    {'flag': 'assets/flags/ph.png', 'language': 'Cebuano', 'displayLanguage': cebuanoWord[currentLanguage] ?? 'Cebuano'},
    {'flag': 'assets/flags/mw.png', 'language': 'Chichewa', 'displayLanguage': chichewaWord[currentLanguage] ?? 'Chichewa'},
    {'flag': 'assets/flags/cn.png', 'language': 'Chinese', 'displayLanguage': chineseWord[currentLanguage] ?? 'Chinese'},
    {'flag': 'assets/flags/fr.png', 'language': 'Corsican', 'displayLanguage': corsicanWord[currentLanguage] ?? 'Corsican'},
    {'flag': 'assets/flags/hr.png', 'language': 'Croatian', 'displayLanguage': croatianWord[currentLanguage] ?? 'Croatian'},
    {'flag': 'assets/flags/cz.png', 'language': 'Czech', 'displayLanguage': czechWord[currentLanguage] ?? 'Czech'},
    {'flag': 'assets/flags/dk.png', 'language': 'Danish', 'displayLanguage': danishWord[currentLanguage] ?? 'Danish'},
    {'flag': 'assets/flags/nl.png', 'language': 'Dutch', 'displayLanguage': dutchWord[currentLanguage] ?? 'Dutch'},
    {'flag': 'assets/flags/esp.png', 'language': 'Esperanto', 'displayLanguage': esperantoWord[currentLanguage] ?? 'Esperanto'},
    {'flag': 'assets/flags/ee.png', 'language': 'Estonian', 'displayLanguage': estonianWord[currentLanguage] ?? 'Estonian'},
    {'flag': 'assets/flags/ph.png', 'language': 'Filipino', 'displayLanguage': filipinoWord[currentLanguage] ?? 'Filipino'},
    {'flag': 'assets/flags/fi.png', 'language': 'Finnish', 'displayLanguage': finnishWord[currentLanguage] ?? 'Finnish'},
    {'flag': 'assets/flags/nl.png', 'language': 'Frisian', 'displayLanguage': frisianWord[currentLanguage] ?? 'Frisian'},
    {'flag': 'assets/flags/es.png', 'language': 'Galician', 'displayLanguage': galicianWord[currentLanguage] ?? 'Galician'},
    {'flag': 'assets/flags/ge.png', 'language': 'Georgian', 'displayLanguage': georgianWord[currentLanguage] ?? 'Georgian'},
    {'flag': 'assets/flags/us.png', 'language': 'English', 'displayLanguage': englishWord[currentLanguage] ?? 'English'},
    {'flag': 'assets/flags/fr.png', 'language': 'French', 'displayLanguage': frenchWord[currentLanguage] ?? 'French'},
    {'flag': 'assets/flags/de.png', 'language': 'German', 'displayLanguage': germanWord[currentLanguage] ?? 'German'},
    {'flag': 'assets/flags/gr.png', 'language': 'Greek', 'displayLanguage': greekWord[currentLanguage] ?? 'Greek'},
    {'flag': 'assets/flags/in.png', 'language': 'Gujarati', 'displayLanguage': gujaratiWord[currentLanguage] ?? 'Gujarati'},
    {'flag': 'assets/flags/ht.png', 'language': 'Haitian Creole', 'displayLanguage': haitianCreoleWord[currentLanguage] ?? 'Haitian Creole'},
    {'flag': 'assets/flags/ng.png', 'language': 'Hausa', 'displayLanguage': hausaWord[currentLanguage] ?? 'Hausa'},
    {'flag': 'assets/flags/us.png', 'language': 'Hawaiian', 'displayLanguage': hawaiianWord[currentLanguage] ?? 'Hawaiian'},
    {'flag': 'assets/flags/il.png', 'language': 'Hebrew', 'displayLanguage': hebrewWord[currentLanguage] ?? 'Hebrew'},
    {'flag': 'assets/flags/in.png', 'language': 'Hindi', 'displayLanguage': hindiWord[currentLanguage] ?? 'Hindi'},
    {'flag': 'assets/flags/cn.png', 'language': 'Hmong', 'displayLanguage': hmongWord[currentLanguage] ?? 'Hmong'},
    {'flag': 'assets/flags/hu.png', 'language': 'Hungarian', 'displayLanguage': hungarianWord[currentLanguage] ?? 'Hungarian'},
    {'flag': 'assets/flags/is.png', 'language': 'Icelandic', 'displayLanguage': icelandicWord[currentLanguage] ?? 'Icelandic'},
    {'flag': 'assets/flags/ng.png', 'language': 'Igbo', 'displayLanguage': igboWord[currentLanguage] ?? 'Igbo'},
    {'flag': 'assets/flags/id.png', 'language': 'Indonesian', 'displayLanguage': indonesianWord[currentLanguage] ?? 'Indonesian'},
    {'flag': 'assets/flags/ie.png', 'language': 'Irish', 'displayLanguage': irishWord[currentLanguage] ?? 'Irish'},
    {'flag': 'assets/flags/it.png', 'language': 'Italian', 'displayLanguage': italianWord[currentLanguage] ?? 'Italian'},
    {'flag': 'assets/flags/jp.png', 'language': 'Japanese', 'displayLanguage': japaneseWord[currentLanguage] ?? 'Japanese'},
    {'flag': 'assets/flags/id.png', 'language': 'Javanese', 'displayLanguage': javaneseWord[currentLanguage] ?? 'Javanese'},
    {'flag': 'assets/flags/in.png', 'language': 'Kannada', 'displayLanguage': kannadaWord[currentLanguage] ?? 'Kannada'},
    {'flag': 'assets/flags/kz.png', 'language': 'Kazakh', 'displayLanguage': kazakhWord[currentLanguage] ?? 'Kazakh'},
    {'flag': 'assets/flags/kh.png', 'language': 'Khmer', 'displayLanguage': khmerWord[currentLanguage] ?? 'Khmer'},
    {'flag': 'assets/flags/kr.png', 'language': 'Korean', 'displayLanguage': koreanWord[currentLanguage] ?? 'Korean'},
    {'flag': 'assets/flags/iq.png', 'language': 'Kurdish (Kurmanji)', 'displayLanguage': kurdishWord[currentLanguage] ?? 'Kurdish (Kurmanji)'},
    {'flag': 'assets/flags/kg.png', 'language': 'Kyrgyz', 'displayLanguage': kyrgyzWord[currentLanguage] ?? 'Kyrgyz'},
    {'flag': 'assets/flags/la.png', 'language': 'Lao', 'displayLanguage': laoWord[currentLanguage] ?? 'Lao'},
    {'flag': 'assets/flags/va.png', 'language': 'Latin', 'displayLanguage': latinWord[currentLanguage] ?? 'Latin'},
    {'flag': 'assets/flags/lv.png', 'language': 'Latvian', 'displayLanguage': latvianWord[currentLanguage] ?? 'Latvian'},
    {'flag': 'assets/flags/lt.png', 'language': 'Lithuanian', 'displayLanguage': lithuanianWord[currentLanguage] ?? 'Lithuanian'},
    {'flag': 'assets/flags/lu.png', 'language': 'Luxembourgish', 'displayLanguage': luxembourgishWord[currentLanguage] ?? 'Luxembourgish'},
    {'flag': 'assets/flags/mk.png', 'language': 'Macedonian', 'displayLanguage': macedonianWord[currentLanguage] ?? 'Macedonian'},
    {'flag': 'assets/flags/mg.png', 'language': 'Malagasy', 'displayLanguage': malagasyWord[currentLanguage] ?? 'Malagasy'},
    {'flag': 'assets/flags/my.png', 'language': 'Malay', 'displayLanguage': malayWord[currentLanguage] ?? 'Malay'},
    {'flag': 'assets/flags/in.png', 'language': 'Malayalam', 'displayLanguage': malayalamWord[currentLanguage] ?? 'Malayalam'},
    {'flag': 'assets/flags/mt.png', 'language': 'Maltese', 'displayLanguage': malteseWord[currentLanguage] ?? 'Maltese'},
    {'flag': 'assets/flags/nz.png', 'language': 'Maori', 'displayLanguage': maoriWord[currentLanguage] ?? 'Maori'},
    {'flag': 'assets/flags/in.png', 'language': 'Marathi', 'displayLanguage': marathiWord[currentLanguage] ?? 'Marathi'},
    {'flag': 'assets/flags/mn.png', 'language': 'Mongolian', 'displayLanguage': mongolianWord[currentLanguage] ?? 'Mongolian'},
    {'flag': 'assets/flags/mm.png', 'language': 'Myanmar (Burmese)', 'displayLanguage': myanmarWord[currentLanguage] ?? 'Myanmar (Burmese)'},
    {'flag': 'assets/flags/np.png', 'language': 'Nepali', 'displayLanguage': nepaliWord[currentLanguage] ?? 'Nepali'},
    {'flag': 'assets/flags/no.png', 'language': 'Norwegian', 'displayLanguage': norwegianWord[currentLanguage] ?? 'Norwegian'},
    {'flag': 'assets/flags/af.png', 'language': 'Pashto', 'displayLanguage': pashtoWord[currentLanguage] ?? 'Pashto'},
    {'flag': 'assets/flags/ir.png', 'language': 'Persian', 'displayLanguage': persianWord[currentLanguage] ?? 'Persian'},
    {'flag': 'assets/flags/pl.png', 'language': 'Polish', 'displayLanguage': polishWord[currentLanguage] ?? 'Polish'},
    {'flag': 'assets/flags/pt.png', 'language': 'Portuguese', 'displayLanguage': portugueseWord[currentLanguage] ?? 'Portuguese'},
    {'flag': 'assets/flags/in.png', 'language': 'Punjabi', 'displayLanguage': punjabiWord[currentLanguage] ?? 'Punjabi'},
    {'flag': 'assets/flags/ro.png', 'language': 'Romanian', 'displayLanguage': romanianWord[currentLanguage] ?? 'Romanian'},
    {'flag': 'assets/flags/ru.png', 'language': 'Russian', 'displayLanguage': russianWord[currentLanguage] ?? 'Russian'},
    {'flag': 'assets/flags/ws.png', 'language': 'Samoan', 'displayLanguage': samoanWord[currentLanguage] ?? 'Samoan'},
    {'flag': 'assets/flags/gb-sct.png', 'language': 'Scots Gaelic', 'displayLanguage': scotsWord[currentLanguage] ?? 'Scots Gaelic'},
    {'flag': 'assets/flags/rs.png', 'language': 'Serbian', 'displayLanguage': serbianWord[currentLanguage] ?? 'Serbian'},
    {'flag': 'assets/flags/ls.png', 'language': 'Sesotho', 'displayLanguage': sesothoWord[currentLanguage] ?? 'Sesotho'},
    {'flag': 'assets/flags/zw.png', 'language': 'Shona', 'displayLanguage': shonaWord[currentLanguage] ?? 'Shona'},
    {'flag': 'assets/flags/pk.png', 'language': 'Sindhi', 'displayLanguage': sindhiWord[currentLanguage] ?? 'Sindhi'},
    {'flag': 'assets/flags/lk.png', 'language': 'Sinhala', 'displayLanguage': sinhalaWord[currentLanguage] ?? 'Sinhala'},
    {'flag': 'assets/flags/sk.png', 'language': 'Slovak', 'displayLanguage': slovakWord[currentLanguage] ?? 'Slovak'},
    {'flag': 'assets/flags/si.png', 'language': 'Slovenian', 'displayLanguage': slovenianWord[currentLanguage] ?? 'Slovenian'},
    {'flag': 'assets/flags/so.png', 'language': 'Somali', 'displayLanguage': somaliWord[currentLanguage] ?? 'Somali'},
    {'flag': 'assets/flags/id.png', 'language': 'Sundanese', 'displayLanguage': sundaneseWord[currentLanguage] ?? 'Sundanese'},
    {'flag': 'assets/flags/tz.png', 'language': 'Swahili', 'displayLanguage': swahiliWord[currentLanguage] ?? 'Swahili'},
    {'flag': 'assets/flags/se.png', 'language': 'Swedish', 'displayLanguage': swedishWord[currentLanguage] ?? 'Swedish'},
    {'flag': 'assets/flags/tj.png', 'language': 'Tajik', 'displayLanguage': tajikWord[currentLanguage] ?? 'Tajik'},
    {'flag': 'assets/flags/in.png', 'language': 'Tamil', 'displayLanguage': tamilWord[currentLanguage] ?? 'Tamil'},
    {'flag': 'assets/flags/in.png', 'language': 'Telugu', 'displayLanguage': teluguWord[currentLanguage] ?? 'Telugu'},
    {'flag': 'assets/flags/th.png', 'language': 'Thai', 'displayLanguage': thaiWord[currentLanguage] ?? 'Thai'},
    {'flag': 'assets/flags/tr.png', 'language': 'Turkish', 'displayLanguage': turkishWord[currentLanguage] ?? 'Turkish'},
    {'flag': 'assets/flags/ua.png', 'language': 'Ukrainian', 'displayLanguage': ukrainianWord[currentLanguage] ?? 'Ukrainian'},
    {'flag': 'assets/flags/pk.png', 'language': 'Urdu', 'displayLanguage': urduWord[currentLanguage] ?? 'Urdu'},
    {'flag': 'assets/flags/uz.png', 'language': 'Uzbek', 'displayLanguage': uzbekWord[currentLanguage] ?? 'Uzbek'},
    {'flag': 'assets/flags/vn.png', 'language': 'Vietnamese', 'displayLanguage': vietnameseWord[currentLanguage] ?? 'Vietnamese'},
    {'flag': 'assets/flags/gb-wls.png', 'language': 'Welsh', 'displayLanguage': welshWord[currentLanguage] ?? 'Welsh'},
    {'flag': 'assets/flags/za.png', 'language': 'Xhosa', 'displayLanguage': xhosaWord[currentLanguage] ?? 'Xhosa'},
    {'flag': 'assets/flags/il.png', 'language': 'Yiddish', 'displayLanguage': yiddishWord[currentLanguage] ?? 'Yiddish'},
    {'flag': 'assets/flags/ng.png', 'language': 'Yoruba', 'displayLanguage': yorubaWord[currentLanguage] ?? 'Yoruba'},
    {'flag': 'assets/flags/za.png', 'language': 'Zulu', 'displayLanguage': zuluWord[currentLanguage] ?? 'Zulu'}
  ];

  // Remove the current language from the list
  languages.removeWhere((lang) => lang['language'] == currentLanguage);

  // Sort the languages alphabetically by their displayLanguage
  languages.sort((a, b) => a['displayLanguage']!.compareTo(b['displayLanguage']!));

  return languages;
}


  // Builds a gesture detector for horizontal drag gestures
  Positioned buildGestureDetector({required bool left}) {
    return Positioned(
      left: left ? 0 : null,
      right: left ? null : 0,
      top: 0,
      bottom: 0,
      width: 20,
      child: GestureDetector(
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
