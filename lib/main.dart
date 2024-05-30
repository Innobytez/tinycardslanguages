import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_changer.dart';
import 'overlay_changer.dart';
import 'home_page.dart';
import 'language_changer.dart';
import 'statistics_changer.dart';
import 'startupsound_changer.dart';
import 'tutorial_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set the preferred screen orientation to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Check whether the app has been opened before
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('first_time') ?? true;

  runApp(MyApp(isFirstTime: isFirstTime));

  // Handle back navigation
  SystemChannels.navigation.setMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'popRoute') {
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
      return Future.value(false);
    }
    return Future.value(true);
  });
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;

  const MyApp({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeChanger>(create: (_) => ThemeChanger()),
        ChangeNotifierProvider(create: (_) => OverlayChanger()),
        ChangeNotifierProvider(create: (_) => LanguageChanger()),
        ChangeNotifierProvider(create: (_) => StatisticsData()),
        ChangeNotifierProvider(create: (_) => StartupSoundChanger()),
      ],
      child: Consumer<ThemeChanger>(
        builder: (context, ThemeChanger themeChanger, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            theme: themeChanger.getTheme(),
            home: LoadingScreen(isFirstTime: isFirstTime, key: Key('LoadingScreen')),
            debugShowCheckedModeBanner: false,  // Added this line to remove the debug banner
          );
        },
      ),
    );
  }
}


class LoadingScreen extends StatefulWidget {
  final bool isFirstTime;

  const LoadingScreen({required Key key, required this.isFirstTime}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  // Initialize the video player and handle the startup sound preference
  Future<void> _initializeVideoPlayer() async {
    // Load the startup sound preference
    await Provider.of<StartupSoundChanger>(context, listen: false).loadStartupSoundPreference();
    bool soundIsOn = Provider.of<StartupSoundChanger>(context, listen: false).isStartupSoundOn;
    
    // Choose the appropriate video based on the sound preference
    _controller = VideoPlayerController.asset(
      soundIsOn 
        ? 'assets/videos/Innobytez_Mobile_App_Splashscreen_Sound.mp4' 
        : 'assets/videos/Innobytez_Mobile_App_Splashscreen.mp4'
    )
    ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized
        setState(() {
          _isInitialized = true;
        });
      });
    
    _controller.play();
    _controller.setLooping(true);

    // Wait for 5 seconds before navigating to the next screen
    await Future.delayed(const Duration(seconds: 5));
    
    // Navigate to the next screen based on whether it's the first time the app is opened
    if (widget.isFirstTime) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => TutorialScreen()),
      );
      // Update the preference to indicate that the app has been opened
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('first_time', false);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isInitialized
          ? Stack(
              children: <Widget>[
                Positioned.fill(
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
