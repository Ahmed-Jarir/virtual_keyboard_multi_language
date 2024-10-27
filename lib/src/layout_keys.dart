part of virtual_keyboard_multi_language;
//import '../virtual_keyboard_multi_language.dart';

abstract class VirtualKeyboardLayoutKeys {
  int activeIndex = 0;

  List<List> get defaultEnglishLayout => _defaultEnglishLayout;
  List<List> get defaultArabicLayout => _defaultArabicLayout;

  List<List> get activeLayout => getLanguage(activeIndex);
  int getLanguagesCount();
  List<List> getLanguage(int index);

  void switchLanguage() {
    if ((activeIndex + 1) == getLanguagesCount())
      activeIndex = 0;
    else
      activeIndex++;
  }
}

class VirtualKeyboardDefaultLayoutKeys extends VirtualKeyboardLayoutKeys {
  List<VirtualKeyboardDefaultLayouts> defaultLayouts;
  VirtualKeyboardDefaultLayoutKeys(this.defaultLayouts);

  int getLanguagesCount() => defaultLayouts.length;

  List<List> getLanguage(int index) {
    switch (defaultLayouts[index]) {
      case VirtualKeyboardDefaultLayouts.English:
        return _defaultEnglishLayout;
      case VirtualKeyboardDefaultLayouts.Arabic:
        return _defaultArabicLayout;
      case VirtualKeyboardDefaultLayouts.Kurdish:
        return _defaultKurdishLayout;
      default:
    }
    return _defaultEnglishLayout;
  }
}

/// Keys for Virtual Keyboard's rows.
const List<List> _defaultEnglishLayout = [
  // Row 1
  const [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '0',
    VirtualKeyboardKeyAction.Delete
  ],
  // Row 2
  const [
    'q',
    'w',
    'e',
    'r',
    't',
    'y',
    'u',
    'i',
    'o',
    'p',
    VirtualKeyboardKeyAction.Backspace
  ],
  // Row 3
  const [
    'a',
    's',
    'd',
    'f',
    'g',
    'h',
    'j',
    'k',
    'l',
    // '\'',
    VirtualKeyboardKeyAction.Return
  ],
  // Row 4
  const [
    'z',
    'x',
    'c',
    'v',
    'b',
    'n',
    'm',
    ',',
    '.',
    VirtualKeyboardKeyAction.Shift
  ],
  // Row 5
  const [
    VirtualKeyboardKeyAction.SwitchLanguage,
    '@',
    VirtualKeyboardKeyAction.Space,
    VirtualKeyboardKeyAction.Left,
    VirtualKeyboardKeyAction.Right,
  ]
];

const List<List> _defaultArabicLayout = [
  // Row 1
  const [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '0',
    VirtualKeyboardKeyAction.Delete
  ],
  // Row 2
  const [
    'ض',
    'ص',
    'ث',
    'ق',
    'ف',
    'غ',
    'ع',
    'ه',
    'خ',
    'ح',
    'ج',
    VirtualKeyboardKeyAction.Backspace
  ],
  // Row 3
  const [
    'ش',
    'س',
    'ي',
    'ب',
    'ل',
    'ا',
    'ت',
    'ن',
    'م',
    'ك',
    'ط',
    VirtualKeyboardKeyAction.Return
  ],
  // Row 4
  const [
    'ذ',
    'ئ',
    'ء',
    'ؤ',
    'ر',
    'لا',
    'ى',
    'ة',
    'و',
    'ز',
    'ظ',
    'د',
    '،',
    '.',
  ],
  // Row 5
  const [
    VirtualKeyboardKeyAction.SwitchLanguage,
    '@',
    VirtualKeyboardKeyAction.Space,
    VirtualKeyboardKeyAction.Left,
    VirtualKeyboardKeyAction.Right,

  ]
];



const List<List> _defaultKurdishLayout = [
  // Row 1
  const [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '0',
  ],
  // Row 2
  const [
    'چ',
    'پ',
    'ق',
    'ڤ',
    'ف',
    'غ',
    'ھ',
    'خ',
    'ح',
    'ج',
  ],
  // Row 3
  const [
    'ش',
    'س',
    'ی',
    'ب',
    'ل',
    'ا',
    'ت',
    'ن',
    'م',
    'ک',
    'گ',

  ],
  // Row 4
  const [
    'ئ',
    'ڕ',
    'ر',
    'ێ',
    'ڵ',
    'ە',
    'و',
    'ز',
    'ۆ',
    'د',
    VirtualKeyboardKeyAction.Backspace

  ],
  // Row 5
  const [
    VirtualKeyboardKeyAction.SwitchLanguage,
    '@',
    VirtualKeyboardKeyAction.Space,
    '-',
    '.',
    '_',
    VirtualKeyboardKeyAction.Return,
  ]
];