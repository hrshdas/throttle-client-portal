class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.timestamp,
  });
}

class UserProfile {
  final String name;
  final String company;
  final String email;
  final String phone;

  const UserProfile({
    required this.name,
    required this.company,
    required this.email,
    required this.phone,
  });
}
