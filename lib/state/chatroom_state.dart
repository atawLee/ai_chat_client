// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ai_chat/repository/chat_client.dart';

import '../models/chat_models.dart';

/// 간단한 채팅방 상태
class ChatRoomState {
  final List<ChatMessage> messages;

  const ChatRoomState({this.messages = const []});

  ChatRoomState copyWith({bool? isConnected, List<ChatMessage>? messages}) {
    return ChatRoomState(messages: messages ?? this.messages);
  }
}

class ChatRoomStateNotifier extends FamilyAsyncNotifier<ChatRoomState, String> {
  final ChatClient chatClient;
  ChatRoomStateNotifier({required this.chatClient});

  @override
  FutureOr<ChatRoomState> build(String roomId) {
    // roomId를 받아서 초기 상태 반환
    return const ChatRoomState();
  }

  /// 메시지 추가
  Future<void> addMessage(ChatMessage message) async {
    state = const AsyncValue.loading();

    try {
      final currentState = await future;
      final newMessages = [...currentState.messages, message];
      final newState = currentState.copyWith(messages: newMessages);

      state = AsyncValue.data(newState);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 채팅방 연결 및 초기화
  Future<void> initializeChatRoom() async {
    state = const AsyncValue.loading();

    try {
      // 여기서 ChatClient 연결 로직 처리 (arg로 받은 roomId 사용 가능)
      final roomId = arg; // family parameter 접근
      print('Initializing chat room: $roomId');

      await Future.delayed(const Duration(seconds: 1)); // 시뮬레이션

      final initialState = const ChatRoomState(messages: []);
      state = AsyncValue.data(initialState);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 메시지 전송
  Future<void> sendMessage(String userName, String messageText) async {
    try {
      final roomId = arg; // family parameter로 받은 roomId

      // 실제 서버로 메시지 전송 로직
      // await chatClient.sendMessage(roomId, userName, messageText);

      // 임시로 로컬에 메시지 추가
      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        roomId: roomId,
        userName: userName,
        message: messageText,
        timestamp: DateTime.now(),
      );

      await addMessage(message);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 채팅방 연결 해제
  Future<void> disconnect() async {
    state = const AsyncValue.loading();

    try {
      // ChatClient disconnect 로직
      await Future.delayed(const Duration(milliseconds: 500));

      state = const AsyncValue.data(ChatRoomState());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
