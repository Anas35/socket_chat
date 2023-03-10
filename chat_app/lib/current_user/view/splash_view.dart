import 'package:chat_app/authentication/authentication.dart';
import 'package:chat_app/current_user/cubit/current_user_cubit.dart';
import 'package:chat_app/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:models/models.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CurrentUserCubit, User?>(
      listener: (context, state) {
        if (state == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => AuthenticationCubit(),
                child: const LogView(),
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeView(),
            ),
          );
        }
      },
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
