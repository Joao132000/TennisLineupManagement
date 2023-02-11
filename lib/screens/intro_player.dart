import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroPlayer extends StatefulWidget {
  @override
  State<IntroPlayer> createState() => _IntroPlayerState();
}

class _IntroPlayerState extends State<IntroPlayer> {
  // 1. Define a `GlobalKey` as part of the parent widget's state

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      // 2. Pass that key to the `IntroductionScreen` `key` param
      pages: [
        PageViewModel(
          title: 'Page One',
          bodyWidget: Column(
            children: [
              ElevatedButton(onPressed: () {}, child: const Text('Start'))
            ],
          ),
        ),
        PageViewModel(
          title: "Title of custom button page",
          body: "This is a description on a page with a custom button below.",
        ),
        PageViewModel(
          title: 'Page Two',
          bodyWidget: Column(
            children: [
              ElevatedButton(
                  onPressed: () {
                    // 3. Use the `currentState` member to access functions defined in `IntroductionScreenState`
                    Navigator.pop(context);
                  },
                  child: const Text('Close'))
            ],
          ),
        ),
      ],
      showSkipButton: true,
      skip: const Text("Skip"),
      next: const Text("Next"),
      done: const Text("Done"),
      onDone: () {
        Navigator.pop(context);
      },
      baseBtnStyle: TextButton.styleFrom(
        backgroundColor: Colors.black12,
        minimumSize: Size(40, 40),
      ),
      skipStyle: TextButton.styleFrom(
        foregroundColor: Colors.red,
      ),
      doneStyle: TextButton.styleFrom(
        foregroundColor: Colors.green,
      ),
      nextStyle: TextButton.styleFrom(
        foregroundColor: Colors.blue,
      ),
    );
  }
}
