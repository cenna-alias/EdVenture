import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_edventure/screen/login.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://zocmpjizmgscrhudkozy.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvY21waml6bWdzY3JodWRrb3p5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYzOTk1NzcsImV4cCI6MjA1MTk3NTU3N30.PlwRSf4PIU2DjbnlkzqQqiZ1SfWo5fxCaKCOdT8biqo',
  );
  runApp(MainApp());
}

final supabase = Supabase.instance.client;

// Intro Screen with PageView
class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  final int _totalPages = 3; // Number of intro pages

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                buildPage(
                  imagePath: 'assets/wow.avif',
                  title: 'Welcome to Edventure',
                  subtitle: 'Discover a world of learning !',
                ),
                buildPage(
                  imagePath: 'assets/cube.avif',
                  title: 'Learn Anytime',
                  subtitle: 'Explore learning at your pace !',
                ),
                buildPage(
                  imagePath: 'assets/lap.avif',
                  title: 'Start Your Journey',
                  subtitle: 'Get ready to grow with us !',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color:
                          Theme.of(context).textTheme.labelLarge?.color ??
                          Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ),
                Row(
                  children: List.generate(_totalPages, (index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      width: 8.0,
                      height: 8.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _currentPage == index
                                ? Theme.of(context).primaryColor
                                : Colors.grey[600],
                      ),
                    );
                  }),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _totalPages - 1) {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.pushNamed(context, '/login');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    _currentPage < _totalPages - 1 ? 'Next' : 'Get Started',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPage({
    required String imagePath,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Image.asset(
              imagePath,
              width: MediaQuery.of(context).size.width * 0.7,
              height: 350,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 350,
                  color: Colors.grey[800],
                  child: Center(
                    child: Text(
                      'Image not found',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 40), // Increased from 20 to 40 for more spacing
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12), // Slightly increased from 10 to 12
          Text(
            subtitle,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onBackground.withOpacity(0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/intro',
      theme: ThemeData(
        // Adjusted Theme for Intro Page
        primarySwatch: Colors.deepPurple,
        primaryColor: Colors.deepPurple[600], // Slightly lighter deep purple
        scaffoldBackgroundColor: Colors.grey[900], // Softer black
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple,
          brightness: Brightness.dark,
        ).copyWith(
          secondary: Colors.deepPurple[200], // Softer purple accent
          onPrimary: Colors.white,
          onBackground: Colors.white,
          onSurface: Colors.white70,
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.white70),
          labelLarge: TextStyle(
            fontSize: 16.0,
            color: Colors.grey[300],
          ), // Brighter grey for "Skip"
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple[600], // Matching primary color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        ),
      ),
      routes: {
        '/intro': (context) => IntroScreen(),
        '/login': (context) => Login(),
      },
    );
  }
}
