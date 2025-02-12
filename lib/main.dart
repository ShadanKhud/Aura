import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'splash_screen.dart'; // Import the SplashScreen class
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// ...

void main()  async{
  WidgetsFlutterBinding.ensureInitialized(); 
  String secret ="sk_test_51Qrl4ARth5SQH9HL6u9t5ryvllJyPSpGVtTFt3xY4US1tki0kIvdCiRnkSO3BHGWIMI6I4zImWk5nsndcreUrfJz004vj2yoQM";
  Stripe.publishableKey = 'pk_test_51Qrl4ARth5SQH9HLDR1AfGs1AJbSm2HyO70GilrQQDtmxtExVCr9CDamudrwhBsq23TkP6bHSwqFlyLMyqxnrcIj001ofWobik';
  await Stripe.instance.applySettings();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the "Debug" banner
      home: SplashScreen(), // Call the SplashScreen class here
    );
  }
}
