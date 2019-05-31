part of 'scanner.dart';

class Token {
  final TokenType type;

  final FileSpan span;

  final Match match;

  Token(this.type, this.span, this.match);

  String get text => span.text;

  @override
  String toString() {
    return '$type: "${span.text}"';
  }
}

enum TokenType {
  comment,
  newLine,

  // Operators
  dot,
  comma,
  assign,
  semicolon,

  addAssign,
  subAssign,
  mulAssign,
  divAssign,
  modAssign,
  powAssign,
  orAssign,
  andAssign,
  xorAssign,

  plus,
  minus,
  asterisk,
  div,
  mod,
  pow,
  bitwiseOr,
  bitwiseAnd,
  bitwiseXor,

  // Brackets
  leftSquareBracket,
  rightSquareBracket,
  leftCurlyBracket,
  rightCurlyBracket,
  leftAngleBracket,
  rightAngleBracket,
  leftBracket,
  rightBracket,

  // Data
  false_,
  true_,
  integer,
  hexInteger,
  binaryInteger,
  double,
  string,
  key,
  identifier,
  date,

  let,
}

final normalPatterns = <Pattern, TokenType>{
  '\r\n': TokenType.newLine,
  '\n': TokenType.newLine,

  '.': TokenType.dot,
  '=': TokenType.assign,
  ',': TokenType.comma,
  ';': TokenType.semicolon,

  '+': TokenType.plus,
  '-': TokenType.minus,
  '*': TokenType.asterisk,
  '/': TokenType.div,
  '%': TokenType.mod,
  '**': TokenType.pow,
  '|': TokenType.bitwiseOr,
  '&': TokenType.bitwiseAnd,
  '^': TokenType.bitwiseXor,

  '+=': TokenType.addAssign,
  '-=': TokenType.subAssign,
  '*=': TokenType.mulAssign,
  '/=': TokenType.divAssign,
  '%=': TokenType.modAssign,
  '**=': TokenType.powAssign,
  '|=': TokenType.orAssign,
  '&=': TokenType.andAssign,
  '^=': TokenType.xorAssign,

  '[': TokenType.leftSquareBracket,
  ']': TokenType.rightSquareBracket,
  '{': TokenType.leftCurlyBracket,
  '}': TokenType.rightCurlyBracket,
  '<': TokenType.leftAngleBracket,
  '>': TokenType.rightAngleBracket,
  '(': TokenType.leftBracket,
  ')': TokenType.rightBracket,

  'let': TokenType.let,

  'false': TokenType.false_,
  'true': TokenType.true_,
  'f': TokenType.false_,
  't': TokenType.true_,
  'no': TokenType.false_,
  'yes': TokenType.true_,
  'n': TokenType.false_,
  'y': TokenType.true_,
  RegExp(r'[0-9]+([_0-9]*[0-9])*'): TokenType.integer,
  RegExp(r'0x([A-Fa-f0-9]+)'): TokenType.hexInteger,
  RegExp(r'0b([01]+)'): TokenType.binaryInteger,
  RegExp(r'[0-9]+((\.[0-9]+)|b)?'): TokenType.double,
  RegExp(r"@'[0-9a-zA-Z\-\+: ]*'"): TokenType.date,
  singleQuotedString: TokenType.string,
  doubleQuotedString: TokenType.string,
  RegExp(r'[A-Za-z_][A-Za-z0-9_]*'): TokenType.key,
  RegExp(r'\$[A-Za-z_][A-Za-z0-9_]*'): TokenType.identifier,

  RegExp(r'#([^\n]*)'): TokenType.comment,
};

final RegExp doubleQuotedString = new RegExp(
    r'"((\\(["\\/bfnrt]|(u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])))|([^"\\]))*"');

final RegExp singleQuotedString = new RegExp(
    r"'((\\(['\\/bfnrt]|(u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])))|([^'\\]))*'");
