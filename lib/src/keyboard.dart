part of virtual_keyboard_multi_language;

/// The default keyboard height. Can we overriden by passing
///  `height` argument to `VirtualKeyboard` widget.
const double _virtualKeyboardDefaultHeight = 300;

const int _virtualKeyboardBackspaceEventPerioud = 250;

/// Virtual Keyboard widget.
class VirtualKeyboard extends StatefulWidget {
  /// Keyboard Type: Should be inited in creation time.
  final VirtualKeyboardType type;

  /// Callback for Key press event. Called with pressed `Key` object.

  /// will fire before adding key's text to controller if a controller is provided
  final Function(VirtualKeyboardKey key)? preKeyPress;

  /// Callback for Key press event. Called with pressed `Key` object.
  /// will fire after adding key's text to controller if a controller is provided
  final Function(VirtualKeyboardKey key)? postKeyPress;

  final Function? onDone;


  /// Virtual keyboard height. Default is 300
  final double height;

  /// Virtual keyboard height. Default is full screen width
  final double? width;

  /// Color for key texts and icons.
  final Color textColor;

  /// Font size for keyboard keys.
  final double fontSize;

  /// the custom layout for multi or single language
  final VirtualKeyboardLayoutKeys? customLayoutKeys;

  /// the text controller go get the output and send the default input
  final TextEditingController? textController;

  /// The builder function will be called for each Key object.
  final Widget Function(BuildContext context, VirtualKeyboardKey key)? builder;

  /// Set to true if you want only to show Caps letters.
  final bool alwaysCaps;

  /// inverse the layout to fix the issues with right to left languages.
  final bool reverseLayout;

  /// used for multi-languages with default layouts, the default is English only
  /// will be ignored if customLayoutKeys is not null
  final List<VirtualKeyboardDefaultLayouts>? defaultLayouts;

  final double horizontalPadding;
  final double verticalPadding;

  VirtualKeyboard(
      {Key? key,
      required this.type,
      this.preKeyPress,
      this.postKeyPress,
      this.builder,
      this.width,
      this.defaultLayouts,
      this.customLayoutKeys,
      this.textController,
      this.onDone,
      this.reverseLayout = false,
      this.height = _virtualKeyboardDefaultHeight,
      this.textColor = Colors.black,
      this.fontSize = 14,
      this.horizontalPadding = 2,
      this.verticalPadding = 4,
      this.alwaysCaps = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _VirtualKeyboardState();
  }
}

/// Holds the state for Virtual Keyboard class.
class _VirtualKeyboardState extends State<VirtualKeyboard> {

  VirtualKeyboardType type = VirtualKeyboardType.Alphanumeric;
  Function(VirtualKeyboardKey key)? preKeyPress;
  Function(VirtualKeyboardKey key)? postKeyPress;
  TextEditingController? textController;

  // The builder function will be called for each Key object.
  Widget Function(BuildContext context, VirtualKeyboardKey key)? builder;
  late double height;
  double? width;
  late Color textColor;
  late double fontSize;
  late bool alwaysCaps;
  late bool reverseLayout;
  late VirtualKeyboardLayoutKeys customLayoutKeys;

  // Text Style for keys.
  late TextStyle textStyle;

  // True if shift is enabled.
  bool isShiftEnabled = false;

  void _onKeyPress(VirtualKeyboardKey key) {

    if (preKeyPress != null) preKeyPress!(key);

    if (key.keyType == VirtualKeyboardKeyType.String) {
      if (isShiftEnabled) {
        _insertText(key.capsText!);
      } else {
        _insertText(key.text!);
      }
    } else if (key.keyType == VirtualKeyboardKeyType.Action) {
      switch (key.action) {
        case VirtualKeyboardKeyAction.Backspace:
          _backspace();
          break;
        case VirtualKeyboardKeyAction.Delete:
          _delete();
          break;
        case VirtualKeyboardKeyAction.Return:
          FocusScope.of(context).unfocus();
          widget.onDone?.call();
          break;
        case VirtualKeyboardKeyAction.Space:

          _insertText(key.text!);
          break;
        case VirtualKeyboardKeyAction.Shift:

          break;
        case VirtualKeyboardKeyAction.Left:
          _moveCursorLeft();
          break;
        case VirtualKeyboardKeyAction.Right:
          _moveCursorRight();
          break;
        default:
      }
    }


    if (postKeyPress != null) postKeyPress!(key);
  }

  void _insertText(String myText) {
    if (textController != null) {
      final text = textController!.text;
      final textSelection = textController!.selection;
      final newText = text.replaceRange(
        (textSelection.start >= 0) ? textSelection.start : 0,
        (textSelection.end >= 0) ? textSelection.end : 0,
        myText,
      );
      final myTextLength = myText.length;
      textController!.text = newText;
      textController!.selection = textSelection.copyWith(
        baseOffset: min(
            textSelection.start + myTextLength, textController!.text.length),
        extentOffset: min(
            textSelection.start + myTextLength, textController!.text.length),
      );
    }
  }

  void _moveCursorLeft() {
    if (textController != null) {
      final text = textController!.text;
      final textSelection = textController!.selection;
      final selectionLength = textSelection.end - textSelection.start;

      int newOffset;
      if (selectionLength > 0) {
        // Collapse selection to the start
        newOffset = textSelection.start;
      } else if (textSelection.start > 0) {
        // Move cursor one character to the left
        final previousCodeUnit = text.codeUnitAt(textSelection.start - 1);
        final offset = _isUtf16Surrogate(previousCodeUnit) ? 2 : 1;
        newOffset = textSelection.start - offset;
      } else {
        // Cursor is already at the beginning
        newOffset = textSelection.start;
      }

      // Ensure newOffset is not negative
      if (newOffset < 0) {
        newOffset = 0;
      }

      textController!.selection = TextSelection.collapsed(offset: newOffset);
    }
  }
  void _moveCursorRight() {
    if (textController != null) {
      final text = textController!.text;
      final textSelection = textController!.selection;
      final selectionLength = textSelection.end - textSelection.start;

      int newOffset;
      if (selectionLength > 0) {
        // Collapse selection to the end
        newOffset = textSelection.end;
      } else if (textSelection.start < text.length) {
        // Move cursor one character to the right
        final nextCodeUnit = text.codeUnitAt(textSelection.start);
        final offset = _isUtf16Surrogate(nextCodeUnit) ? 2 : 1;
        newOffset = textSelection.start + offset;
      } else {
        // Cursor is already at the end
        newOffset = textSelection.start;
      }

      // Ensure newOffset doesn't exceed text length
      if (newOffset > text.length) {
        newOffset = text.length;
      }

      textController!.selection = TextSelection.collapsed(offset: newOffset);
    }
  }
  void _delete() {
    if (textController != null) {
      final text = textController!.text;
      final textSelection = textController!.selection;
      final selectionLength = textSelection.end - textSelection.start;

      // There is a selection.
      if (selectionLength > 0) {
        final newText = text.replaceRange(
          textSelection.start,
          textSelection.end,
          '',
        );
        textController!.text = newText;
        textController!.selection = textSelection.copyWith(
          baseOffset: textSelection.start,
          extentOffset: textSelection.start,
        );
        return;
      }

      // The cursor is at the end.
      if (textSelection.start == text.length) {
        return;
      }

      // Delete the next character
      final nextCodeUnit = text.codeUnitAt(textSelection.start);
      final offset = _isUtf16Surrogate(nextCodeUnit) ? 2 : 1;
      final newStart = textSelection.start;
      final newEnd = textSelection.start + offset;

      // Ensure we don't go past the end of the text
      if (newEnd > text.length) {
        return;
      }

      final newText = text.replaceRange(
        newStart,
        newEnd,
        '',
      );
      textController!.text = newText;
      textController!.selection = textSelection.copyWith(
        baseOffset: newStart,
        extentOffset: newStart,
      );
    }
  }
  void _backspace() {
    if (textController != null) {
      final text = textController!.text;
      final textSelection = textController!.selection;
      final selectionLength = textSelection.end - textSelection.start;

      // There is a selection.
      if (selectionLength > 0) {
        final newText = text.replaceRange(
          textSelection.start,
          textSelection.end,
          '',
        );
        textController!.text = newText;
        textController!.selection = textSelection.copyWith(
          baseOffset: textSelection.start,
          extentOffset: textSelection.start,
        );
        return;
      }

      // The cursor is at the beginning.
      if (textSelection.start == 0) {
        return;
      }

      // Delete the previous character
      final previousCodeUnit = text.codeUnitAt(textSelection.start - 1);
      final offset = _isUtf16Surrogate(previousCodeUnit) ? 2 : 1;
      final newStart = textSelection.start - offset;
      final newEnd = textSelection.start;
      final newText = text.replaceRange(
        newStart,
        newEnd,
        '',
      );
      textController!.text = newText;
      textController!.selection = textSelection.copyWith(
        baseOffset: newStart,
        extentOffset: newStart,
      );
    }
  }

  bool _isUtf16Surrogate(int value) {
    return value & 0xF800 == 0xD800;
  }

  @override
  void didUpdateWidget(VirtualKeyboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      type = widget.type;
      preKeyPress = widget.preKeyPress;
      postKeyPress = widget.postKeyPress;
      height = widget.height;
      width = widget.width;
      textColor = widget.textColor;
      fontSize = widget.fontSize;
      alwaysCaps = widget.alwaysCaps;
      reverseLayout = widget.reverseLayout;
      textController = widget.textController;
      customLayoutKeys = widget.customLayoutKeys ?? customLayoutKeys;
      // Init the Text Style for keys.
      textStyle = TextStyle(
        fontSize: fontSize,
        color: textColor,
      );
    });
  }

  @override
  void initState() {
    super.initState();


    textController = widget.textController;
    width = widget.width;
    type = widget.type;
    customLayoutKeys = widget.customLayoutKeys ??
        VirtualKeyboardDefaultLayoutKeys(
            widget.defaultLayouts ?? [VirtualKeyboardDefaultLayouts.English]);

    preKeyPress = widget.preKeyPress;
    postKeyPress = widget.postKeyPress;
    height = widget.height;
    textColor = widget.textColor;
    fontSize = widget.fontSize;
    alwaysCaps = widget.alwaysCaps;
    reverseLayout = widget.reverseLayout;
    // Init the Text Style for keys.
    textStyle = TextStyle(
      fontSize: fontSize,
      color: textColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return type == VirtualKeyboardType.Numeric ? _numeric() : _alphanumeric();
  }

  Widget _alphanumeric() {
    return Container(
      height: height + widget.verticalPadding * 10,
      width: width ?? MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _rows(),
      ),
    );
  }

  Widget _numeric() {
    return Container(
      height: height,
      width: width ?? MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _rows(),
      ),
    );
  }

  /// Returns the rows for keyboard.

  List<Widget> _rows() {
    // Get the keyboard Rows
    List<List<VirtualKeyboardKey>> keyboardRows =
    type == VirtualKeyboardType.Numeric
        ? _getKeyboardRowsNumeric()
        : _getKeyboardRows(customLayoutKeys);

    // Generate keyboard rows.
    List<Widget> rows = List.generate(keyboardRows.length, (int rowNum) {
      var items = List.generate(keyboardRows[rowNum].length, (int keyNum) {
        // Get the VirtualKeyboardKey object.
        VirtualKeyboardKey virtualKeyboardKey = keyboardRows[rowNum][keyNum];

        Widget keyWidget;

        // Check if builder is specified.
        // Call builder function if specified or use default
        // Key widgets if not.
        if (builder == null) {
          // Check the key type.
          switch (virtualKeyboardKey.keyType) {
            case VirtualKeyboardKeyType.String:
            // Draw String key.
              keyWidget = _keyboardDefaultKey(virtualKeyboardKey);
              break;
            case VirtualKeyboardKeyType.Action:
            // Draw action key.
              keyWidget = _keyboardDefaultActionKey(virtualKeyboardKey);
              break;
          }
        } else {
          // Call the builder function, so the user can specify custom UI for keys.
          keyWidget = builder!(context, virtualKeyboardKey);
        }

        return keyWidget;
      });

      if (this.reverseLayout) items = items.reversed.toList();

      // Define padding or offsets for specific rows to achieve staggered layout
      Widget rowWidget;
      if (rowNum == 2 && type != VirtualKeyboardType.Numeric) {
        double paddingWidth = 20.0;

        rowWidget = Padding(
          padding: EdgeInsets.only(left: paddingWidth),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: items,
          ),
        );
      } else if (rowNum == 3 && type != VirtualKeyboardType.Numeric) { // For the third row, if needed
        // Adjust the padding width for the third row
        double paddingWidth = 40.0;

        rowWidget = Padding(
          padding: EdgeInsets.only(left: paddingWidth),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: items,
          ),
        );
      } else {
        // For rows that don't need padding
        rowWidget = Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center or adjust as needed
          crossAxisAlignment: CrossAxisAlignment.center,
          children: items,
        );
      }
      return Material(
        color: Colors.transparent,
        child: rowWidget,
      );
    });

    return rows;
  }

  // True if long press is enabled.
  bool longPress = false;

  /// Creates default UI element for keyboard Key.
  Widget _keyboardDefaultKey(VirtualKeyboardKey key) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.horizontalPadding,
          vertical: widget.verticalPadding,
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: () {
              _onKeyPress(key);
            },
            borderRadius: BorderRadius.circular(6),
            highlightColor: Colors.grey.shade700,
            splashColor: Colors.grey.shade600,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.white38,
                    blurRadius: 20,
                    offset: Offset(0, 5),
                  ),
                ],
                borderRadius: BorderRadius.circular(6),
              ),
              height: height / customLayoutKeys.activeLayout.length,
              alignment: Alignment.center,
              child: Text(
                alwaysCaps
                    ? key.capsText!
                    : (isShiftEnabled ? key.capsText! : key.text!),
                style: textStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }
  // Widget _keyboardDefaultKey(VirtualKeyboardKey key) {
  //   return Expanded(
  //     child: Padding(
  //       padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding,
  //           vertical: widget.verticalPadding),
  //       child: Material(
  //         color: Colors.transparent,
  //         child: InkWell(
  //           onTap: () {
  //             _onKeyPress(key);
  //           },
  //           //TODO: change colors
  //           borderRadius: BorderRadius.circular(6),
  //           highlightColor: Colors.black,
  //           splashColor: Colors.black,
  //           child: Container(
  //             decoration: BoxDecoration(
  //               boxShadow: [BoxShadow(color: Colors.white38, blurRadius: 20, offset: Offset(0, 5))],
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(6),
  //             ),
  //             height: height / customLayoutKeys.activeLayout.length,
  //             child: Center(
  //                 child: Text(
  //               alwaysCaps
  //                   ? key.capsText!
  //                   : (isShiftEnabled ? key.capsText! : key.text!),
  //               style: textStyle,
  //             )),
  //           ),
  //         ),
  //       ),
  //     ));
  // }

  /// Creates default UI element for keyboard Action Key.
  Widget _keyboardDefaultActionKey(VirtualKeyboardKey key) {
    // Holds the action key widget.
    Widget? actionKey;

    // Switch the action type to build action Key widget.

    switch (key.action!) {
      case VirtualKeyboardKeyAction.Backspace:
        actionKey = GestureDetector(
            onLongPress: () {
              longPress = true;
              // Start sending backspace key events while longPress is true
              Timer.periodic(
                  Duration(milliseconds: _virtualKeyboardBackspaceEventPerioud),
                  (timer) {
                if (longPress) {
                  _onKeyPress(key);
                } else {
                  // Cancel timer.
                  timer.cancel();
                }
              });
            },
            onLongPressUp: () {
              // Cancel event loop
              longPress = false;
            },
            child: Container(
              height: double.infinity,
              width: double.infinity,


              child: Directionality(textDirection: customLayoutKeys.activeIndex == 1 ? TextDirection.ltr : TextDirection.rtl,
                child: Icon(
                  Icons.backspace_outlined,
                  color: textColor,
                ),
              ),
            ));
        break;
      case VirtualKeyboardKeyAction.Shift:
        actionKey = Container(
            height: double.infinity,
            width: double.infinity,
            child: Icon(Icons.arrow_upward, color: textColor));
        break;
      case VirtualKeyboardKeyAction.Space:
        actionKey = actionKey = Container(
            height: double.infinity,
            width: double.infinity,
            child: Icon(Icons.space_bar, color: textColor));
        break;
      case VirtualKeyboardKeyAction.Return:
        actionKey = Container(
          height: double.infinity,
          width: double.infinity,
          child: Icon(
            Icons.keyboard_return_rounded,
            color: Color.fromRGBO(0x65, 0x66, 0xDE, 1.0),
          ),
        );
        break;
      case VirtualKeyboardKeyAction.SwitchLanguage:
        actionKey = GestureDetector(
            onTap: () {
              setState(() {
                customLayoutKeys.switchLanguage();
              });
            },
            child: Container(
              height: double.infinity,
              width: double.infinity,
              child: Icon(
                Icons.language,
                color: textColor,
              ),
            ));
        break;

      case VirtualKeyboardKeyAction.Delete:
        actionKey = GestureDetector(

            onLongPress: () {
              longPress = true;
              // Start sending backspace key events while longPress is true
              Timer.periodic(
                  Duration(milliseconds: _virtualKeyboardBackspaceEventPerioud),
                      (timer) {
                    if (longPress) {
                      _onKeyPress(key);
                    } else {
                      // Cancel timer.
                      timer.cancel();
                    }
                  });
            },
            onLongPressUp: () {
              // Cancel event loop
              longPress = false;
            },
            child: Container(
              height: double.infinity,
              width: double.infinity,
              child: Center(
                child: Text(
                  "Del",
                  style: textStyle,
                  // color: textColor,
                ),
              ),
            ));
        break;
      case VirtualKeyboardKeyAction.Left:
        actionKey = GestureDetector(

            onLongPress: () {
              longPress = true;
              // Start sending backspace key events while longPress is true
              Timer.periodic(
                  Duration(milliseconds: _virtualKeyboardBackspaceEventPerioud),
                      (timer) {
                    if (longPress) {
                      _onKeyPress(key);
                    } else {
                      // Cancel timer.
                      timer.cancel();
                    }
                  });
            },
            onLongPressUp: () {
              // Cancel event loop
              longPress = false;
            },
            child: Container(
              height: double.infinity,
              width: double.infinity,
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: textColor,
              ),
            ));
        break;
      case VirtualKeyboardKeyAction.Right:
        actionKey = GestureDetector(
            onLongPress: () {
              longPress = true;
              // Start sending backspace key events while longPress is true
              Timer.periodic(
                  Duration(milliseconds: _virtualKeyboardBackspaceEventPerioud),
                      (timer) {
                    if (longPress) {
                      _onKeyPress(key);
                    } else {
                      // Cancel timer.
                      timer.cancel();
                    }
                  });
            },
            onLongPressUp: () {
              // Cancel event loop
              longPress = false;
            },
            child: Container(
              height: double.infinity,
              width: double.infinity,
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: textColor,
              ),
            ));
        break;
    }

    var wdgt = Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
      child: Material(
        color: key.action == VirtualKeyboardKeyAction.Space
            ? Colors.white
            : Color.fromRGBO(0xC3, 0xC4, 0xD8, 1.0),
        borderRadius: BorderRadius.circular(6),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () {
            if (key.action == VirtualKeyboardKeyAction.Shift) {
              if (!alwaysCaps) {
                setState(() {
                  isShiftEnabled = !isShiftEnabled;
                });
              }
            }
            _onKeyPress(key);
          },
          borderRadius: BorderRadius.circular(6),
          highlightColor: Colors.grey.shade700,
          splashColor: Colors.grey.shade600,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.white38, blurRadius: 20, offset: Offset(0, 5))],
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            height: height / customLayoutKeys.activeLayout.length,
            child: actionKey,
          ),
        ),
      ),
    );


    if (key.action == VirtualKeyboardKeyAction.Space){
      return Expanded(flex: 6, child: wdgt);

    } else if (((key.action == VirtualKeyboardKeyAction.Backspace && widget.defaultLayouts?[customLayoutKeys.activeIndex] == VirtualKeyboardDefaultLayouts.Arabic) ||
              (key.action == VirtualKeyboardKeyAction.Return && widget.defaultLayouts?[customLayoutKeys.activeIndex] == VirtualKeyboardDefaultLayouts.English) )&&
              (widget.type != VirtualKeyboardType.Numeric)
    ) {
      return Expanded(flex: 2, child: wdgt);
    }
    else
        return Expanded(child: wdgt);
    }
}
