class NumberVocabulary {
  static const Map<String, String> operations = {
    'плюс': '+',
    'прибавить': '+',
    'сложить': '+',
    'и': '+',
    'добавить': '+',
    'сумма': '+',
    'увеличить': '+',

    'минус': '-',
    'вычесть': '-',
    'отнять': '-',
    'без': '-',
    'разность': '-',
    'уменшить': '-',

    'увеличь в': '*',
    'умножить на': '*',
    'умножить': '*',
    'на': '*',
    'помножить': '*',
    'произведение': '*',

    'разделить на': '/',
    'разделить': '/',
    'делить': '/',
    'поделить': '/',
    'частное': '/',
  };

  static num? parseWord(String word) {
    if (word == 'пол') return 0.5;
    if ((word == 'полторы') || word.startsWith('полтора')) return 1.5;
    if (word == 'полтораста') return 150;
    if (word == 'полсотни') return 50;
    if (word == 'полтысячи') return 500;
    if (word == 'полмиллиона') return 500000;

    if (word.startsWith('миллиард')) return 1000000000;
    if (word.startsWith('миллион')) return 1000000;
    if (word.startsWith('тысяч')) return 1000;
    if (word.startsWith('сотн')) return 100;

    if (word.startsWith('девятьсот') || word.startsWith('девятисот')) return 900;
    if (word.startsWith('восемьсот') || word.startsWith('восьмисот')) return 800;
    if (word.startsWith('семьсот') || word.startsWith('семисот')) return 700;
    if (word.startsWith('шестьсот') || word.startsWith('шестисот')) return 600;
    if (word.startsWith('пятьсот') || word.startsWith('пятисот')) return 500;
    if (word.startsWith('четырест') || word.startsWith('четырехсот') || word.startsWith('трёхсот') || word.startsWith('трехсот')) {
      return word.startsWith('четыр') ? 400 : 300;
    }
    if (word.startsWith('двест') || word.startsWith('двухсот')) return 200;
    if (word.startsWith('сто') || word.startsWith('ста')) return 100;

    if (word.startsWith('девяност')) return 90;
    if (word.startsWith('восемьдесят') || word.startsWith('восьмидесят') || word.startsWith('восемдесят')) return 80;
    if (word.startsWith('семьдесят') || word.startsWith('семидесят') || word.startsWith('семдесят')) return 70;
    if (word.startsWith('шестьдесят') || word.startsWith('шестидесят') || word.startsWith('шестдесят')) return 60;
    if (word.startsWith('пятьдесят') || word.startsWith('пятидесят') || word.startsWith('пятдесят')) return 50;
    if (word.startsWith('сорок')) return 40;
    if (word.startsWith('тридцат')) return 30;
    if (word.startsWith('двадцат')) return 20;

    if (word.startsWith('одиннадцать')) return 11;
    if (word.startsWith('двенадцать')) return 12;
    if (word.startsWith('тринадцать')) return 13;
    if (word.startsWith('четырнадцать')) return 14;
    if (word.startsWith('пятнадцать')) return 15;
    if (word.startsWith('шестнадцать')) return 16;
    if (word.startsWith('семнадцать')) return 17;
    if (word.startsWith('восемнадцать')) return 18;
    if (word.startsWith('девятнадцать')) return 19;

    if (word.startsWith('десят')) return 10;
    if (word.startsWith('девят')) return 9;
    if (word.startsWith('восем') || word.startsWith('восьм')) return 8;
    if (word.startsWith('сем')) return 7;
    if (word.startsWith('шест')) return 6;
    if (word.startsWith('пят')) return 5;
    if (word.startsWith('четыр')) return 4;
    if (word.startsWith('трех') || word.startsWith('трёх') || word.startsWith('трем') || word.startsWith('трём') || word.startsWith('тремя') || word.startsWith('три')) return 3;
    if (word.startsWith('дв')) return 2;
    if (word.startsWith('одн') || word.startsWith('один') || word.startsWith('единиц')) return 1;
    if (word.startsWith('нол') || word.startsWith('нул')) return 0;

    return num.tryParse(word);
  }
}