import 'dart:async';
import 'dart:io';
import 'package:clipboard/clipboard.dart';
import '../../domain/entities/server_status.dart';
import '../../domain/repositories/server_repository.dart';
import '../data_sources/http_server_data_source.dart';
import '../data_sources/network_data_source.dart';

class ServerRepositoryImpl implements ServerRepository {
  final HttpServerDataSource httpServerDataSource;
  final NetworkDataSource networkDataSource;
  final _statusController = StreamController<ServerStatus>.broadcast();
  ServerStatus _currentStatus = const ServerStatus(isRunning: false);

  ServerRepositoryImpl({
    required this.httpServerDataSource,
    required this.networkDataSource,
  }) {
    httpServerDataSource.onTextReceived = _handleTextReceived;
  }

  @override
  Future<void> startServer(int port) async {
    try {
      final ipAddress = await getLocalIpAddress();
      if (ipAddress == null) {
        throw Exception('Не удалось получить IP адрес');
      }

      await httpServerDataSource.startServer(port);
      
      final url = 'http://$ipAddress:$port';
      _updateStatus(
        isRunning: true,
        ipAddress: ipAddress,
        port: port,
        url: url,
      );
    } catch (e) {
      _updateStatus(isRunning: false);
      rethrow;
    }
  }

  @override
  Future<void> stopServer() async {
    await httpServerDataSource.stopServer();
    _updateStatus(isRunning: false);
  }

  @override
  Stream<ServerStatus> get serverStatus => _statusController.stream;

  @override
  Future<String?> getLocalIpAddress() async {
    return await networkDataSource.getLocalIpAddress();
  }

  @override
  Future<void> copyToClipboard(String text) async {
    await FlutterClipboard.copy(text);
  }

  void _updateStatus({
    required bool isRunning,
    String? ipAddress,
    int? port,
    String? url,
  }) {
    _currentStatus = _currentStatus.copyWith(
      isRunning: isRunning,
      ipAddress: ipAddress,
      port: port,
      url: url,
    );
    _statusController.add(_currentStatus);
  }

  Future<void> _handleTextReceived(String text) async {
    await copyToClipboard(text);
  }

  void dispose() {
    _statusController.close();
  }
}
