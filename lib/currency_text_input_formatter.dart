library currency_text_input_formatter;

import 'dart:math';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Flutter plugin for currency text input formatter.
///
/// See [the official documentation](https://github.com/gtgalone/currency_text_input_formatter)
/// for more information on how to use TextInputFormatter.
class CurrencyTextInputFormatter extends TextInputFormatter {
  /// Builds an CurrencyTextInputFormatter with the following parameters.
  ///
  /// [format] Number format .
  ///
  /// [enableNegative] argument is used to enable negative value.
  ///
  /// [inputDirection] argument is used to set input direction.
  ///
  /// [minValue] argument is used to set min value.
  ///
  /// [maxValue] argument is used to set max value.
  ///
  /// [onChange] argument is used to set callback when value is changed.
  factory CurrencyTextInputFormatter(
    NumberFormat format, {
    bool enableNegative = true,
    InputDirection inputDirection = InputDirection.right,
    num? minValue,
    num? maxValue,
    Function(String)? onChange,
  }) {
    return CurrencyTextInputFormatter._(
      format,
      enableNegative,
      inputDirection,
      minValue,
      maxValue,
      onChange,
    );
  }

  CurrencyTextInputFormatter._(
    this.format,
    this.enableNegative,
    this.inputDirection,
    this.minValue,
    this.maxValue,
    this.onChange,
  );

  /// Builds an CurrencyTextInputFormatter with the following parameters.
  ///
  /// [locale] argument is used to locale of NumberFormat currency.
  ///
  /// [name] argument is used to locale of NumberFormat currency.
  ///
  /// [symbol] argument is used to symbol of NumberFormat currency.
  ///
  /// [decimalDigits] argument is used to decimalDigits of NumberFormat currency.
  ///
  /// [customPattern] argument is used to locale of NumberFormat currency.
  ///
  /// [turnOffGrouping] argument is used to locale of NumberFormat currency.
  ///
  /// [enableNegative] argument is used to enable negative value.
  ///
  /// [inputDirection] argument is used to set input direction.
  ///
  /// [minValue] argument is used to set min value.
  ///
  /// [maxValue] argument is used to set max value.
  ///
  /// [onChange] argument is used to set callback when value is changed.
  factory CurrencyTextInputFormatter.currency({
    String? locale,
    String? name,
    String? symbol,
    int? decimalDigits,
    String? customPattern,
    bool turnOffGrouping = false,
    bool enableNegative = true,
    InputDirection inputDirection = InputDirection.right,
    num? minValue,
    num? maxValue,
    Function(String)? onChange,
  }) {
    final NumberFormat format = NumberFormat.currency(
      locale: locale,
      name: name,
      symbol: symbol,
      decimalDigits: decimalDigits,
      customPattern: customPattern,
    );

    if (turnOffGrouping) {
      format.turnOffGrouping();
    }

    return CurrencyTextInputFormatter._(
      format,
      enableNegative,
      inputDirection,
      minValue,
      maxValue,
      onChange,
    );
  }

  /// Builds an CurrencyTextInputFormatter with simpleCurrency the following parameters.
  ///
  /// [locale] argument is used to locale of NumberFormat currency.
  ///
  /// [name] argument is used to locale of NumberFormat currency.
  ///
  /// [decimalDigits] argument is used to decimalDigits of NumberFormat currency.
  ///
  /// [turnOffGrouping] argument is used to locale of NumberFormat currency.
  ///
  /// [enableNegative] argument is used to enable negative value.
  ///
  /// [inputDirection] argument is used to set input direction.
  ///
  /// [minValue] argument is used to set min value.
  ///
  /// [maxValue] argument is used to set max value.
  ///
  /// [onChange] argument is used to set callback when value is changed.
  factory CurrencyTextInputFormatter.simpleCurrency({
    String? locale,
    String? name,
    int? decimalDigits,
    bool turnOffGrouping = false,
    bool enableNegative = true,
    InputDirection inputDirection = InputDirection.right,
    num? minValue,
    num? maxValue,
    Function(String)? onChange,
  }) {
    final NumberFormat format = NumberFormat.simpleCurrency(
      locale: locale,
      name: name,
      decimalDigits: decimalDigits,
    );

    if (turnOffGrouping) {
      format.turnOffGrouping();
    }

    return CurrencyTextInputFormatter._(
      format,
      enableNegative,
      inputDirection,
      minValue,
      maxValue,
      onChange,
    );
  }

  /// NumberFormat
  final NumberFormat format;

  /// Defaults `enableNegative` is true.
  ///
  /// Set to false if you want to disable negative numbers.
  final bool enableNegative;

  /// Defaults `inputDirection` is InputDirection.right.
  ///
  /// Set to InputDirection.left if you want to type from left.
  /// InputDirection.left cannot support formatting for now. You need to format
  /// your self.
  final InputDirection inputDirection;

  /// Defaults `minValue` is null.
  final num? minValue;

  /// Defaults `maxValue` is null.
  final num? maxValue;

  /// Callback when value is changed.
  /// You can use this to listen to value changes.
  /// e.g. onChange: (value) => print(value);
  final Function(String)? onChange;

  num _newNum = 0;
  String _newString = '';
  bool _isNegative = false;

  /// Returns the NumberFormat created on currency and simpleCurrency constructors
  NumberFormat get numberFormat {
    return format;
  }

  void _formatter(String newText, [num? initialDecimalDigits]) {
    _newNum = _parseStrToNum(newText, initialDecimalDigits);
    _newString = (_isNegative ? '-' : '') + format.format(_newNum).trim();
  }

  num _parseStrToNum(String text, [num? initialDecimalDigits]) {
    num value = num.tryParse(text) ?? 0;

    if (initialDecimalDigits != null) {
      value /= pow(10, initialDecimalDigits);
    } else if (format.decimalDigits! > 0) {
      value /= pow(10, format.decimalDigits!);
    }
    return value;
  }

  bool _isLessThanMinValue(num value) {
    if (minValue == null) {
      return false;
    }
    return value < minValue!;
  }

  bool _isMoreThanMaxValue(num value) {
    if (maxValue == null) {
      return false;
    }
    return value > maxValue!;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final bool isLeft = inputDirection == InputDirection.left;
    if (isLeft) {
      final List<String> nums = newValue.text.split('.');
      if (nums.length > 2) {
        return oldValue;
      }
      if (nums.length == 2 && (nums[1].length > (format.decimalDigits ?? 2))) {
        return oldValue;
      }
      final double? v = double.tryParse(newValue.text);
      if (v == null) {
        return oldValue;
      }
      if (_isLessThanMinValue(v) || _isMoreThanMaxValue(v)) {
        return oldValue;
      }
      _newNum = v;
      _newString = newValue.text;
      return newValue;
    }

    // final bool isInsertedCharacter =
    //     oldValue.text.length + 1 == newValue.text.length &&
    //         newValue.text.startsWith(oldValue.text);
    final bool isRemovedCharacter =
        oldValue.text.length - 1 == newValue.text.length &&
            oldValue.text.startsWith(newValue.text);

    // Apparently, Flutter has a bug where the framework calls
    // formatEditUpdate twice, or even four times, after a backspace press (see
    // https://github.com/gtgalone/currency_text_input_formatter/issues/11).
    // However, only the first of these calls has inputs which are consistent
    // with a character insertion/removal at the end (which is the most common
    // use case of editing the TextField - the others being insertion/removal
    // in the middle, or pasting text onto the TextField). This condition
    // fixes a problem where a character wasn't properly erased after a
    // backspace press, when this Flutter bug was present. This comes at the
    // cost of losing insertion/removal in the middle and pasting text.
    // if (!isInsertedCharacter && !isRemovedCharacter) {
    //   return oldValue;
    // }

    if (enableNegative) {
      _isNegative = newValue.text.startsWith('-');
    } else {
      _isNegative = false;
    }

    String newText = newValue.text.replaceAll(RegExp('[^0-9]'), '');

    // If the user wants to remove a digit, but the last character of the
    // formatted text is not a digit (for example, "1,00 €"), we need to remove
    // the digit manually.
    if (isRemovedCharacter && !_lastCharacterIsDigit(oldValue.text)) {
      final int length = newText.length - 1;
      newText = newText.substring(0, length > 0 ? length : 0);
    }

    final num value = _parseStrToNum(newText);

    if (_isLessThanMinValue(value) || _isMoreThanMaxValue(value)) {
      return oldValue;
    }

    if (oldValue.text.isEmpty ||
        (oldValue.selection.baseOffset == 0 &&
            oldValue.selection.extentOffset == oldValue.text.length)) {
      num? initialDecimalDigits;
      if (newValue.text.contains('.')) {
        initialDecimalDigits = newValue.text.split('.').lastOrNull?.length ?? 0;
      }

      _formatter(newText, initialDecimalDigits);
    } else {
      _formatter(newText);
    }

    if (newText.trim() == '' || newText == '00' || newText == '000') {
      return TextEditingValue(
        text: _isNegative ? '-' : '',
        selection: TextSelection.collapsed(offset: _isNegative ? 1 : 0),
      );
    }

    /// Call onChange callback
    if (onChange != null) {
      onChange!(_newString);
    }

    final int cursorPosition =
        _calculateCursorPosition(oldValue, newValue.selection.end);

    return TextEditingValue(
      text: _newString,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }

  int _calculateCursorPosition(
    TextEditingValue oldValue,
    int cursorPosition,
  ) {
    final String oldText = oldValue.text;

    // Empty text start cursor from length of masked string
    if (oldText.isEmpty) {
      return _newString.length;
    }

    // When number starts with negative
    if (oldText == '-' && _isNegative) {
      return _newString.length;
    }

    final num oldNumber =
        _parseStrToNum(oldText.replaceAll(RegExp('[^0-9]'), ''));

    // When select all
    if (oldValue.selection.baseOffset == 0 &&
        oldValue.selection.extentOffset == oldText.length) {
      return _newString.length;
    }

    // When cursor is before currency symbol
    if (cursorPosition <= format.currencySymbol.length) {
      if (oldNumber >= _newNum) {
        if (_isNegative) {
          return format.currencySymbol.length + 1;
        }
        return format.currencySymbol.length;
      }
      if (_isNegative) {
        return format.currencySymbol.length + 2;
      }
      return format.currencySymbol.length + 1;
    }

    // Comma calculations
    final List<int> oldCommaPositions = _seperatorPositions(oldText);
    final List<int> newCommaPositions = _seperatorPositions(_newString);

    final int newCommasBeforeCursor = newCommaPositions
        .where((int element) => element < cursorPosition)
        .length;

    final int oldCommasBeforeCursor = oldCommaPositions
        .where((int element) => element < cursorPosition)
        .length;

    cursorPosition =
        cursorPosition + newCommasBeforeCursor - oldCommasBeforeCursor;

    // Shift after comma
    if (newCommaPositions.contains(cursorPosition) &&
        _newString.length > oldText.length) {
      cursorPosition += 1;
    }

    // Decimal calculations
    final List<int> decimalPositions =
        _seperatorPositions(_newString, separator: '.');

    // Shift after decimal
    if (format.decimalDigits != null) {
      if (decimalPositions
          .where((int element) => element <= cursorPosition)
          .isNotEmpty) {
        if (_newNum > oldNumber) {
          cursorPosition -= 1;

          if (_newNum >= 10) {
            cursorPosition += 1;
          }
        } else {
          if (_newNum < 1) {
            cursorPosition += 1;
          }
        }
      }
    }

    if (cursorPosition > _newString.length) {
      return _newString.length;
    }

    return cursorPosition;
  }

  static List<int> _seperatorPositions(String text, {String separator = ','}) {
    final List<int> positions = <int>[];
    for (int i = 0; i < text.length; i++) {
      if (text[i] == separator) {
        positions.add(i);
      }
    }
    return positions;
  }

  static bool _lastCharacterIsDigit(String text) {
    final String lastChar = text.substring(text.length - 1);
    return RegExp('[0-9]').hasMatch(lastChar);
  }

  /// Get String type value with format such as `$ 2,000.00`
  String getFormattedValue() {
    return _newString;
  }

  /// Get num type value without format such as `2000.00`
  num getUnformattedValue() {
    return _isNegative ? (_newNum * -1) : _newNum;
  }

  /// Method for formatting value.
  /// You can use initialValue with this method.
  String formatString(String value) {
    if (enableNegative) {
      _isNegative = value.startsWith('-');
    } else {
      _isNegative = false;
    }

    final String newText = value.replaceAll(RegExp('[^0-9]'), '');

    num? initialDecimalDigits = 0;
    if (value.contains('.')) {
      initialDecimalDigits = value.split('.').lastOrNull?.length ?? 0;
    }

    _formatter(newText, initialDecimalDigits);
    return _newString;
  }

  /// Method for formatting value.
  /// You can use initialValue(double) with this method.
  String formatDouble(double value) {
    if (enableNegative) {
      _isNegative = value.isNegative;
    } else {
      _isNegative = false;
    }

    final String newText = value
        .toStringAsFixed(format.decimalDigits ?? 0)
        .replaceAll(RegExp('[^0-9]'), '');
    _formatter(newText);
    return _newString;
  }

  /// get double value
  double getDouble() {
    return getUnformattedValue().toDouble();
  }
}

/// Enum for input direction.
enum InputDirection {
  /// Left input direction
  left,

  /// Right input direction
  right,
}
