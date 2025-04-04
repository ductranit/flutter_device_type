library flutter_device_type;

import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as Math;

import 'package:flutter/widgets.dart';

class Device {
  static double get devicePixelRatio =>
      WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
  static ui.Size get size =>
      WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;
  static double get width => size.width;
  static double get height => size.height;
  static double get screenWidth => width / devicePixelRatio;
  static double get screenHeight => height / devicePixelRatio;
  static ui.Size get screenSize => ui.Size(screenWidth, screenHeight);

  final bool isTablet, isPhone, isIos, isAndroid, isIphoneX, hasNotch;
  static Device? _device;
  static bool _isMetricsHandlerSet = false;

  Device({
    required this.isTablet,
    required this.isPhone,
    required this.isIos,
    required this.isAndroid,
    required this.isIphoneX,
    required this.hasNotch,
  });

  // Static method to initialize the metrics change handler
  static void _initializeMetricsHandler() {
    if (!_isMetricsHandlerSet) {
      WidgetsBinding.instance.platformDispatcher.onMetricsChanged = () {
        _device = null; // Invalidate cache on metrics change
      };
      _isMetricsHandlerSet = true;
    }
  }

  factory Device.get() {
    // Set up the metrics handler before computing device properties
    _initializeMetricsHandler();

    if (_device != null) return _device!;

    bool isTablet;
    bool isPhone;
    bool isIos = Platform.isIOS;
    bool isAndroid = Platform.isAndroid;
    bool isIphoneX = false;
    bool hasNotch = false;

    if (devicePixelRatio < 2 && (width >= 1000 || height >= 1000)) {
      isTablet = true;
      isPhone = false;
    } else if (isAndroid &&
        devicePixelRatio >= 2 &&
        (width >= 2400 || height >= 2400)) {
      // Adjusted for Android only
      isTablet = true;
      isPhone = false;
    } else if (!isAndroid &&
        devicePixelRatio == 2 &&
        (width >= 1920 || height >= 1920)) {
      // Original for non-Android
      isTablet = true;
      isPhone = false;
    } else {
      isTablet = false;
      isPhone = true;
    }

    // Recalculate for Android Tablet using device inches (adjusted for Android only)
    if (isAndroid) {
      final adjustedWidth = _calWidth() / devicePixelRatio;
      final adjustedHeight = _calHeight() / devicePixelRatio;
      final diagonalSizeInches = (Math.sqrt(
              Math.pow(adjustedWidth, 2) + Math.pow(adjustedHeight, 2))) /
          _ppi;
      // print(
      //     "Device DPR: $devicePixelRatio, Diagonal size: $diagonalSizeInches inches"); // Debug output

      if (diagonalSizeInches >= 7.5) {
        isTablet = true;
        isPhone = false;
      } else {
        isTablet = false;
        isPhone = true;
      }
    }

    if (isIos &&
        isPhone &&
        (screenHeight == 812 ||
            screenWidth == 812 ||
            screenHeight == 896 ||
            screenWidth == 896 ||
            // iPhone 12 pro
            screenHeight == 844 ||
            screenWidth == 844 ||
            // Iphone 12 pro max
            screenHeight == 926 ||
            screenWidth == 926)) {
      isIphoneX = true;
      hasNotch = true;
    }

    if (_hasTopOrBottomPadding()) hasNotch = true;

    return _device = new Device(
        isTablet: isTablet,
        isPhone: isPhone,
        isAndroid: isAndroid,
        isIos: isIos,
        isIphoneX: isIphoneX,
        hasNotch: hasNotch);
  }

  static double _calWidth() {
    if (width > height)
      return (width +
          (WidgetsBinding.instance.platformDispatcher.views.first.viewPadding
                      .left +
                  WidgetsBinding.instance.platformDispatcher.views.first
                      .viewPadding.right) *
              width /
              height);
    return (width +
        WidgetsBinding
            .instance.platformDispatcher.views.first.viewPadding.left +
        WidgetsBinding
            .instance.platformDispatcher.views.first.viewPadding.right);
  }

  static double _calHeight() {
    return (height +
        (WidgetsBinding
                .instance.platformDispatcher.views.first.viewPadding.top +
            WidgetsBinding
                .instance.platformDispatcher.views.first.viewPadding.bottom));
  }

  static int get _ppi => Platform.isAndroid
      ? 160
      : Platform.isIOS
          ? 150
          : 96;

  static bool _hasTopOrBottomPadding() {
    final padding =
        WidgetsBinding.instance.platformDispatcher.views.first.viewPadding;
    //print(padding);
    return padding.top > 0 || padding.bottom > 0;
  }
}
