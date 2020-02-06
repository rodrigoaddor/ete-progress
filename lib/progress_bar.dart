String generateProgressBar(double percent, {int length = 16, String filled = '█', String empty = '░'}) =>
    filled * (percent * length).floor() + empty * (length - percent * length).floor();
