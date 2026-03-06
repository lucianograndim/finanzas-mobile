const List<String> months = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];

const List<Map<String, String>> incomeSources = [
  {'value': 'sueldo', 'label': 'Sueldo'},
  {'value': 'venta', 'label': 'Venta'},
  {'value': 'trabajo_extra', 'label': 'Trabajo Extra'},
  {'value': 'otro', 'label': 'Otro'},
];

String getSourceLabel(String? value) {
  if (value == null) return '';
  final source = incomeSources.where((s) => s['value'] == value).firstOrNull;
  return source?['label'] ?? value;
}
