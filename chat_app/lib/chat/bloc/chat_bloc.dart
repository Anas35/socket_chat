import 'dart:async';

import 'package:chat_repository/chat_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:group_repository/group_repository.dart';
import 'package:models/models.dart';
part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  
  ChatBloc() :
  _groupRepository = GroupRepository(),
  _chatRepository = ChatRepository(),
  super(const ChatState()) {
    on<PreMessagesEvent>(_onPreMessagesEvent);
    on<AddMessageEvent>(_onAddMessageEvent);
    on<_GetMessageEvent>(_onGetMessageEvent);
  }

  final ChatRepository _chatRepository;
  final GroupRepository _groupRepository;
  StreamSubscription? _streamSubscription;

  Future<void> _onPreMessagesEvent(
    PreMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(state.copyWith(chatStatus: ChatStatus.loading));

      if(_chatRepository.isChannelActive) {
        _streamSubscription?.cancel();
        _chatRepository.close();
      }
      
      _chatRepository.joinChat(event.groupId);
      final messages = await _groupRepository.getGroupMessages(event.groupId);

      emit(
        state.copyWith(
          chatStatus: ChatStatus.loaded, 
          messages: List.from(messages),
        ),
      );

      _streamSubscription = _chatRepository.messages.listen((id) {
        add(_GetMessageEvent(messageId: id));
      });

    } on GroupException catch (e) {
      emit(state.copyWith(
        chatStatus: ChatStatus.failed,
        errorMessage: e.message,
      ));
    } catch (e, stck) {
      print(stck);
      emit(state.copyWith(
        chatStatus: ChatStatus.failed,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onGetMessageEvent(
    _GetMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {

      final messageIds = state.messages.map((message) => message.messageId).toList();

      if (!messageIds.contains(event.messageId)) {
        final message = await _chatRepository.getMessage(event.messageId);
        emit(
          state.copyWith(
            chatStatus: ChatStatus.loaded, messages: List.from(state.messages)..add(message),
          ),
        );
      }

    } catch (e) {
      print(e);
      emit(state.copyWith(
        errorMessage: e.toString(),
      ));
    }
  }

  FutureOr<void> _onAddMessageEvent(
    AddMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final message = Message(
        groupId: event.groupId,
        userId: event.userId,
        message: event.message,
      );
      await _chatRepository.addMessage(message);
    } catch (e) {
      emit(state.copyWith(
        chatStatus: ChatStatus.failed,
        errorMessage: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    _chatRepository.close();
    return super.close();
  }
}
