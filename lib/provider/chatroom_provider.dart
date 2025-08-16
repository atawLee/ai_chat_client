import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/chatroom_repository.dart';
import 'global.dart';

// ChatRoomRepository를 제공하는 단순 Provider
final chatRoomRepositoryProvider = Provider<ChatRoomRepository>((ref) {
  final apiSetting = ref.watch(apiProvider);
  return ChatRoomRepository(baseUrl: apiSetting.defaultAddress);
});
