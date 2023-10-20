import 'package:credible/app/shared/ui/base/palette.dart';
import 'package:flutter/material.dart';

class CrediblePalette extends UiPalette {
  const CrediblePalette();

  // static const blue = Color(0xff3A83A3);
  static const blue = Color.fromRGBO(0, 0, 68, 1.0);
  static const lightBlue = Color.fromRGBO(57, 45, 117, 1.0);
  static const orange = Color.fromRGBO(255, 125, 0, 1.0);
  static const light = Color.fromRGBO(247, 235, 255, 1.0);
  static const lightGreen = Color.fromRGBO(0, 200, 160, 1.0);
  //---------------
  static const text = Color(0xff324854);

  static const lightGrey = Color(0xffF6F7FA);
  static const greyPurple = Color(0xffE8E8F4);

  static const gradientBlue = Color(0xff2C6681);

  static const lighterGreen = Color(0xffA9D564);
  // static const lightGreen = Color(0xff76B562);

  static const green = Color(0xff5B9C54);
  static const darkGreen = Color(0xff438E73);
  static const darkerGreen = Color(0xff324854);

  static const gradientDarkGreen = Color(0xffC7DF6A);
  static const gradientLightGreen = Color(0xff84C95F);

  static const greenGrey = Color(0xff27496E);

  @override
  Color get primary => blue;

  @override
  Color get accent => blue;

  @override
  Color get background => Color(0xffF6F7F8);

  @override
  Gradient get pageBackground => LinearGradient(
        colors: [lightGrey, lightGrey],
      );

  @override
  Gradient get splashBackground => LinearGradient(
        colors: [blue, gradientBlue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  @override
  Gradient get buttonBackground => LinearGradient(
        colors: [blue, blue],
      );

  @override
  Color get shadow => Color(0x0d000000);

  @override
  Color get credentialText => lightGrey;

  @override
  // Color get credentialBackground => darkGreen;
  Color get credentialBackground => lightBlue;

  @override
  // Color get credentialDetail => gradientLightGreen;
  Color get credentialDetail => light;

  @override
  Color get icon => text;

  @override
  Color get lightBorder => greyPurple;

  @override
  Color get appBarBackground => Colors.white;

  @override
  Color get navBarBackground => Colors.white;

  @override
  Color get navBarIcon => blue;

  @override
  Color get wordBorder => text;

  @override
  Color get textFieldBackground => Colors.white;

  @override
  Color get textFieldBorder => greyPurple;

  @override
  Color get lineChain => lightGrey;
}
