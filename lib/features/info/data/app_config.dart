import 'dart:convert';

/// Non-stream configuration from `GET /api/v1/app-config`.
class AppConfig {
  const AppConfig({
    this.aboutText,
    this.websiteUrl,
    this.facebookUrl,
    this.instagramUrl,
    this.youtubeUrl,
    this.tiktokUrl,
    this.contactPhone,
    this.contactEmail,
    this.privacyPolicyUrl,
    this.androidStoreUrl,
    this.minSupportedVersion = '1.0.0',
  });

  final String? aboutText;
  final String? websiteUrl;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? youtubeUrl;
  final String? tiktokUrl;
  final String? contactPhone;
  final String? contactEmail;
  final String? privacyPolicyUrl;
  final String? androidStoreUrl;
  final String minSupportedVersion;

  factory AppConfig.fromJson(Map<String, dynamic> json) => AppConfig(
    aboutText: json['about_text'] as String?,
    websiteUrl: json['website_url'] as String?,
    facebookUrl: json['facebook_url'] as String?,
    instagramUrl: json['instagram_url'] as String?,
    youtubeUrl: json['youtube_url'] as String?,
    tiktokUrl: json['tiktok_url'] as String?,
    contactPhone: json['contact_phone'] as String?,
    contactEmail: json['contact_email'] as String?,
    privacyPolicyUrl: json['privacy_policy_url'] as String?,
    androidStoreUrl: json['android_store_url'] as String?,
    minSupportedVersion:
        (json['min_supported_version'] as String?) ?? '1.0.0',
  );

  Map<String, dynamic> toJson() => {
    'about_text': aboutText,
    'website_url': websiteUrl,
    'facebook_url': facebookUrl,
    'instagram_url': instagramUrl,
    'youtube_url': youtubeUrl,
    'tiktok_url': tiktokUrl,
    'contact_phone': contactPhone,
    'contact_email': contactEmail,
    'privacy_policy_url': privacyPolicyUrl,
    'android_store_url': androidStoreUrl,
    'min_supported_version': minSupportedVersion,
  };

  String encode() => jsonEncode(toJson());

  static AppConfig decode(String raw) =>
      AppConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
