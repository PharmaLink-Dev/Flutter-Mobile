import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/**
 * HeaderSection Widget
 * ---------------------
 * This widget is the top section of the HomePage.
 * It displays a greeting message, user information, and a circular avatar.
 */
class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key}); // const: ensures immutability, better performance

  @override
  Widget build(BuildContext context) {
    return Row( // Row: places children horizontally
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // push items left & right
      children: [
        Column( // Column: places text vertically
          crossAxisAlignment: CrossAxisAlignment.start, // align to left
          children: const [
            Text(
              "Hello, Mr. Somchai!", // greeting message
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              "Age 65 • Stay healthy today!", // sub message
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const CircleAvatar( // CircleAvatar: circular profile icon
          radius: 24,
          backgroundColor: Colors.blue,
          child: FaIcon(FontAwesomeIcons.user, color: Colors.white, size: 22),
        ),
      ],
    );
  }
}
