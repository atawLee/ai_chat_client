import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/chat_provider.dart';
import 'room_list_screen.dart';

class NicknameScreen extends StatefulWidget {
  const NicknameScreen({super.key});

  @override
  State<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _serverUrlController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 기본 서버 URL 설정 (실제 SignalR 서버 URL로 변경하세요)
    _serverUrlController.text = 'http://localhost:5000/chathub';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 30),
            const Text(
              'AI 채팅에 오신 것을 환영합니다!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _serverUrlController,
              decoration: const InputDecoration(
                labelText: '서버 URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                labelText: '닉네임을 입력하세요',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              onSubmitted: (_) => _connectToServer(),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _connectToServer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('채팅 시작하기', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _connectToServer() async {
    final nickname = _nicknameController.text.trim();
    final serverUrl = _serverUrlController.text.trim();

    if (nickname.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('닉네임을 입력해주세요.')));
      return;
    }

    if (serverUrl.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('서버 URL을 입력해주세요.')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 닉네임 저장
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('nickname', nickname);
      await prefs.setString('serverUrl', serverUrl);

      // SignalR 연결
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await chatProvider.initializeConnection(serverUrl, nickname);

      if (chatProvider.isConnected) {
        // 방 목록 화면으로 이동
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const RoomListScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('서버 연결에 실패했습니다. URL을 확인해주세요.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('연결 오류: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _serverUrlController.dispose();
    super.dispose();
  }
}
