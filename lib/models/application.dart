class ApplicationModel {
  final int appId;
  final String name;
  final String packageName;
  final String? iconUrl;

  ApplicationModel({
    required this.appId,
    required this.name,
    required this.packageName,
    this.iconUrl,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      appId: json['app_id'] ?? json['id'] ?? 0,
      name: json['name'] ?? '',
      packageName: json['package_name'] ?? '',
      iconUrl: json['icon_url'],
    );
  }
}
