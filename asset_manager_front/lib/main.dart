import 'package:asset_manager_front/pages/asset_list_screen.dart';
import 'package:asset_manager_front/pages/login_screen.dart';
import 'package:asset_manager_front/services/api_service.dart';
import 'package:asset_manager_front/models/user.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiService = ApiService();
  runApp(MyApp(apiService: apiService));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;

  const MyApp({required this.apiService, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asset Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/check-auth',
      routes: {
        '/check-auth': (context) => CheckAuthScreen(apiService: apiService),
        '/login': (context) => LoginScreen(apiService: apiService),
        '/assets': (context) => AssetListScreen(apiService: apiService),
      },
    );
  }
}

class CheckAuthScreen extends StatelessWidget {
  final ApiService apiService;

  const CheckAuthScreen({required this.apiService, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: User.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final token = snapshot.data;
        if (token != null && !JwtDecoder.isExpired(token)) {
          // Token exists and is not expired, navigate to AssetListScreen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/assets');
          });
        } else {
          // No token or token expired, navigate to LoginScreen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
        }

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}