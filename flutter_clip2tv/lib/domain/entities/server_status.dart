class ServerStatus {
  final bool isRunning;
  final String? ipAddress;
  final int? port;
  final String? url;

  const ServerStatus({
    required this.isRunning,
    this.ipAddress,
    this.port,
    this.url,
  });

  ServerStatus copyWith({
    bool? isRunning,
    String? ipAddress,
    int? port,
    String? url,
  }) {
    return ServerStatus(
      isRunning: isRunning ?? this.isRunning,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      url: url ?? this.url,
    );
  }
}
