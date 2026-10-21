String formatCLP(num amount) {
  final isNegative = amount < 0;
  final abs = amount.abs().toInt().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < abs.length; i++) {
    if (i > 0 && (abs.length - i) % 3 == 0) buffer.write('.');
    buffer.write(abs[i]);
  }
  return '${isNegative ? '-' : ''}\$$buffer';
}
