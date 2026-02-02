import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    text: json['text'],
    isUser: json['isUser'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class ChatController extends GetxController {
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  late final GenerativeModel model;
  late final ChatSession chat;

  // TODO: Replace with your actual Gemini API key
  static const String GEMINI_API_KEY = 'YOUR_API_KEY_HERE';

  @override
  void onInit() {
    super.onInit();
    model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: GEMINI_API_KEY,
    );
    chat = model.startChat();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatData = prefs.getString('chat_history');
      if (chatData != null) {
        final List<dynamic> decoded = jsonDecode(chatData);
        messages.value = decoded
            .map((item) => ChatMessage.fromJson(item))
            .toList();
      }
    } catch (e) {
      print('Error loading chat history: $e');
    }
  }

  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        messages.map((msg) => msg.toJson()).toList(),
      );
      await prefs.setString('chat_history', encoded);
    } catch (e) {
      print('Error saving chat history: $e');
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    messages.add(userMessage);
    messageController.clear();
    _scrollToBottom();
    await _saveChatHistory();

    isLoading.value = true;

    try {
      final response = await chat.sendMessage(Content.text(text));
      final aiMessage = ChatMessage(
        text: response.text ?? 'No response',
        isUser: false,
        timestamp: DateTime.now(),
      );

      messages.add(aiMessage);
      await _saveChatHistory();
      _scrollToBottom();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to get response: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> clearChat() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to delete all messages?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      messages.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('chat_history');

      // Restart chat session
      chat = model.startChat();

      Get.snackbar(
        'Success',
        'Chat history cleared',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}