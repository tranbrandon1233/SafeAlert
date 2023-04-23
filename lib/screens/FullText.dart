import 'package:flutter/material.dart';

class FullText extends StatelessWidget {
  final String info;
  const FullText({Key? key, required this.info}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: const Text("Emergency Alert!"),
        ),
        body:
          Container(
              margin: EdgeInsets.all(30),

              child: Center(
                child: Text(
                    info,
                    textScaleFactor: 3,
                )
            )
          )
    );
  }

}