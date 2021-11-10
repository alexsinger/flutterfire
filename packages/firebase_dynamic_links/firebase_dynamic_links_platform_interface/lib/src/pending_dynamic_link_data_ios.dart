/// Provides iOS specific data from received dynamic link.
class PendingDynamicLinkDataIOS {
  const PendingDynamicLinkDataIOS({this.minimumVersion});

  /// The minimum version of your app that can open the link.
  ///
  /// It is app developer's responsibility to open AppStore when received link
  /// declares higher [minimumVersion] than currently installed.
  final String? minimumVersion;

  /// Returns the current instance as a [Map].
  Map<String, dynamic> asMap() => <String, dynamic>{
        'minimumVersion': minimumVersion,
      };

  @override
  String toString() {
    return '$PendingDynamicLinkDataIOS($asMap)';
  }
}
