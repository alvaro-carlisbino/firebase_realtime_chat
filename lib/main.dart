import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'config/app_theme.dart';
import 'services/auth_service.dart';
import 'services/chat_service.dart';
import 'services/conversation_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/chat_viewmodel.dart';
import 'viewmodels/conversation_viewmodel.dart';
import 'views/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      debugPrint('Firebase already initialized');
    } else {
      rethrow;
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<ChatService>(
          create: (_) => ChatService(),
        ),
        Provider<ConversationService>(
          create: (_) => ConversationService(),
        ),
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(
            context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider<ChatViewModel>(
          create: (context) => ChatViewModel(
            context.read<ChatService>(),
            context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider<ConversationViewModel>(
          create: (context) => ConversationViewModel(
            context.read<ConversationService>(),
            context.read<AuthService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Chat',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
      ),
    );
  }
}
