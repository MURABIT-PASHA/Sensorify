import 'package:sensorify/models/message_model.dart';
import 'package:web_socket_client/web_socket_client.dart';

class SocketHelper {
  WebSocket socket = WebSocket(Uri.parse('http://localhost:8080'));

  void sendMessage(MessageModel messageModel) {
    socket.send('ping');
  }

  getStream() {
    socket.messages.listen((message) {
      // Handle incoming messages.
    });
  }

  Future<bool> connect({required String url}) async {
    socket = WebSocket(Uri.parse(url));
    if (socket.connection.state is Connected) {
      return true;
    } else {
      return false;
    }
  }

  void closeConnection() {
    if (socket.connection.state is Connected) {
      socket.close();
    }
  }
}
