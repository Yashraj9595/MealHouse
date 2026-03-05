import 'package:MealHouse/core/app_export.dart';

// Minimal debug version to test if the page loads
class UserHomePageDebug extends StatefulWidget {
  const UserHomePageDebug({super.key});

  @override
  State<UserHomePageDebug> createState() => _UserHomePageDebugState();
}

class _UserHomePageDebugState extends State<UserHomePageDebug> {
  @override
  void initState() {
    super.initState();
    print('✅ UserHomePage initialized successfully');
  }

  @override
  Widget build(BuildContext context) {
    print('✅ UserHomePage building...');
    return Scaffold(
      appBar: AppBar(
        title: Text('User Home - Debug'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text(
              'User Home Page Loaded Successfully!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print('Button pressed - navigation works!');
              },
              child: Text('Test Button'),
            ),
          ],
        ),
      ),
    );
  }
}
