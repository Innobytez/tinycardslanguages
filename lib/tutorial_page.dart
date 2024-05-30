import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tinycards/constants.dart';
import 'package:tinycards/language_changer.dart';
import 'package:tinycards/overlay_changer.dart';
import 'package:tinycards/home_page.dart';

class TutorialScreen extends StatelessWidget {

  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: Padding(
        padding: const EdgeInsets.only(top: 30.0, bottom: 0.0), // adjust this value as needed
        child: Stack(
          children: <Widget>[
            buildBackButton(context),
            buildHelpContainer(context),
          ],
        ),
      ),
    );
  }

  // Builds the back button with vibration feedback and animation to the specified page index
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
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => HomeScreen()),
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

  // Builds the back text with dynamic font and styling based on the current language
  SizedBox buildBackText(BuildContext context) {
    bool isFontOpenSans = checkFontOpenSans(context);

    return SizedBox(
      height: 90, // Set a fixed height for the container
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: isFontOpenSans ? const EdgeInsets.only(bottom: 12.0) : const EdgeInsets.all(0), // Add padding here
          child: Text(
            homeWord[Provider.of<LanguageChanger>(context).currentLanguage['language']] ?? 'BACK',
            style: TextStyle(
              fontSize: 70, // base font size
              fontFamily: isFontOpenSans ? 'OpenSansCondensed' : 'Kapra',
              color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // Builds the help container with instructional phrases and images
  Positioned buildHelpContainer(BuildContext context) {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      bottom: 85, // adjust as needed
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0), // add padding here
          child: Stack(
            children: <Widget>[
              buildTapCardPhrase(context),
              buildSwipeEasyPhrase(context),
              buildSwipeIncorrectPhrase(context),
              buildSwipeCorrectPhrase(context),
            ],
          ),
        ),
      ),
    );
  }

  // Checks if the current language requires the OpenSansCondensed font
  bool checkFontOpenSans(BuildContext context) {
    List<String> openSansLanguages = [
      'Greek', 'Russian', 'Mandarin', 'Hebrew', 'Hindi', 'Bengali', 'Japanese', 'Korean', 'Arabic',
      'Thai', 'Tamil', 'Telugu', 'Kannada', 'Malayalam', 'Sinhala', 'Amharic', 'Georgian', 'Khmer',
      'Lao', 'Myanmar (Burmese)', 'Yiddish', 'Gujarati', 'Urdu', 'Pashto', 'Farsi', 'Ukrainian',
      'Cyrillic', 'Afrikaans', 'Albanian', 'Armenian', 'Azerbaijani', 'Basque', 'Belarusian', 'Bosnian',
      'Bulgarian', 'Catalan', 'Cebuano', 'Chichewa', 'Corsican', 'Croatian', 'Czech', 'Danish', 'Dutch',
      'Esperanto', 'Estonian', 'Filipino', 'Finnish', 'Frisian', 'Galician', 'Haitian Creole', 'Hausa',
      'Hawaiian', 'Hmong', 'Hungarian', 'Icelandic', 'Igbo', 'Indonesian', 'Irish', 'Javanese', 'Kazakh',
      'Kurdish (Kurmanji)', 'Kyrgyz', 'Latin', 'Latvian', 'Lithuanian', 'Luxembourgish', 'Macedonian',
      'Malagasy', 'Malay', 'Maori', 'Marathi', 'Mongolian', 'Nepali', 'Norwegian', 'Polish', 'Portuguese',
      'Punjabi', 'Romanian', 'Samoan', 'Scots Gaelic', 'Serbian', 'Sesotho', 'Shona', 'Sindhi', 'Slovak',
      'Slovenian', 'Somali', 'Sundanese', 'Swahili', 'Swedish', 'Tajik', 'Uzbek', 'Vietnamese', 'Welsh',
      'Xhosa', 'Yoruba', 'Zulu'
    ];

    return openSansLanguages.contains(Provider.of<LanguageChanger>(context).currentLanguage['language']);
  }

  // Builds the phrase and image indicating to tap on a card
  Positioned buildTapCardPhrase(BuildContext context) {
    bool isFontOpenSans = checkFontOpenSans(context);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            tapCardPhrase[Provider.of<LanguageChanger>(context).currentLanguage['language']] ?? 'Tap on a card to view translation',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: isFontOpenSans ? 'OpenSansCondensed' : 'Kapra',
            ),
          ),
          buildImage(context, 'assets/images/hand.png', -90),
        ],
      ),
    );
  }

  // Builds the phrase and images indicating to swipe up or down if very easy
  Positioned buildSwipeEasyPhrase(BuildContext context) {
    bool isFontOpenSans = checkFontOpenSans(context);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              buildImage(context, 'assets/images/arrow.png', -90),
              buildImage(context, 'assets/images/arrow.png', 90),
            ],
          ),
          Text(
            swipeEasyPhrase[Provider.of<LanguageChanger>(context).currentLanguage['language']] ?? 'Swipe up or down if very easy',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: isFontOpenSans ? 'OpenSansCondensed' : 'Kapra',
            ),
          ),
        ],
      ),
    );
  }

  // Builds the phrase and image indicating to swipe left if incorrect
  Positioned buildSwipeIncorrectPhrase(BuildContext context) {
    bool isFontOpenSans = checkFontOpenSans(context);

    return Positioned(
      top: MediaQuery.of(context).size.height / 3 - 60,
      left: 0,
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 80, // subtracting the left and right padding
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            buildImage(context, 'assets/images/arrow.png', 180),
            const SizedBox(width: 15), // space between icon and text
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  swipeIncorrectPhrase[Provider.of<LanguageChanger>(context).currentLanguage['language']] ?? 'Swipe left if incorrect',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: isFontOpenSans ? 'OpenSansCondensed' : 'Kapra',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds the phrase and image indicating to swipe right if correct
  Positioned buildSwipeCorrectPhrase(BuildContext context) {
    bool isFontOpenSans = checkFontOpenSans(context);

    return Positioned(
      top: MediaQuery.of(context).size.height / 2 - 60,
      right: 0,
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 80, // subtracting the left and right padding
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0), // add more padding to the left side of the text
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    swipeCorrectPhrase[Provider.of<LanguageChanger>(context).currentLanguage['language']] ?? 'Swipe right if correct',
                    textAlign: TextAlign.center, // make the text centered within itself
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: isFontOpenSans ? 'OpenSansCondensed' : 'Kapra',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20), // control the space between the text and the image
            buildImage(context, 'assets/images/arrow.png', 0),
          ],
        ),
      ),
    );
  }

  // Builds and rotates an image with color filtering based on theme brightness
  Transform buildImage(BuildContext context, String path, double rotation) {
    return Transform.rotate(
      angle: rotation * pi / 180,
      child: ColorFiltered(
        colorFilter: Theme.of(context).brightness == Brightness.dark
            ? const ColorFilter.matrix([
                -1, 0, 0, 0, 255,
                0, -1, 0, 0, 255,
                0, 0, -1, 0, 255,
                0, 0, 0, 1, 0,
              ])
            : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
        child: Image.asset(path, width: 96, height: 96),
      ),
    );
  }
}
