import 'package:ai_chat/models/chat_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/signalr_client.dart';

class ChatClient {
  HubConnection? _connection;
  final String _baseUrl;

  // 메시지 수신 콜백
  Function(ChatMessage)? onMessageReceived;

  ChatClient({required String baseUrl}) : _baseUrl = baseUrl;

  /// SignalR 연결 초기화
  Future<void> initialize() async {
    _connection = HubConnectionBuilder().withUrl('$_baseUrl/chathub').build();

    // 연결 전에 메시지 핸들러 등록
    _setupMessageHandlers();
  }

  /// 메시지 핸들러 설정
  void _setupMessageHandlers() {
    // ReceiveMessage 핸들러 등록
    _connection!.on('ReceiveMessage', (List<Object?>? arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final messageData = arguments[0] as Map<String, dynamic>;
        final userName = messageData['userName'] as String;
        final message = messageData['message'] as String;
        final chatUid = messageData['chatUid'] as String;

        // ChatMessage 객체 생성
        final chatMessage = ChatMessage(
          id: '', // 클라이언트에서 생성하는 임시 ID
          userName: userName,
          message: message,
          timestamp: DateTime.now(),
          roomId: chatUid, // ChatUid를 roomId로 매핑
        );

        // 등록된 콜백 함수에 ChatMessage 객체 전달
        onMessageReceived?.call(chatMessage);
      }
    });
  }

  /// 서버에 연결
  Future<bool> connect() async {
    if (_connection == null) {
      await initialize();
    }

    try {
      await _connection!.start();
      print('SignalR 연결 성공');
      return _connection!.state == HubConnectionState.Connected;
    } catch (e) {
      print('연결 실패: $e');
      return false;
    }
  }

  Future<bool> sendMessage(ChatMessage message) async {
    if (_connection?.state != HubConnectionState.Connected) {
      print('SignalR 연결이 되지 않았습니다.');
      return false;
    }

    try {
      // C# SendMessageToGroup(string groupName, string user, string message)에 맞게 전달
      await _connection!.invoke(
        'SendMessageToGroup',
        args: [
          message.roomId, // groupName (chatUid)
          message.userName, // user
          message.message, // message
        ],
      );

      print('메시지 전송 성공: ${message.userName} - ${message.message}');
      return true;
    } catch (e) {
      print('메시지 전송 실패: $e');
      return false;
    }
  }

  /// 서버 연결 해제
  Future<void> disconnect() async {
    if (_connection != null) {
      await _connection!.stop();
      print('SignalR 연결 해제');
    }
  }

  /// 연결 상태 확인
  bool get isConnected => _connection?.state == HubConnectionState.Connected;

  /// 현재 연결 상태 반환
  HubConnectionState? get currentState => _connection?.state;

  /// 채팅방 그룹 입장
  Future<bool> joinGroup(String chatUid) async {
    if (_connection?.state != HubConnectionState.Connected) {
      print('SignalR 연결이 되지 않았습니다.');
      return false;
    }

    try {
      await _connection!.invoke('JoinGroup', args: [chatUid]);
      print('채팅방 그룹 입장 성공: $chatUid');
      return true;
    } catch (e) {
      print('채팅방 그룹 입장 실패: $e');
      return false;
    }
  }

  /// 리소스 정리
  void dispose() {
    disconnect();
  }
}
