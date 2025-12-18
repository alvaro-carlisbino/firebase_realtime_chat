import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/conversation_viewmodel.dart';
import '../models/user_model.dart';
import 'auth_view.dart';
import 'chats_list_view.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return StreamBuilder<User?>(
      stream: authViewModel.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;
          final userModel = UserModel.fromFirebaseUser(user);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            context
                .read<ConversationViewModel>()
                .updateUserPresence(userModel);
          });

          return const ChatsListView();
        }

        return const AuthView();
      },
    );
  }
}
