import 'package:flutter/material.dart';

class Responsive {
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;

  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  static void init(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    screenWidth = mediaQueryData.size.width;
    screenHeight = mediaQueryData.size.height;

    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal = mediaQueryData.padding.left + mediaQueryData.padding.right;
    _safeAreaVertical = mediaQueryData.padding.top + mediaQueryData.padding.bottom;

    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
  }

  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 850;
  
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 850;

  // Scales a size proportionally based on screen width.
  // Assumes a base design width of 390.0 (iPhone 12/13/14).
  static double getProportionateScreenWidth(double inputWidth, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // On desktop, don't scale indefinitely; treat 600 as the max scaling threshold for widgets
    if (screenWidth > 600) screenWidth = 600;
    return (inputWidth / 390.0) * screenWidth;
  }

  // Scales a size proportionally based on screen height.
  // Assumes a base design height of 844.0 (iPhone 12/13/14).
  static double getProportionateScreenHeight(double inputHeight, BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return (inputHeight / 844.0) * screenHeight;
  }
}

