class ChatRoom {
  final String id;
  final String name;
  final int userCount;

  ChatRoom({required this.id, required this.name, required this.userCount});

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      name: json['name'],
      userCount: json['userCount'] ?? 0,
    );
  }
}

class ChatMessage {
  final String id;
  final String roomId;
  final String userName;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.userName,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      roomId: json['roomId'] ?? '',
      userName: json['userName'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}
