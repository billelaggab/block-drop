import 'package:flutter/services.dart';

class HapticService {
  bool enabled = true;

  void light() {
    if (!enabled) return;
    HapticFeedback.selectionClick();
  }

  void medium() {
    if (!enabled) return;
    HapticFeedback.lightImpact();
  }

  void strong() {
    if (!enabled) return;
    HapticFeedback.mediumImpact();
  }

  void heavy() {
    if (!enabled) return;
    HapticFeedback.heavyImpact();
  }
}
