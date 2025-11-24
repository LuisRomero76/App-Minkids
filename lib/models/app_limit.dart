import 'package:minkids/models/application.dart';

class AppLimitModel {
  final int id;
  final int childId;
  final int appId;
  final int dailyLimitMinutes;
  final bool enabled;
  final ApplicationModel? application;

  AppLimitModel({
    required this.id,
    required this.childId,
    required this.appId,
    required this.dailyLimitMinutes,
    required this.enabled,
    this.application,
  });

  factory AppLimitModel.fromJson(Map<String, dynamic> json) {
    return AppLimitModel(
      id: json['id'] ?? 0,
      childId: json['child_id'] ?? 0,
      appId: json['app_id'] ?? 0,
      dailyLimitMinutes: json['daily_limit_minutes'] ?? 60,
      enabled: json['enabled'] ?? true,
      application: json['application'] != null
          ? ApplicationModel.fromJson(json['application'])
          : null,
    );
  }
}
