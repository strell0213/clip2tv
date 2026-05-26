class ServerStatus {
  final bool isRunning;
  final String? ipAddress;
  final int? port;
  final String? url;
  final DateTime? lastCopiedAt;

  const ServerStatus({
    required this.isRunning,
    this.ipAddress,
    this.port,
    this.url,
    this.lastCopiedAt,
  });

  ServerStatus copyWith({
    bool? isRunning,
    String? ipAddress,
    int? port,
    String? url,
    DateTime? lastCopiedAt,
  }) {
    return ServerStatus(
      isRunning: isRunning ?? this.isRunning,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      url: url ?? this.url,
      lastCopiedAt: lastCopiedAt ?? this.lastCopiedAt,
    );
  }
}
