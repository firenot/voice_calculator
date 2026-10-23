import 'number_vocabulary.dart';

class CalculationResult {
  final String displayExpression;
  final String result;
  final bool success;

  CalculationResult({
    required this.displayExpression,
    required this.result,
    required this.success,
  });
}

class CalculatorEngine {
  static CalculationResult calculate(String text) {
    try {
      String cleanText = text.toLowerCase().trim();

      List<String> words = cleanText
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .toList();

      List<dynamic> tokens = [];
      List<String> currentNumWords = [];

      bool? isIncreaseCommand;

      void flushNumber() {
        if (currentNumWords.isEmpty) return;
        num total = 0;
        num subTotal = 0;

        for (var w in currentNumWords) {
          num? val = NumberVocabulary.parseWord(w);
          if (val != null) {
            if (val == 100 || val >= 1000) {
              if (subTotal == 0) subTotal = 1;
              total += subTotal * val;
              subTotal = 0;
            } else {
              subTotal += val;
            }
          }
        }
        total += subTotal;
        tokens.add(total);
        currentNumWords.clear();
      }

      for (int i = 0; i < words.length; i++) {
        String word = words[i];

        if (word == 'увеличь' || word == 'увеличить') {
          isIncreaseCommand = true;
          continue;
        } else if (word == 'уменьши' || word == 'уменьшить') {
          isIncreaseCommand = false;
          continue;
        }

        if (isIncreaseCommand != null && (word == 'на' || word == 'в')) {
          flushNumber();
          if (isIncreaseCommand!) {
            tokens.add(word == 'на' ? '+' : '*');
          } else {
            tokens.add(word == 'на' ? '-' : '/');
          }
          isIncreaseCommand = null;
          continue;
        }

        if (i + 1 < words.length) {
          String nextWord = words[i + 1];
          if ((word == 'умножить' && nextWord == 'на') ||
              (word == 'разделить' && nextWord == 'на') ||
              (word == 'поделить' && nextWord == 'на')) {
            flushNumber();
            tokens.add(word == 'умножить' ? '*' : '/');
            i++;
            continue;
          }
        }

        String? opSymbol;
        if (['+', 'плюс', 'прибавить', 'сложить', 'добавить', 'и'].contains(word)) {
          opSymbol = '+';
        } else if (['-', 'минус', 'вычесть', 'отнять', 'без'].contains(word)) {
          opSymbol = '-';
        } else if (['*', 'умножить', 'помножить'].contains(word)) {
          opSymbol = '*';
        } else if (['/', 'разделить', 'делить', 'поделить'].contains(word)) {
          opSymbol = '/';
        }

        if (opSymbol != null) {
          flushNumber();
          tokens.add(opSymbol);
        } else {
          num? numVal = NumberVocabulary.parseWord(word);
          if (numVal != null || double.tryParse(word) != null) {
            currentNumWords.add(word);
          }
        }
      }
      flushNumber();

      if (tokens.isEmpty) {
        return CalculationResult(displayExpression: text, result: 'Не удалось распознать', success: false);
      }

      List<dynamic> reduced = [];
      for (int i = 0; i < tokens.length; i++) {
        if (tokens[i] == '*' || tokens[i] == '/') {
          if (reduced.isEmpty) reduced.add(0.0);
          var prev = reduced.removeLast();
          var op = tokens[i];
          var next = (i + 1 < tokens.length) ? tokens[i + 1] : 0;
          i++;

          double pVal = (prev is num) ? prev.toDouble() : 0.0;
          double nVal = (next is num) ? next.toDouble() : 0.0;
          double res = (op == '*') ? (pVal * nVal) : (nVal != 0 ? pVal / nVal : 0.0);
          reduced.add(res);
        } else {
          reduced.add(tokens[i]);
        }
      }

      if (reduced.isEmpty) {
        return CalculationResult(displayExpression: text, result: 'Ошибка расчета', success: false);
      }

      double finalResult = (reduced[0] is num) ? (reduced[0] as num).toDouble() : 0.0;
      for (int i = 1; i < reduced.length; i += 2) {
        if (i + 1 >= reduced.length) break;
        String op = reduced[i].toString();
        double nextVal = (reduced[i + 1] is num) ? (reduced[i + 1] as num).toDouble() : 0.0;
        if (op == '+') finalResult += nextVal;
        if (op == '-') finalResult -= nextVal;
      }

      String displayExpr = tokens.join(' ');
      String resStr = finalResult == finalResult.roundToDouble()
          ? finalResult.toInt().toString()
          : finalResult.toString();

      return CalculationResult(
        displayExpression: displayExpr.isNotEmpty ? displayExpr : text,
        result: resStr,
        success: true,
      );
    } catch (e) {
      return CalculationResult(displayExpression: text, result: 'Ошибка расчета', success: false);
    }
  }
}