class ActionModel {
  final String id;
  final String label;

  ActionModel({required this.id, required this.label});

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
      };

  factory ActionModel.fromJson(Map<String, dynamic> json) {
    return ActionModel(
      id: json['id'],
      label: json['label'],
    );
  }
}