import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../services/support_services.dart';
import '../services/socket_service.dart';
import '../services/base_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const _teal = Color(0xFF1A9BE8);
  final MessagingService _service = MessagingService();
  final TextEditingController _searchCtrl = TextEditingController();
  StreamSubscription<SocketChatMessage>? _socketSub;

  List<ConversationSummaryResponse> _conversations = [];
  List<ConversationSummaryResponse> _filtered = [];
  bool _isLoading = true;
  String? _error;

  // unread counts keyed by userId
  final Map<int, int> _unreadCounts = {};

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_filter);
    _socketSub = SocketService.instance.onMessage.listen((msg) {
      if (!mounted) return;
      setState(() {
        _unreadCounts[msg.senderId] =
            (_unreadCounts[msg.senderId] ?? 0) + 1;
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _socketSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await _service.getConversations(forceRefresh: true);
      if (mounted) setState(() { _conversations = data; _filtered = data; _isLoading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _conversations.where((c) =>
          c.fullName.toLowerCase().contains(q) ||
          c.role.name.toLowerCase().contains(q)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D1B2E) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF112240) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? Colors.white60 : Colors.black54;
    final searchBg = isDark ? const Color(0xFF1E3A5F) : Colors.white;
    final searchHint = isDark ? Colors.white38 : Colors.black38;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A9BE8), Color(0xFF0B7FCC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.messages, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                            const SizedBox(height: 2),
                            Text('Discuss with your care team', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                          ],
                        ),
                        Row(
                          children: [
                            // Live badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle)),
                                  const SizedBox(width: 5),
                                  const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 46,
                      decoration: BoxDecoration(color: searchBg, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Icon(Icons.search, color: searchHint, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              style: TextStyle(color: textPrimary, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: l.searchMessages,
                                hintStyle: TextStyle(color: searchHint, fontSize: 14),
                                border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_searchCtrl.text.isNotEmpty)
                            IconButton(
                              icon: Icon(Icons.clear, color: searchHint, size: 18),
                              onPressed: () { _searchCtrl.clear(); _filter(); },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody(context, l, cardColor, textPrimary, textSecondary, isDark, bgColor)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l, Color cardColor, Color textPrimary, Color textSecondary, bool isDark, Color bgColor) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: _teal));
    if (_error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.wifi_off_rounded, size: 64, color: textSecondary),
          const SizedBox(height: 16),
          Text('Could not load messages', style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary)),
          const SizedBox(height: 8),
          TextButton.icon(onPressed: _load, icon: const Icon(Icons.refresh, color: _teal), label: const Text('Retry', style: TextStyle(color: _teal))),
        ]),
      );
    }
    if (_filtered.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: _teal.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.chat_bubble_outline, size: 36, color: _teal),
          ),
          const SizedBox(height: 20),
          Text(_searchCtrl.text.isEmpty ? 'No conversations yet' : 'No results found',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: textPrimary)),
          if (_searchCtrl.text.isEmpty) ...[
            const SizedBox(height: 8),
            Text('Your conversations will appear here', style: TextStyle(color: textSecondary, fontSize: 13)),
          ],
        ]),
      );
    }
    return RefreshIndicator(
      color: _teal,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _ConversationTile(
          conversation: _filtered[i],
          cardColor: cardColor,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          isDark: isDark,
          unreadCount: _unreadCounts[_filtered[i].id] ?? 0,
          onTap: () {
            setState(() => _unreadCounts[_filtered[i].id] = 0);
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => _ConversationScreen(conversation: _filtered[i], service: _service),
            ));
          },
        ),
      ),
    );
  }
}

// ─── Conversation Tile ───────────────────────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  final ConversationSummaryResponse conversation;
  final Color cardColor, textPrimary, textSecondary;
  final bool isDark;
  final int unreadCount;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation, required this.cardColor,
    required this.textPrimary, required this.textSecondary,
    required this.isDark, required this.unreadCount, required this.onTap,
  });

  static const List<Color> _colors = [
    Color(0xFF7986CB), Color(0xFF4DB6AC), Color(0xFFBA68C8),
    Color(0xFFFF8A65), Color(0xFF4FC3F7),
  ];

  Color get _color => _colors[conversation.id % _colors.length];

  String get _initials {
    final f = conversation.firstName.isNotEmpty ? conversation.firstName[0] : '';
    final l = conversation.lastName.isNotEmpty ? conversation.lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  String get _roleLabel => conversation.role.name
      .split('_').map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase()).join(' ');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                conversation.imageUrl != null
                    ? CircleAvatar(radius: 28, backgroundImage: NetworkImage(conversation.imageUrl!), backgroundColor: _color.withOpacity(0.15))
                    : CircleAvatar(radius: 28, backgroundColor: _color.withOpacity(0.15),
                        child: Text(_initials, style: TextStyle(color: _color, fontWeight: FontWeight.w700, fontSize: 16))),
                if (unreadCount > 0)
                  Positioned(
                    right: -2, top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Color(0xFF1A9BE8), shape: BoxShape.circle),
                      child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(conversation.fullName, style: TextStyle(fontWeight: unreadCount > 0 ? FontWeight.w800 : FontWeight.w600, fontSize: 15, color: textPrimary)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8)),
                    child: Text(_roleLabel, style: const TextStyle(color: Color(0xFF1A9BE8), fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                ]),
                const SizedBox(height: 4),
                Text(unreadCount > 0 ? '$unreadCount new message${unreadCount > 1 ? 's' : ''}' : 'Tap to view conversation',
                    style: TextStyle(color: unreadCount > 0 ? const Color(0xFF1A9BE8) : textSecondary, fontSize: 12, fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.w400),
                    overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Full Conversation Screen ────────────────────────────────────────────────

class _ConversationScreen extends StatefulWidget {
  final ConversationSummaryResponse conversation;
  final MessagingService service;
  const _ConversationScreen({required this.conversation, required this.service});

  @override
  State<_ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<_ConversationScreen> {
  static const _teal = Color(0xFF1A9BE8);

  List<ChatMessageResponse> _messages = [];
  bool _isLoading = true;
  String? _error;
  bool _isSending = false;
  int? _myId;

  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  StreamSubscription<SocketChatMessage>? _socketSub;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _subscribeSocket();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _socketSub?.cancel();
    super.dispose();
  }

  void _subscribeSocket() {
    _socketSub = SocketService.instance.onMessage.listen((msg) {
      if (!mounted) return;
      if (msg.senderId == widget.conversation.id || msg.receiverId == widget.conversation.id) {
        setState(() => _messages.add(msg.toChatMessageResponse()));
        _scrollToBottom();
      }
    });
  }

  Future<void> _loadMessages() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      _myId = await SessionStore.getUserId();
      final msgs = await widget.service.getConversationWith(widget.conversation.id);
      if (mounted) {
        setState(() { _messages = msgs; _isLoading = false; });
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _isSending) return;
    setState(() => _isSending = true);
    _msgCtrl.clear();

    final token = await SessionStore.getToken();
    if (token == null) { setState(() => _isSending = false); return; }

    // Optimistic UI
    final optimistic = ChatMessageResponse(
      id: DateTime.now().millisecondsSinceEpoch,
      content: text,
      senderId: _myId ?? 0,
      receiverId: widget.conversation.id,
      status: MessageStatus.SENT,
      sentAt: DateTime.now(),
    );
    setState(() => _messages.add(optimistic));
    _scrollToBottom();

    final sent = await SocketService.instance.sendMessage(
      receiverId: widget.conversation.id,
      content: text,
      token: token,
    );

    if (sent != null && mounted) {
      setState(() {
        final idx = _messages.indexWhere((m) => m.id == optimistic.id);
        if (idx >= 0) _messages[idx] = sent;
      });
    }
    setState(() => _isSending = false);
  }

  bool _isMine(ChatMessageResponse msg) => msg.senderId == _myId;

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D1B2E) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF112240) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 48,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            widget.conversation.imageUrl != null
                ? CircleAvatar(radius: 18, backgroundImage: NetworkImage(widget.conversation.imageUrl!))
                : CircleAvatar(radius: 18, backgroundColor: Colors.white.withOpacity(0.3),
                    child: Text(
                      (widget.conversation.firstName.isNotEmpty ? widget.conversation.firstName[0] : '') +
                      (widget.conversation.lastName.isNotEmpty ? widget.conversation.lastName[0] : ''),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                    )),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.conversation.fullName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              Row(children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text('En ligne', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.85))),
              ]),
            ]),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.phone_outlined, size: 20), onPressed: () {}),
          IconButton(icon: const Icon(Icons.videocam_outlined, size: 22), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: _teal))
                : _error != null
                    ? Center(child: Text(_error!, style: TextStyle(color: textSecondary)))
                    : _messages.isEmpty
                        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.chat_bubble_outline, size: 56, color: textSecondary),
                            const SizedBox(height: 12),
                            Text('No messages yet', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
                          ]))
                        : ListView.builder(
                            controller: _scrollCtrl,
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            itemCount: _messages.length,
                            itemBuilder: (_, i) {
                              final msg = _messages[i];
                              final mine = _isMine(msg);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (!mine) ...[
                                      widget.conversation.imageUrl != null
                                          ? CircleAvatar(radius: 14, backgroundImage: NetworkImage(widget.conversation.imageUrl!))
                                          : CircleAvatar(radius: 14, backgroundColor: const Color(0xFF1A9BE8).withOpacity(0.15),
                                              child: Text(
                                                (widget.conversation.firstName.isNotEmpty ? widget.conversation.firstName[0] : ''),
                                                style: const TextStyle(color: Color(0xFF1A9BE8), fontSize: 12, fontWeight: FontWeight.w700))),
                                      const SizedBox(width: 8),
                                    ],
                                    Column(
                                      crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.68),
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: mine ? _teal : cardColor,
                                            borderRadius: BorderRadius.only(
                                              topLeft: const Radius.circular(18),
                                              topRight: const Radius.circular(18),
                                              bottomLeft: Radius.circular(mine ? 18 : 4),
                                              bottomRight: Radius.circular(mine ? 4 : 18),
                                            ),
                                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 6, offset: const Offset(0, 2))],
                                          ),
                                          child: Text(msg.content, style: TextStyle(color: mine ? Colors.white : textPrimary, fontSize: 14, height: 1.4)),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(_formatTime(msg.sentAt), style: TextStyle(color: textSecondary, fontSize: 10)),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
          _buildInputBar(cardColor, textPrimary, textSecondary),
        ],
      ),
    );
  }

  Widget _buildInputBar(Color cardColor, Color textPrimary, Color textSecondary) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 8,
          left: 12, right: 12, top: 8,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -3))],
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.attach_file_outlined, color: textSecondary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E3A5F) : const Color(0xFFF0F7FF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _msgCtrl,
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Écrire un message...',
                    hintStyle: TextStyle(color: textSecondary, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _sendMessage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _isSending ? const Color(0xFF1A9BE8).withOpacity(0.5) : const Color(0xFF1A9BE8),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: const Color(0xFF1A9BE8).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: _isSending
                    ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
