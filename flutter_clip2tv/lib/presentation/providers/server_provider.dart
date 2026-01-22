import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/server_status.dart';
import '../../domain/repositories/server_repository.dart';
import '../../domain/use_cases/start_server_use_case.dart';
import '../../domain/use_cases/stop_server_use_case.dart';

class ServerProvider extends ChangeNotifier {
  final StartServerUseCase startServerUseCase;
  final StopServerUseCase stopServerUseCase;
  final ServerRepository repository;

  ServerStatus _status = const ServerStatus(isRunning: false);
  StreamSubscription<ServerStatus>? _statusSubscription;
  String? _errorMessage;

  ServerProvider({
    required this.startServerUseCase,
    required this.stopServerUseCase,
    required this.repository,
  }) {
    _statusSubscription = repository.serverStatus.listen((status) {
      _status = status;
      _errorMessage = null;
      notifyListeners();
    });
  }

  ServerStatus get status => _status;
  String? get errorMessage => _errorMessage;

  Future<void> startServer(int port) async {
    try {
      _errorMessage = null;
      notifyListeners();
      await startServerUseCase.execute(port);
    } catch (e) {
      _errorMessage = 'Ошибка запуска сервера: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> stopServer() async {
    try {
      _errorMessage = null;
      notifyListeners();
      await stopServerUseCase.execute();
    } catch (e) {
      _errorMessage = 'Ошибка остановки сервера: ${e.toString()}';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }
}
