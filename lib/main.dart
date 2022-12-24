import 'package:text_app/app.dart';
import 'package:text_app/screens/screens.dart';
import 'package:text_app/screens/select_user_screen.dart';
import 'package:text_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'package:text_app/screens/select_user_screen.dart';
import 'package:text_app/theme.dart';

void main() {
  final client = StreamChatClient(streamKey);

  runApp(
    MyApp(
      client: client,
      appTheme : AppTheme(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    required this.client, required this.appTheme
  }) : super(key: key);

  final StreamChatClient client;
 final AppTheme appTheme;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme.light,
      darkTheme: appTheme.dark,
      themeMode: ThemeMode.dark,
      title: 'Chatter',
      builder: (context, child) {
        return StreamChatCore(
          client: client,
          child: ChannelsBloc(
            child: UsersBloc(
              child: child!,
            ),
          ),
        );
      },
      home: const SelectUserScreen(),
    );
  }
}