class TrafficStats {
  final double downloadKbps;
  final double uploadKbps;
  final int pingMs;
  final double sessionDownloadMb;
  final double sessionUploadMb;
  final List<double> pingHistory;

  const TrafficStats({
    this.downloadKbps = 262.9,
    this.uploadKbps = 200.2,
    this.pingMs = 230,
    this.sessionDownloadMb = 449.4,
    this.sessionUploadMb = 411.9,
    this.pingHistory = const [210, 240, 220, 230, 225, 235, 230, 228, 232, 230],
  });

  TrafficStats copyWith({
    double? downloadKbps,
    double? uploadKbps,
    int? pingMs,
    double? sessionDownloadMb,
    double? sessionUploadMb,
    List<double>? pingHistory,
  }) {
    return TrafficStats(
      downloadKbps: downloadKbps ?? this.downloadKbps,
      uploadKbps: uploadKbps ?? this.uploadKbps,
      pingMs: pingMs ?? this.pingMs,
      sessionDownloadMb: sessionDownloadMb ?? this.sessionDownloadMb,
      sessionUploadMb: sessionUploadMb ?? this.sessionUploadMb,
      pingHistory: pingHistory ?? this.pingHistory,
    );
  }
}
