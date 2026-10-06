import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/chat_model.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glass_card.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgController.text;
    if (text.trim().isEmpty) return;
    Provider.of<ChatProvider>(context, listen: false).sendMessage(text);
    _msgController.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final currentUserId = authProvider.user?['id'];
    final isAdmin = authProvider.userRole == 'THROTTLE_ADMIN' || authProvider.userRole == 'THROTTLE_STAFF';

    // If Admin and no conversation is currently selected, show Clients List View
    final showClientsList = isAdmin && chatProvider.activeConversation == null;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SafeArea(
        bottom: false,
        child: showClientsList
            ? _buildClientsListView(chatProvider)
            : _buildChatThreadView(authProvider, chatProvider, currentUserId, isAdmin),
      ),
    );
  }

  /// Render Clients List for Throttle Admin Users
  Widget _buildClientsListView(ChatProvider chatProvider) {
    if (chatProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
      );
    }

    final convs = chatProvider.conversations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.screenPadding,
            14,
            AppConstants.screenPadding,
            12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Client Inbox',
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryText,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined, size: 14, color: Color(0xFF34C759)),
                      const SizedBox(width: 4),
                      Text(
                        '1-on-1 Encrypted Client Channels',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF34C759),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryText,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${convs.length} Clients',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Clients List
        Expanded(
          child: convs.isEmpty
              ? Center(
                  child: Text(
                    'No client conversations found.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.screenPadding,
                    6,
                    AppConstants.screenPadding,
                    20,
                  ),
                  itemCount: convs.length,
                  itemBuilder: (context, index) {
                    final conv = convs[index];
                    final lastMsgText = conv.lastMessage?.message ?? 'No messages yet';
                    final partnerName = conv.partnerName;
                    final orgName = conv.organizationName ?? 'Client Organization';
                    final timeSource = conv.lastMessage?.createdAt ?? conv.updatedAt;
                    final timeStr = _formatTimestamp(timeSource);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () => chatProvider.selectConversation(conv),
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          borderRadius: 20,
                          child: Row(
                            children: [
                              // Initial Avatar
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryText,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    partnerName.isNotEmpty ? partnerName[0].toUpperCase() : 'C',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Name & Last message
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            partnerName,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.primaryText,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.06),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            orgName,
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.secondaryText,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      lastMsgText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppTheme.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 10),

                              // Time & Unread counter
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    timeStr,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: AppTheme.tertiaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (conv.unreadCount > 0)
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF34C759),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${conv.unreadCount}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// Render 1-on-1 Active Chat Feed
  Widget _buildChatThreadView(
    AuthProvider authProvider,
    ChatProvider chatProvider,
    String? currentUserId,
    bool isAdmin,
  ) {
    final activeConv = chatProvider.activeConversation;
    final partnerName = activeConv?.partnerName ?? 'Client';
    final orgName = activeConv?.organizationName ?? '';
    final titleText = isAdmin
        ? '$partnerName • $orgName'
        : 'Throttle Admin • Direct Chat';

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.screenPadding,
            12,
            AppConstants.screenPadding,
            12,
          ),
          child: Row(
            children: [
              if (isAdmin)
                GestureDetector(
                  onTap: () => chatProvider.clearActiveConversation(),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.black87,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryText,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    isAdmin && partnerName.isNotEmpty ? partnerName[0].toUpperCase() : 'T',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 12,
                          color: Color(0xFF34C759),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '1-on-1 Encrypted',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF34C759),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE8E8EC)),

        // Messages Feed
        Expanded(
          child: chatProvider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2,
                  ),
                )
              : chatProvider.messages.isEmpty
                  ? Center(
                      child: Text(
                        'No messages yet. Send a message to start conversation.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.screenPadding,
                        12,
                        AppConstants.screenPadding,
                        12,
                      ),
                      itemCount: chatProvider.messages.length,
                      itemBuilder: (context, index) {
                        final msg = chatProvider.messages[index];
                        final isMe = currentUserId != null
                            ? (msg.senderUserId == currentUserId)
                            : !msg.isAgency;
                        return _buildMessageBubble(msg, isMe);
                      },
                    ),
        ),
        // Input Bar
        _buildInputBar(isAdmin: isAdmin, partnerName: partnerName),
        const SizedBox(height: 6),
      ],
    );
  }

  String _formatTimestamp(DateTime dt) {
    final local = dt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(local.year, local.month, local.day);

    if (dateToCheck == today) {
      return DateFormat('h:mm a').format(local);
    } else if (dateToCheck == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (local.year == now.year) {
      return DateFormat('MMM d').format(local);
    } else {
      return DateFormat('MM/dd/yy').format(local);
    }
  }

  Widget _buildMessageBubble(ChatMessageModel msg, bool isMe) {
    final timeStr = DateFormat('h:mm a').format(msg.createdAt.toLocal());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: msg.isAgency ? Colors.black : AppTheme.primaryText,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  msg.senderName.isNotEmpty ? msg.senderName[0].toUpperCase() : 'C',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.70,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isMe
                      ? AppTheme.primaryText
                      : Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMe ? 18 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  msg.message,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isMe ? Colors.white : AppTheme.primaryText,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: EdgeInsets.only(
                  left: isMe ? 0 : 2,
                  right: isMe ? 2 : 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeStr,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.tertiaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        msg.readAt != null ? Icons.done_all_rounded : Icons.done_rounded,
                        size: 14,
                        color: msg.readAt != null ? Colors.blue : AppTheme.tertiaryText,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildInputBar({required bool isAdmin, required String partnerName}) {
    final hint = isAdmin ? 'Message $partnerName...' : 'Message Throttle...';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.screenPadding,
        vertical: 4,
      ),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        borderRadius: 28,
        child: Row(
          children: [
            Icon(
              Icons.attach_file_rounded,
              size: 22,
              color: AppTheme.tertiaryText,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _msgController,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppTheme.primaryText,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppTheme.tertiaryText,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onSubmitted: (_) => _sendMessage(),
                maxLines: null,
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primaryText,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
