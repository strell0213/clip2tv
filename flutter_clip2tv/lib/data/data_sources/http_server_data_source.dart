import 'dart:async';
import 'dart:convert';
import 'dart:io';

class HttpServerDataSource {
  HttpServer? _server;
  Function(String)? onTextReceived;

  Future<void> startServer(int port) async {
    if (_server != null) {
      await stopServer();
    }

    _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    
    _server!.listen((request) async {
      await _handleRequest(request);
    });
  }

  Future<void> stopServer() async {
    await _server?.close(force: true);
    _server = null;
  }

  Future<void> _handleRequest(HttpRequest request) async {
    try {
      if (request.method == 'GET' && request.uri.path == '/') {
        await _handleGetRequest(request);
      } else if (request.method == 'POST' && request.uri.path == '/submit') {
        await _handlePostRequest(request);
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..close();
      }
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..close();
    }
  }

  Future<void> _handleGetRequest(HttpRequest request) async {
    final html = _generateHtml();
    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.html
      ..write(html)
      ..close();
  }

  Future<void> _handlePostRequest(HttpRequest request) async {
    try {
      final contentType = request.headers.contentType;
      String body = '';
      
      if (contentType != null && contentType.mimeType == 'application/x-www-form-urlencoded') {
        final bodyBytes = await request.toList();
        body = utf8.decode(bodyBytes.expand((x) => x).toList());
      } else {
        await request.toList();
      }
      
      final params = Uri.splitQueryString(body);
      final text = params['text'] ?? '';
      final decodedText = text.isNotEmpty ? Uri.decodeComponent(text) : '';
      
      if (decodedText.isNotEmpty && onTextReceived != null) {
        onTextReceived!(decodedText);
      }

      final responseHtml = _generateResponseHtml(decodedText.isNotEmpty);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.html
        ..write(responseHtml)
        ..close();
    } catch (e) {
      final responseHtml = _generateResponseHtml(false);
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.html
        ..write(responseHtml)
        ..close();
    }
  }

  String _generateHtml() {
    return '''
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Clip2TV</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .container {
            background: white;
            border-radius: 20px;
            padding: 40px;
            max-width: 500px;
            width: 100%;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }
        h1 {
            color: #333;
            margin-bottom: 30px;
            text-align: center;
            font-size: 28px;
        }
        .form-group {
            margin-bottom: 25px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            color: #555;
            font-weight: 500;
        }
        input[type="text"] {
            width: 100%;
            padding: 15px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            font-size: 16px;
            transition: border-color 0.3s;
        }
        input[type="text"]:focus {
            outline: none;
            border-color: #667eea;
        }
        button {
            width: 100%;
            padding: 15px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 18px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        button:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
        button:active {
            transform: translateY(0);
        }
        .message {
            margin-top: 20px;
            padding: 15px;
            border-radius: 10px;
            text-align: center;
            font-weight: 500;
        }
        .success {
            background: #d4edda;
            color: #155724;
        }
        .error {
            background: #f8d7da;
            color: #721c24;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📺 Clip2TV</h1>
        <form id="textForm" method="POST" action="/submit">
            <div class="form-group">
                <label for="text">Введите текст:</label>
                <input type="text" id="text" name="text" required autofocus>
            </div>
            <button type="submit">Отправить</button>
        </form>
        <div id="message"></div>
    </div>
    <script>
        document.getElementById('textForm').addEventListener('submit', function(e) {
            e.preventDefault();
            const formData = new FormData(this);
            const messageDiv = document.getElementById('message');
            
            fetch('/submit', {
                method: 'POST',
                body: new URLSearchParams(formData)
            })
            .then(response => response.text())
            .then(html => {
                document.body.innerHTML = html;
            })
            .catch(error => {
                messageDiv.className = 'message error';
                messageDiv.textContent = 'Ошибка отправки: ' + error;
            });
        });
    </script>
</body>
</html>
''';
  }

  String _generateResponseHtml(bool success) {
    if (success) {
      return '''
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Успешно</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .container {
            background: white;
            border-radius: 20px;
            padding: 40px;
            max-width: 500px;
            width: 100%;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            text-align: center;
        }
        h1 {
            color: #155724;
            margin-bottom: 20px;
            font-size: 28px;
        }
        .message {
            background: #d4edda;
            color: #155724;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            font-size: 18px;
        }
        button {
            padding: 15px 30px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>✅ Успешно!</h1>
        <div class="message">Текст скопирован в буфер обмена телевизора</div>
        <button onclick="window.location.href='/'">Отправить еще</button>
    </div>
</body>
</html>
''';
    } else {
      return '''
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ошибка</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .container {
            background: white;
            border-radius: 20px;
            padding: 40px;
            max-width: 500px;
            width: 100%;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            text-align: center;
        }
        h1 {
            color: #721c24;
            margin-bottom: 20px;
            font-size: 28px;
        }
        .message {
            background: #f8d7da;
            color: #721c24;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            font-size: 18px;
        }
        button {
            padding: 15px 30px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>❌ Ошибка</h1>
        <div class="message">Текст не был отправлен</div>
        <button onclick="window.location.href='/'">Попробовать снова</button>
    </div>
</body>
</html>
''';
    }
  }
}
