class RemoteSettings {
  final bool adsEnabled;

  RemoteSettings({
    required this.adsEnabled,
  });

  RemoteSettings.fromMap(Map<String, dynamic> json)
      : adsEnabled = json['ads_enabled'] == "true";
}
