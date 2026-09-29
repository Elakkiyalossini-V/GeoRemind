import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'chat_history_screen.dart';
import 'location_picker_screen.dart';

class _Msg {
  final bool fromUser;
  final String text;

  // Used when the AI message contains a reminder confirmation card.
  final String? reminder;
  final String? location;

  _Msg(
    this.fromUser,
    this.text, {
    this.reminder,
    this.location,
  });
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_Msg> _messages = [
    _Msg(
      false,
      'Hi! I’m GeoRemind AI 👋\n\n'
      'Tell me what you want to remember and where it should happen.\n\n'
      'For example:\n'
      '“Remind me to buy milk when I reach the supermarket.”',
    ),
  ];

  bool _isTyping = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> _send() async {
    final text = _controller.text.trim();

    if (text.isEmpty || _isTyping) return;

    setState(() {
      _messages.add(_Msg(true, text));
      _controller.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      // --------------------------------------------------------
      // REAL FASTAPI + GEMINI AI
      // --------------------------------------------------------

      final result = await ApiService.sendChatMessage(text);

      if (!mounted) return;

      setState(() {
        _isTyping = false;
      });

      // --------------------------------------------------------
      // AI FOUND A REMINDER
      // --------------------------------------------------------

      if (result['success'] == true &&
          result['is_reminder'] == true) {
        final reminder =
            (result['reminder'] ?? '').toString().trim();

        final location =
            (result['location'] ?? '').toString().trim();

        if (reminder.isNotEmpty && location.isNotEmpty) {
          setState(() {
            _messages.add(
              _Msg(
                false,
                '',
                reminder: reminder,
                location: location,
              ),
            );
          });
        } else {
          setState(() {
            _messages.add(
              _Msg(
                false,
                'I understood your request, but I need a little '
                'more information about the reminder or location. '
                'Could you try saying it again?',
              ),
            );
          });
        }
      }

      // --------------------------------------------------------
      // AI DID NOT DETECT A REMINDER
      // --------------------------------------------------------

      else if (result['success'] == true &&
          result['is_reminder'] == false) {
        setState(() {
          _messages.add(
            _Msg(
              false,
              'I can help you create a location-based reminder. 📍\n\n'
              'Try something like:\n'
              '“Remind me to buy milk when I reach DMart.”',
            ),
          );
        });
      }

      // --------------------------------------------------------
      // API ERROR
      // --------------------------------------------------------

      else {
        setState(() {
          _messages.add(
            _Msg(
              false,
              'Sorry, I couldn’t connect to GeoRemind AI right now. '
              'Please check that the GeoRemind server is running and try again.',
            ),
          );
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isTyping = false;

        _messages.add(
          _Msg(
            false,
            'Sorry, something went wrong while contacting '
            'GeoRemind AI. Please try again.',
          ),
        );
      });

      print('Chat screen error: $e');
    }

    _scrollToBottom();
  }

  // ============================================================
  // CONFIRM EXACT LOCATION
  // ============================================================

  Future<void> _confirmExactLocation(
    String reminder,
    String location,
  ) async {
    final selectedLocation =
        await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          title: 'Confirm $location',
        ),
      ),
    );

    if (!mounted || selectedLocation == null) {
      return;
    }

    // ----------------------------------------------------------
    // For now we confirm the selected coordinates.
    //
    // Later this can be sent to the reminder/database service:
    //
    // reminder
    // latitude
    // longitude
    // ----------------------------------------------------------

    setState(() {
      _messages.add(
        _Msg(
          false,
          'Location confirmed! 📍\n\n'
          'Reminder: $reminder\n'
          'Location: $location',
        ),
      );
    });

    _scrollToBottom();
  }

  // ============================================================
  // SUGGESTED PROMPT
  // ============================================================

  void _useSuggestion(String text) {
    _controller.text = text;

    _controller.selection = TextSelection.fromPosition(
      TextPosition(
        offset: _controller.text.length,
      ),
    );

    FocusScope.of(context).requestFocus(FocusNode());
  }

  // ============================================================
  // AUTO SCROLL
  // ============================================================

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),

        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              20,
            ),
            itemCount:
                _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (_isTyping &&
                  index == _messages.length) {
                return _buildTypingIndicator();
              }

              return _bubble(_messages[index]);
            },
          ),
        ),

        if (_messages.length == 1 && !_isTyping)
          _buildSuggestions(),

        _buildInputArea(),
      ],
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        12,
        8,
      ),
      child: Row(
        children: [
          _buildAiAvatar(size: 42),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'GEOREMIND AI',
                  style: AppText.mono(
                    size: 10,
                    color: AppColors.emerald,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ask GeoRemind',
                  style: AppText.display(
                    size: 23,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            tooltip: 'Chat history',
            icon: const Icon(
              Icons.history_rounded,
              color: AppColors.textMid,
              size: 24,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const ChatHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AI AVATAR
  // ============================================================

  Widget _buildAiAvatar({
    double size = 36,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.mainGradient,
        borderRadius:
            BorderRadius.circular(size * 0.32),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple2
                .withValues(alpha: 0.22),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        Icons.auto_awesome_rounded,
        color: Colors.white,
        size: size * 0.48,
      ),
    );
  }

  // ============================================================
  // MESSAGE BUBBLE
  // ============================================================

  Widget _bubble(_Msg message) {
    final bool isUser = message.fromUser;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.end,
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAiAvatar(size: 30),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: message.reminder != null &&
                    message.location != null
                ? _buildReminderCard(
                    message.reminder!,
                    message.location!,
                  )
                : Container(
                    constraints:
                        const BoxConstraints(
                      maxWidth: 310,
                    ),
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: isUser
                          ? AppColors.mainGradient
                          : null,
                      color: isUser
                          ? null
                          : AppColors.surface,
                      border: isUser
                          ? null
                          : Border.all(
                              color:
                                  AppColors.glassBorder,
                            ),
                      borderRadius:
                          BorderRadius.only(
                        topLeft:
                            const Radius.circular(18),
                        topRight:
                            const Radius.circular(18),
                        bottomLeft:
                            Radius.circular(
                          isUser ? 18 : 5,
                        ),
                        bottomRight:
                            Radius.circular(
                          isUser ? 5 : 18,
                        ),
                      ),
                    ),
                    child: Text(
                      message.text,
                      style: AppText.body(
                        size: 13.8,
                        color: AppColors.textHi,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REMINDER CONFIRMATION CARD
  // ============================================================

  Widget _buildReminderCard(
    String reminder,
    String location,
  ) {
    return Container(
      constraints:
          const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.glassBorder,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'I got it! ✨',
            style: AppText.body(
              size: 13,
              color: AppColors.emerald,
              weight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'Reminder',
            style: AppText.mono(
              size: 9.5,
              color: AppColors.textLow,
              weight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            reminder,
            style: AppText.body(
              size: 15,
              color: AppColors.textHi,
              weight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Location',
            style: AppText.mono(
              size: 9.5,
              color: AppColors.textLow,
              weight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            location,
            style: AppText.body(
              size: 15,
              color: AppColors.textHi,
              weight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () {
                _confirmExactLocation(
                  reminder,
                  location,
                );
              },
              icon: const Icon(
                Icons.location_on_rounded,
                size: 18,
              ),
              label: const Text(
                'Confirm Exact Location',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.emerald,
                foregroundColor: Colors.white,
                elevation: 4,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                textStyle:
                    const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TYPING INDICATOR
  // ============================================================

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        children: [
          _buildAiAvatar(size: 30),
          const SizedBox(width: 8),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  const BorderRadius.only(
                topLeft:
                    Radius.circular(18),
                topRight:
                    Radius.circular(18),
                bottomRight:
                    Radius.circular(18),
                bottomLeft:
                    Radius.circular(5),
              ),
              border: Border.all(
                color: AppColors.glassBorder,
              ),
            ),
            child: Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                _dot(),
                const SizedBox(width: 4),
                _dot(),
                const SizedBox(width: 4),
                _dot(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot() {
    return Container(
      width: 6,
      height: 6,
      decoration:
          const BoxDecoration(
        color: AppColors.textMid,
        shape: BoxShape.circle,
      ),
    );
  }

  // ============================================================
  // SUGGESTIONS
  // ============================================================

  Widget _buildSuggestions() {
    final suggestions = [
      'Remind me when I reach college',
      'Remind me to buy groceries',
      'Remind me when I return home',
    ];

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        10,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'TRY SAYING',
            style: AppText.mono(
              size: 10,
              color: AppColors.textLow,
              weight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection:
                  Axis.horizontal,
              itemCount:
                  suggestions.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: 8),
              itemBuilder:
                  (context, index) {
                return InkWell(
                  onTap: () =>
                      _useSuggestion(
                    suggestions[index],
                  ),
                  borderRadius:
                      BorderRadius.circular(12),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 9,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          AppColors.glassFill2,
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                      border: Border.all(
                        color:
                            AppColors.glassBorder,
                      ),
                    ),
                    child: Text(
                      suggestions[index],
                      style: AppText.body(
                        size: 11.5,
                        color:
                            AppColors.textMid,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INPUT AREA
  // ============================================================

  Widget _buildInputArea() {
    return SafeArea(
      top: false,
      child: Padding(
        padding:
            const EdgeInsets.fromLTRB(
          16,
          4,
          16,
          16,
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration:
                  BoxDecoration(
                color:
                    AppColors.surface2,
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
                border: Border.all(
                  color:
                      AppColors.glassBorder,
                ),
              ),
              child: IconButton(
                tooltip: 'Voice input',
                icon: const Icon(
                  Icons.mic_none_rounded,
                  color:
                      AppColors.textMid,
                  size: 21,
                ),
                onPressed: () {},
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                textInputAction:
                    TextInputAction.newline,
                style: AppText.body(
                  size: 14,
                  color:
                      AppColors.textHi,
                ),
                onSubmitted: (_) {
                  if (!_isTyping) {
                    _send();
                  }
                },
                decoration:
                    InputDecoration(
                  hintText:
                      'Ask GeoRemind...',
                  hintStyle:
                      AppText.body(
                    size: 13.5,
                    color:
                        AppColors.textLow,
                  ),
                  filled: true,
                  fillColor:
                      AppColors.surface2,
                  contentPadding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      15,
                    ),
                    borderSide:
                        BorderSide.none,
                  ),
                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      15,
                    ),
                    borderSide:
                        BorderSide.none,
                  ),
                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      15,
                    ),
                    borderSide:
                        BorderSide(
                      color: AppColors
                          .purple2
                          .withValues(
                        alpha: 0.45,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            GestureDetector(
              onTap: _send,
              child: AnimatedContainer(
                duration:
                    const Duration(
                  milliseconds: 200,
                ),
                width: 48,
                height: 48,
                decoration:
                    BoxDecoration(
                  gradient: _isTyping
                      ? const LinearGradient(
                          colors: [
                            AppColors
                                .surface2,
                            AppColors
                                .surface2,
                          ],
                        )
                      : AppColors
                          .mainGradient,
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
                child: Icon(
                  Icons
                      .arrow_upward_rounded,
                  color: _isTyping
                      ? AppColors.textLow
                      : Colors.white,
                  size: 21,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}