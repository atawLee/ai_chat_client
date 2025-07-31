import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/chat_provider.dart';
import '../models/chat_models.dart';
import 'chat_room_screen.dart';
import 'nickname_screen.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.loadRooms();
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
              final chatProvider = Provider.of<ChatProvider>(
                context,
                listen: false,
              );
              chatProvider.loadRooms();
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
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (!chatProvider.isConnected) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('서버에 연결 중...'),
                ],
              ),
            );
          }

          if (chatProvider.rooms.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '사용 가능한 채팅방이 없습니다.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              if (chatProvider.nickname != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                  ),
                  child: Text(
                    '환영합니다, ${chatProvider.nickname}님!',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: chatProvider.rooms.length,
                  itemBuilder: (context, index) {
                    final room = chatProvider.rooms[index];
                    return _buildRoomCard(context, room, chatProvider);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRoomCard(
    BuildContext context,
    ChatRoom room,
    ChatProvider chatProvider,
  ) {
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
        onTap: () => _joinRoom(context, room, chatProvider),
      ),
    );
  }

  Future<void> _joinRoom(
    BuildContext context,
    ChatRoom room,
    ChatProvider chatProvider,
  ) async {
    try {
      await chatProvider.joinRoom(room.id);
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ChatRoomScreen(room: room)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('방 입장 실패: $e')));
      }
    }
  }

  Future<void> _logout() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // SignalR 연결 해제
    await chatProvider.disconnect();

    // 저장된 닉네임 삭제
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
