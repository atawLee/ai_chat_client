import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../models/chat_models.dart';

class ChatProvider extends ChangeNotifier {
  HubConnection? _hubConnection;
  List<ChatRoom> _rooms = [];
  final List<ChatMessage> _messages = [];
  String? _currentRoomId;
  String? _nickname;
  bool _isConnected = false;

  List<ChatRoom> get rooms => _rooms;
  List<ChatMessage> get messages => _messages;
  String? get currentRoomId => _currentRoomId;
  String? get nickname => _nickname;
  bool get isConnected => _isConnected;

  // SignalR 연결 설정
  Future<void> initializeConnection(String serverUrl, String nickname) async {
    _nickname = nickname;

    _hubConnection = HubConnectionBuilder().withUrl(serverUrl).build();

    // 연결 상태 변경 이벤트
    _hubConnection!.onclose(({error}) {
      _isConnected = false;
      notifyListeners();
    });

    // 메시지 수신 이벤트
    _hubConnection!.on('ReceiveMessage', (List<Object?>? parameters) {
      if (parameters != null && parameters.length >= 3) {
        final message = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          roomId: _currentRoomId ?? '',
          userName: parameters[0] as String,
          message: parameters[1] as String,
          timestamp: DateTime.now(),
        );
        _messages.add(message);
        notifyListeners();
      }
    });

    // 방 목록 업데이트 이벤트
    _hubConnection!.on('UpdateRoomList', (List<Object?>? parameters) {
      if (parameters != null && parameters.isNotEmpty) {
        // 방 목록 업데이트 로직
        loadRooms();
      }
    });

    try {
      await _hubConnection!.start();
      _isConnected = true;
      notifyListeners();
    } catch (e) {
      debugPrint('SignalR 연결 실패: $e');
    }
  }

  // 서버 연결 해제
  Future<void> disconnect() async {
    if (_hubConnection != null) {
      await _hubConnection!.stop();
      _hubConnection = null;
      _isConnected = false;
      notifyListeners();
    }
  }

  // 방 목록 로드
  Future<void> loadRooms() async {
    try {
      // 실제로는 서버에서 방 목록을 가져와야 하지만,
      // 여기서는 더미 데이터를 사용합니다.
      _rooms = [
        ChatRoom(id: '1', name: '일반 채팅', userCount: 5),
        ChatRoom(id: '2', name: '게임 이야기', userCount: 3),
        ChatRoom(id: '3', name: '개발자 모임', userCount: 8),
      ];
      notifyListeners();
    } catch (e) {
      debugPrint('방 목록 로드 실패: $e');
    }
  }

  // 방 입장
  Future<void> joinRoom(String roomId) async {
    if (_hubConnection != null && _isConnected && _nickname != null) {
      try {
        await _hubConnection!.invoke('JoinRoom', args: [roomId, _nickname!]);
        _currentRoomId = roomId;
        _messages.clear();
        notifyListeners();
      } catch (e) {
        debugPrint('방 입장 실패: $e');
      }
    }
  }

  // 방 나가기
  Future<void> leaveRoom() async {
    if (_hubConnection != null &&
        _isConnected &&
        _currentRoomId != null &&
        _nickname != null) {
      try {
        await _hubConnection!.invoke(
          'LeaveRoom',
          args: [_currentRoomId!, _nickname!],
        );
        _currentRoomId = null;
        _messages.clear();
        notifyListeners();
      } catch (e) {
        debugPrint('방 나가기 실패: $e');
      }
    }
  }

  // 메시지 전송
  Future<void> sendMessage(String message) async {
    if (_hubConnection != null &&
        _isConnected &&
        _currentRoomId != null &&
        _nickname != null) {
      try {
        await _hubConnection!.invoke(
          'SendMessage',
          args: [_currentRoomId!, _nickname!, message],
        );
      } catch (e) {
        debugPrint('메시지 전송 실패: $e');
      }
    }
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
