import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_models.dart';
import 'chat_room_screen.dart';
import 'nickname_screen.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  String? _nickname;
  List<ChatRoom> _rooms = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadDummyRooms();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nickname = prefs.getString('nickname');
    });
  }

  void _loadDummyRooms() {
    setState(() {
      _rooms = [
        ChatRoom(id: '1', name: '일반 채팅', userCount: 5),
        ChatRoom(id: '2', name: '게임 이야기', userCount: 3),
        ChatRoom(id: '3', name: '개발자 모임', userCount: 8),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅방 목록'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadDummyRooms();
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: const Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('로그아웃'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_nickname != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
              ),
              child: Text(
                '환영합니다, $_nickname님!',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: _rooms.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '사용 가능한 채팅방이 없습니다.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _rooms.length,
                    itemBuilder: (context, index) {
                      final room = _rooms[index];
                      return _buildRoomCard(context, room);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, ChatRoom room) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple,
          child: Text(
            room.name.substring(0, 1),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          room.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('참여자: ${room.userCount}명'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _joinRoom(context, room),
      ),
    );
  }

  Future<void> _joinRoom(BuildContext context, ChatRoom room) async {
    // 서버 연결 없이 바로 채팅방으로 이동
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => ChatRoomScreen(room: room)));
  }

  Future<void> _logout() async {
    // 저장된 닉네임과 서버 URL 삭제
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('nickname');
    await prefs.remove('serverUrl');

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const NicknameScreen()),
        (route) => false,
      );
    }
  }
}
