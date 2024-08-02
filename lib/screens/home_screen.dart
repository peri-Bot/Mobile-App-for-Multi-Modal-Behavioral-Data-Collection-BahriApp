import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.8,
          heightFactor: 0.8,
          child: Column(
            children: [
              const Divider(color: Colors.transparent),
              const Divider(color: Colors.transparent),
              const Divider(color: Colors.transparent),
              Container(
                height: 75,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(color: Colors.grey, offset: Offset(4.0, 4.0))
                    ]),
                child: SizedBox.expand(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                      padding: EdgeInsets.zero, // Remove any default padding
                    ),
                    child: const Text(
                      'Progress',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "assets/fonts/Poppins.ttf",
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(color: Colors.transparent),
              const Divider(color: Colors.transparent),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(color: Colors.grey, offset: Offset(4.0, 4.0))
                  ],
                ),
                child: SizedBox.expand(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                      padding: EdgeInsets.zero, // Remove any default padding
                    ),
                    child: const Text(
                      'Play Game',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "assets/fonts/Poppins.ttf",
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
