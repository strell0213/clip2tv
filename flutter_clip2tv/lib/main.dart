import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/data_sources/http_server_data_source.dart';
import 'data/data_sources/network_data_source.dart';
import 'data/repositories/server_repository_impl.dart';
import 'domain/use_cases/start_server_use_case.dart';
import 'domain/use_cases/stop_server_use_case.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/providers/server_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Инициализация зависимостей
    final networkDataSource = NetworkDataSource();
    final httpServerDataSource = HttpServerDataSource();
    final serverRepository = ServerRepositoryImpl(
      httpServerDataSource: httpServerDataSource,
      networkDataSource: networkDataSource,
    );
    final startServerUseCase = StartServerUseCase(serverRepository);
    final stopServerUseCase = StopServerUseCase(serverRepository);

    return MaterialApp(
      title: 'Clip2TV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667eea),
        ),
      ),
      home: ChangeNotifierProvider(
        create: (_) => ServerProvider(
          startServerUseCase: startServerUseCase,
          stopServerUseCase: stopServerUseCase,
          repository: serverRepository,
        ),
        child: const HomePage(),
      ),
    );
  }
}
