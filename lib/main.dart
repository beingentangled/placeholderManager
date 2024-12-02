import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:okto_flutter_sdk/okto_flutter_sdk.dart';
import 'package:placeholder/auth/google_login.dart';
import 'package:placeholder/screens/home_page.dart';
import 'package:placeholder/screens/raw_txn/raw_transaction_execute_page.dart';
import 'package:placeholder/utils/okto.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  okto = Okto(globals.getOktoApiKey(), globals.getBuildType());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkLoginStatus() async {
    FlutterNativeSplash.remove();
    return await okto!.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Placeholder Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: FutureBuilder<bool>(
        future: checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            // Show login or home page based on login status
            bool isLoggedIn = snapshot.data ?? false;
            if (isLoggedIn) {
              return const RawTransactioneExecutePage();
            } else {
              return const LoginWithGoogle();
            }
          }
        },
      ),
    );
  }
}
