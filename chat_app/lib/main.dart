import 'package:chat_app/chat_room/cubit/chat_room_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'current_user/current_user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => CurrentUserRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<CurrentUserCubit>(
            create: (context) => CurrentUserCubit(
              currentUserRepository: RepositoryProvider.of<CurrentUserRepository>(context),
            )..init(),
          ),
          BlocProvider<ChatRoomCubit>(create: (context) => ChatRoomCubit()),
        ],
        child: MaterialApp(
          title: 'Socket Chat',
          theme: ThemeData.dark(),
          home: const SplashView(),
        ),
      ),
    );
  }
}
