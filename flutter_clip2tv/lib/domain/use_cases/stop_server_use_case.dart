import '../repositories/server_repository.dart';

class StopServerUseCase {
  final ServerRepository repository;

  StopServerUseCase(this.repository);

  Future<void> execute() async {
    await repository.stopServer();
  }
}
