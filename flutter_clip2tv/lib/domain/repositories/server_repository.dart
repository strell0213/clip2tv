import '../entities/server_status.dart';

abstract class ServerRepository {
  Future<void> startServer(int port);
  Future<void> stopServer();
  Stream<ServerStatus> get serverStatus;
  Future<String?> getLocalIpAddress();
  Future<void> copyToClipboard(String text);
}
