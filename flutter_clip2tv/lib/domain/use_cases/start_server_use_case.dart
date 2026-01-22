import '../repositories/server_repository.dart';

class StartServerUseCase {
  final ServerRepository repository;

  StartServerUseCase(this.repository);

  Future<void> execute(int port) async {
    await repository.startServer(port);
  }
}
