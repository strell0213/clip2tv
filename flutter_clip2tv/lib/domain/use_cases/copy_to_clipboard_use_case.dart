import '../repositories/server_repository.dart';

class CopyToClipboardUseCase {
  final ServerRepository repository;

  CopyToClipboardUseCase(this.repository);

  Future<void> execute(String text) async {
    await repository.copyToClipboard(text);
  }
}
