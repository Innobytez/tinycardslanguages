import 'dart:async';
import 'dart:convert';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'overlay_changer.dart';
import 'language_changer.dart';
import 'statistics_changer.dart';
import 'constants.dart';

class Flashcard extends StatefulWidget {
  final List<Map<String, String>> initialFlashcards;
  final Function(List<AnimationController>) onDispose;

  const Flashcard({super.key, required this.initialFlashcards, required this.onDispose});

  @override
  FlashcardState createState() => FlashcardState();
}

class FlashcardState extends State<Flashcard> with TickerProviderStateMixin, WidgetsBindingObserver {
  late List<Map<String, String>> flashcards;
  CardSwiperDirection? swipeDirection;
  late AnimationController animationController;
  final List<AnimationController> _animationControllers = [];
  List<OverlayEntry> overlayEntries = [];
  String selectedLanguage = 'English';
  late FlutterTts flutterTts;
  int currentIndex = 0;
  final Map<String, dynamic> _cache = {};
  bool isAnimating = false;
  List<String> availableLanguages = [];

  final Map<String, String> languageToTtsCode = {
    'english': 'en-US', 'spanish': 'es-ES', 'french': 'fr-FR', 'afrikaans': 'af-ZA', 'albanian': 'sq-AL',
    'amharic': 'am-ET', 'arabic': 'ar-SA', 'armenian': 'hy-AM', 'azerbaijani': 'az-AZ', 'basque': 'eu-ES',
    'belarusian': 'be-BY', 'bengali': 'bn-BD', 'bosnian': 'bs-BA', 'bulgarian': 'bg-BG', 'catalan': 'ca-ES',
    'cebuano': 'ceb-PH', 'chichewa': 'ny-MW', 'chinese': 'zh-CN', 'mandarin': 'zh-CN', 'corsican': 'co-FR',
    'croatian': 'hr-HR', 'czech': 'cs-CZ', 'danish': 'da-DK', 'dutch': 'nl-NL', 'esperanto': 'eo-EU',
    'estonian': 'et-EE', 'filipino': 'fil-PH', 'finnish': 'fi-FI', 'frisian': 'fy-NL', 'galician': 'gl-ES',
    'georgian': 'ka-GE', 'german': 'de-DE', 'greek': 'el-GR', 'gujarati': 'gu-IN', 'haitian creole': 'ht-HT',
    'hausa': 'ha-NE', 'hawaiian': 'haw-US', 'hebrew': 'he-IL', 'hindi': 'hi-IN', 'hmong': 'hmn-CN',
    'hungarian': 'hu-HU', 'icelandic': 'is-IS', 'igbo': 'ig-NG', 'indonesian': 'id-ID', 'irish': 'ga-IE',
    'italian': 'it-IT', 'japanese': 'ja-JP', 'javanese': 'jv-ID', 'kannada': 'kn-IN', 'kazakh': 'kk-KZ',
    'khmer': 'km-KH', 'korean': 'ko-KR', 'kurdish (kurmanji)': 'ku-TR', 'kyrgyz': 'ky-KG', 'lao': 'lo-LA',
    'latin': 'la-LA', 'latvian': 'lv-LV', 'lithuanian': 'lt-LT', 'luxembourgish': 'lb-LU', 'macedonian': 'mk-MK',
    'malagasy': 'mg-MG', 'malay': 'ms-MY', 'malayalam': 'ml-IN', 'maltese': 'mt-MT', 'maori': 'mi-NZ',
    'marathi': 'mr-IN', 'mongolian': 'mn-MN', 'myanmar (burmese)': 'my-MM', 'nepali': 'ne-NP', 'norwegian': 'no-NO',
    'pashto': 'ps-AF', 'persian': 'fa-IR', 'polish': 'pl-PL', 'portuguese': 'pt-PT', 'punjabi': 'pa-IN',
    'romanian': 'ro-RO', 'russian': 'ru-RU', 'samoan': 'sm-WS', 'scots gaelic': 'gd-GB', 'serbian': 'sr-RS',
    'sesotho': 'st-LS', 'shona': 'sn-ZW', 'sindhi': 'sd-IN', 'sinhala': 'si-LK', 'slovak': 'sk-SK',
    'slovenian': 'sl-SI', 'somali': 'so-SO', 'sundanese': 'su-ID', 'swahili': 'sw-KE', 'swedish': 'sv-SE',
    'tajik': 'tg-TJ', 'tamil': 'ta-IN', 'telugu': 'te-IN', 'thai': 'th-TH', 'turkish': 'tr-TR', 'ukrainian': 'uk-UA',
    'urdu': 'ur-PK', 'uzbek': 'uz-UZ', 'vietnamese': 'vi-VN', 'welsh': 'cy-GB', 'xhosa': 'xh-ZA', 'yiddish': 'yi-YD',
    'yoruba': 'yo-NG', 'zulu': 'zu-ZA'
  };

  @override
  void initState() {
    super.initState();
    flashcards = List.from(widget.initialFlashcards); // Initialize flashcards with the data passed to the widget
    WidgetsBinding.instance.addObserver(this); // Add observer to listen to the app's lifecycle events
    animationController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this); // Initialize animation controller
    flutterTts = FlutterTts(); // Initialize TTS instance
    _initializeApp(); // Initialize the app-specific settings and data
  }

  // Method to initialize app-specific settings and data
  Future<void> _initializeApp() async {
    await _loadSelectedLanguage(); // Load the selected language from persistent storage
    await _initializeTts(); // Initialize TTS settings
    await _loadState(); // Load the saved state of flashcards
    await _loadAvailableLanguages(); // Load available TTS languages to avoid repeated fetches
  }

  // Method to initialize TTS settings
  Future<void> _initializeTts() async {
    await flutterTts.awaitSpeakCompletion(true); // Ensure TTS awaits speech completion before moving on
  }

  // Method to load available TTS languages once
  Future<void> _loadAvailableLanguages() async {
    availableLanguages = List<String>.from(await flutterTts.getLanguages); // Fetch and store available TTS languages
    setState(() {}); // Update the state to refresh the UI with available languages
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer to prevent memory leaks
    widget.onDispose.call(_animationControllers); // Dispose animation controllers
    for (var overlay in overlayEntries) {
      overlay.remove(); // Remove overlay entries to clean up resources
    }
    animationController.dispose(); // Dispose the main animation controller
    super.dispose();
  }

  // Method to load the selected language from shared preferences
  Future<void> _loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); // Access shared preferences
    List<String> selectedLanguages = prefs.getStringList('selectedLanguages') ?? []; // Get the selected languages or an empty list
    setState(() {
      selectedLanguage = selectedLanguages.isNotEmpty ? selectedLanguages.first : 'English'; // Set the selected language
    });
  }

  // Method to speak the given text using TTS
  Future<void> _speak(String text, String languageCode) async {
    await flutterTts.setLanguage(languageCode); // Set the TTS language
    await flutterTts.speak(text); // Speak the given text
  }

  // Method to save the current state to shared preferences
  Future<void> _saveState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); // Access shared preferences
    await prefs.setInt('${selectedLanguage}_currentIndex', currentIndex); // Save the current index
    await prefs.setStringList('${selectedLanguage}_flashcards', flashcards.map((card) => jsonEncode(card)).toList()); // Save the flashcards
    _cache['${selectedLanguage}_currentIndex'] = currentIndex; // Update cache with the current index
    _cache['${selectedLanguage}_flashcards'] = flashcards; // Update cache with the flashcards
  }

  // Method to load the saved state from shared preferences
  Future<void> _loadState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); // Access shared preferences
    int savedIndex = _cache['${selectedLanguage}_currentIndex'] ?? prefs.getInt('${selectedLanguage}_currentIndex') ?? 0; // Get the saved index
    List<String>? savedFlashcards = _cache['${selectedLanguage}_flashcards'] ?? prefs.getStringList('${selectedLanguage}_flashcards'); // Get the saved flashcards
    if (savedFlashcards != null) {
      flashcards = savedFlashcards.map((card) {
        Map<String, dynamic> decodedCard = jsonDecode(card); // Decode the saved flashcards
        return decodedCard.map((key, value) => MapEntry(key, value.toString())); // Ensure all values are strings
      }).toList();
    }
    setState(() {
      currentIndex = savedIndex; // Set the current index
      flashcards = flashcards.sublist(currentIndex); // Update the flashcards list to start from the saved index
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the current language from the provider
    String? currentLanguage = Provider.of<LanguageChanger>(context).currentLanguage['language'];
    if (currentLanguage == null) {
      return const Center(child: CircularProgressIndicator()); // Show a loading indicator if the language is not available
    }

    return CardSwiper(
      cards: flashcards.map((flashcard) {
        // Build each flashcard with flipping functionality
        return buildFlipCard(flashcard, selectedLanguage.toLowerCase(), currentLanguage.toLowerCase());
      }).toList(),
      onSwipe: (index, direction) {
        setState(() => swipeDirection = direction); // Update the swipe direction
        handleSwipe(index, direction, currentLanguage.toLowerCase(), selectedLanguage.toLowerCase()); // Handle swipe action
        if (Provider.of<OverlayChanger>(context, listen: false).isOverlayOn) {
          showOverlay(); // Show overlay if enabled
        }
        if (Provider.of<OverlayChanger>(context, listen: false).isVibrationOn) {
          handleVibration(); // Handle vibration if enabled
        }
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() => swipeDirection = null); // Reset swipe direction after delay
          }
        });
      },
    );
  }

  // Method to handle swipe actions on the flashcards
  void handleSwipe(int index, CardSwiperDirection direction, String currentLanguage, String selectedLanguage) async {
    final card = Map<String, String>.from(flashcards[index]); // Create a copy of the card
    switch (direction) {
      case CardSwiperDirection.top:
      case CardSwiperDirection.bottom:
        Provider.of<StatisticsData>(context, listen: false).markCardAsLearned(card['number']!, selectedLanguage.toLowerCase()); // Mark card as learned
        flashcards.add(card); // Add card to the end of the list
        break;
      case CardSwiperDirection.right:
        flashcards.insert(index + 500 < flashcards.length ? index + 500 : flashcards.length, card); // Insert card further in the list
        break;
      case CardSwiperDirection.left:
        flashcards.insert(index + 10 < flashcards.length ? index + 10 : flashcards.length, card); // Insert card closer in the list
        break;
      default:
        break;
    }
    setState(() {
      flashcards = List.from(flashcards); // Update flashcards list
    });
    currentIndex = index + 1; // Update the current index
    await _saveState(); // Save the state after handling swipe
  }

  // Method to build a flip card widget for each flashcard
  Widget buildFlipCard(Map<String, String> flashcard, String selectedLanguage, String currentLanguage) {
    String? selectedLanguageText = flashcard[selectedLanguage.toLowerCase()]; // Get the text for the selected language
    String? currentLanguageText = flashcard[currentLanguage.toLowerCase()]; // Get the text for the current language

    if (selectedLanguageText == null || currentLanguageText == null) {
      return Container(); // Return an empty container if either text is null
    }

    bool isCardFaceFlipped = Provider.of<StatisticsData>(context).isCardFaceFlipped; // Get card face flip status from provider
    String key = '${flashcard['number']}_$selectedLanguage'; // Generate a unique key for the flip card

    return FlipCard(
      key: ValueKey(key),
      direction: FlipDirection.HORIZONTAL,
      speed: 200,
      front: buildCardSide(isCardFaceFlipped ? currentLanguageText : selectedLanguageText, isCardFaceFlipped ? currentLanguage : selectedLanguage), // Front side of the card
      back: buildCardSide(isCardFaceFlipped ? selectedLanguageText : currentLanguageText, isCardFaceFlipped ? selectedLanguage : currentLanguage), // Back side of the card
    );
  }

  // Method to build each side of a flip card
  Widget buildCardSide(String text, String language) {
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark; // Determine if the current theme is dark
    Color iconColor = isDarkTheme ? Colors.white : Colors.black; // Set icon color based on theme
    String? languageCode = languageToTtsCode[language.toLowerCase()]; // Get TTS code for the language

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                  fontFamily: 'OpenSans',
                  fontSize: 120.0,
                ),
              ),
            ),
          ),
        ),
        if (languageCode != null && availableLanguages.contains(languageCode))
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: IconButton(
                icon: Icon(Icons.volume_up, size: 100, color: iconColor),
                onPressed: () => _speak(text, languageCode), // Speak the text when icon is pressed
              ),
            ),
          ),
      ],
    );
  }

  // Method to show an overlay with animation
  void showOverlay() {
    isAnimating = true; // Set animating flag

    String overlayText = getOverlayText(); // Get text for overlay
    Color overlayColor = getOverlayColor(); // Get color for overlay
    IconData iconData;
    Alignment beginAlignment;
    Alignment endAlignment;

    // Set icon and alignment based on swipe direction
    switch (swipeDirection) {
      case CardSwiperDirection.right:
        iconData = Icons.thumb_up;
        beginAlignment = Alignment.centerRight;
        endAlignment = Alignment.centerLeft;
        break;
      case CardSwiperDirection.left:
        iconData = Icons.thumb_down;
        beginAlignment = Alignment.centerLeft;
        endAlignment = Alignment.centerRight;
        break;
      case CardSwiperDirection.top:
        iconData = Icons.whatshot;
        beginAlignment = Alignment.topCenter;
        endAlignment = Alignment.bottomCenter;
        break;
      case CardSwiperDirection.bottom:
        iconData = Icons.whatshot;
        beginAlignment = Alignment.bottomCenter;
        endAlignment = Alignment.topCenter;
        break;
      default:
        iconData = Icons.whatshot;
        beginAlignment = Alignment.center;
        endAlignment = Alignment.center;
        break;
    }

    // Initialize animation controller for the overlay
    final overlayAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animationControllers.add(overlayAnimationController);

    // Create animation for fade transition
    final animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(overlayAnimationController);

    // Create overlay entry for the overlay
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: overlayAnimationController,
        builder: (context, child) => Stack(
          children: [
            IgnorePointer(
              ignoring: true,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: FadeTransition(
                      opacity: animation,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: beginAlignment,
                            end: endAlignment,
                            colors: [overlayColor, overlayColor.withOpacity(0.5), overlayColor.withOpacity(0)],
                            stops: const [0.0, 0.07, 0.1],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height / 4,
                    left: 0,
                    right: 0,
                    child: Material(
                      color: Colors.transparent,
                      child: FadeTransition(
                        opacity: animation,
                        child: buildOverlayContent(context, overlayText, overlayColor, iconData),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    overlayEntries.add(overlayEntry); // Add overlay entry to the list
    Overlay.of(context).insert(overlayEntry); // Insert overlay into the overlay stack

    // Start the overlay animation and remove it after a delay
    overlayAnimationController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 200)).then((_) {
        if (mounted) {
          overlayAnimationController.reverse().then((_) {
            overlayEntry.remove();
            overlayEntries.remove(overlayEntry);
            isAnimating = false; // Reset animating flag
          });
        }
      });
    });
  }

  // Method to build the content of the overlay
  Widget buildOverlayContent(BuildContext context, String overlayText, Color overlayColor, IconData iconData) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        buildIconStack(context, overlayColor, iconData), // Build stack with icon
        buildTextStack(context, overlayText, overlayColor), // Build stack with text
      ],
    );
  }

  // Method to build the icon stack for the overlay
  Stack buildIconStack(BuildContext context, Color overlayColor, IconData iconData) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Icon(
          iconData,
          size: 90,
          color: overlayColor,
        ),
        CustomPaint(
          size: const Size(90, 90),
          painter: IconOutlinePainter(
            iconData: iconData,
            size: 90,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

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

    return openSansLanguages.contains(Provider.of<LanguageChanger>(context, listen: false).currentLanguage['language']);
  }

  // Method to build the text stack for the overlay
  Stack buildTextStack(BuildContext context, String overlayText, Color overlayColor) {
    Paint textOutlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;

    bool useOpenSans = checkFontOpenSans(context);

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Text(
          overlayText,
          style: TextStyle(
            fontSize: 90,
            fontFamily: useOpenSans ? 'OpenSansCondensed' : 'Kapra',
            color: overlayColor,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          overlayText,
          style: TextStyle(
            fontSize: 90,
            fontFamily: useOpenSans ? 'OpenSansCondensed' : 'Kapra',
            foreground: textOutlinePaint,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }


  // Method to get the color for the overlay based on swipe direction
  Color getOverlayColor() {
    switch (swipeDirection) {
      case CardSwiperDirection.left:
        return Colors.red;
      case CardSwiperDirection.right:
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  // Method to get the text for the overlay based on swipe direction
  String getOverlayText() {
    switch (swipeDirection) {
      case CardSwiperDirection.left:
        return needsWorkWord[Provider.of<LanguageChanger>(context, listen: false).currentLanguage['language']] ?? 'NEEDS WORK';
      case CardSwiperDirection.right:
        return wellDoneWord[Provider.of<LanguageChanger>(context, listen: false).currentLanguage['language']] ?? 'WELL DONE';
      default:
        return tooEasyWord[Provider.of<LanguageChanger>(context, listen: false).currentLanguage['language']] ?? 'TOO EASY';
    }
  }

  // Method to handle vibration feedback based on swipe direction
  void handleVibration() {
    switch (swipeDirection) {
      case CardSwiperDirection.left:
        HapticFeedback.lightImpact();
        break;
      case CardSwiperDirection.right:
        HapticFeedback.lightImpact();
        break;
      default:
        HapticFeedback.mediumImpact();
        break;
    }
  }
}

// Custom painter class to draw icon outlines
class IconOutlinePainter extends CustomPainter {
  final IconData iconData;
  final double size;
  final Color color;

  IconOutlinePainter({required this.iconData, required this.size, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: this.size,
        fontFamily: iconData.fontFamily,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = color,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset.zero);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
