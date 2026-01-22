import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/server_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const int _defaultPort = 8080;
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ServerProvider>();
      if (!provider.status.isRunning) {
        _startServer();
      }
    });
  }

  Future<void> _startServer() async {
    setState(() {
      _isStarting = true;
    });

    final provider = context.read<ServerProvider>();
    await provider.startServer(_defaultPort);

    setState(() {
      _isStarting = false;
    });
  }

  Future<void> _stopServer() async {
    final provider = context.read<ServerProvider>();
    await provider.stopServer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity, // важно!
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<ServerProvider>(
            builder: (context, provider, child) {
              final status = provider.status;
              final errorMessage = provider.errorMessage;

              if (_isStarting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Запуск сервера...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (errorMessage != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 64,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          errorMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        Focus(
                          autofocus: true,
                          child: ElevatedButton(
                            onPressed: _startServer,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 16,
                              ),
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF667eea),
                            ),
                            child: const Text(
                              'Попробовать снова',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (!status.isRunning) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.tv,
                        color: Colors.white,
                        size: 80,
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Сервер не запущен',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Focus(
                        autofocus: true,
                        child: ElevatedButton(
                          onPressed: _startServer,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 20,
                            ),
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF667eea),
                          ),
                          child: const Text(
                            'Запустить сервер',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16), // внутренние отступы
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                            '📺 Clip2TV',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 10),
                        const Text(
                          'Сервер запущен',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),


                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              if (status.url != null)
                                QrImageView(
                                  data: status.url!,
                                  version: QrVersions.auto,
                                  size: 250.0,
                                  backgroundColor: Colors.white,
                                ),
                              const SizedBox(height: 24),
                              Column(
                                children: [
                                  if (status.url != null)
                                    SelectableText(
                                      status.url!,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF667eea),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  const SizedBox(height: 16),
                                  if (status.ipAddress != null)
                                    Text(
                                      'IP: ${status.ipAddress}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  if (status.port != null)
                                    Text(
                                      'Порт: ${status.port}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 50,),
                    Column(
                      children: [
                        const SizedBox(height: 50),
                        const Text(
                          'Отсканируйте QR-код с телефона',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Focus(
                          autofocus: true,
                          child: ElevatedButton(
                            onPressed: _stopServer,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 20,
                              ),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text(
                              'Остановить сервер',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
