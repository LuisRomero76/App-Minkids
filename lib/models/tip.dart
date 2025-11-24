class TipModel {
  final String id;
  final String title;
  final String content;
  final String category;
  final String targetRole; // 'padre' o 'hijo'
  final String? iconName; // Nombre del icono
  final String? colorName; // Color asociado

  TipModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.targetRole,
    this.iconName,
    this.colorName,
  });
}
