import '../models/part.dart';

class OCRService {
  /// Parses a single line from estimate text into a PartItem.
  ///
  /// Example input line: "Front Bumper 1 4500 4500"
  /// Parsing rules:
  /// - last number -> amount
  /// - second last -> rate
  /// - first number -> quantity
  /// - remaining text -> part name
  static PartItem? parseLine(String line, {int claimId = 0, int id = 0}) {
    final tokens = line.trim().split(RegExp(r"\s+"));
    if (tokens.length < 4) return null;

    try {
      double amount = double.parse(tokens.last);
      double rate = double.parse(tokens[tokens.length - 2]);
      int quantity = int.parse(tokens[tokens.length - 3]);
      String name = tokens.sublist(0, tokens.length - 3).join(' ');

      return PartItem(
        id: id,
        claimId: claimId,
        partName: name,
        quantity: quantity,
        rate: rate,
        amount: amount,
        materialType: '',
      );
    } catch (e) {
      // parsing failed
      return null;
    }
  }
}
