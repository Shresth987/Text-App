import 'package:flutter/cupertino.dart';

class DisplayErrorMessage extends StatelessWidget {
  const DisplayErrorMessage({Key? key,required this.error}) : super(key: key);

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'oh no something went wrong'
            'Please check your config. $error',
      ),
    );
  }
}
