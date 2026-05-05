import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../services/auth_service.dart';
import '../services/base_service.dart';
import '../services/user_profile_service.dart';
import 'language_selection_screen.dart';
import 'personal_info_screen.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _blue = Color(0xFF1A9BE8);

  String _fullName = '';
  String _email = '';
  String? _imageUrl;
  String _role = '';
  bool _profileLoading = true;
  bool _imageUploading = false;

  // Held in memory after pick so we can show it immediately without waiting
  // for the remote URL to propagate.
  Uint8List? _localImageBytes;

  final _picker = ImagePicker();
  final _profileService = UserProfileService();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final fullName = await SessionStore.getFullName();
    final email    = await SessionStore.getEmail();
    final imageUrl = await SessionStore.getImageUrl();
    final role     = await SessionStore.getRole();
    if (mounted) {
      setState(() {
        _fullName       = fullName ?? 'User';
        _email          = email ?? '';
        _imageUrl       = imageUrl;
        _role           = role ?? '';
        _profileLoading = false;
      });
    }
  }

  // ── Image handling ──────────────────────────────────────────────────────────

  Future<void> _onEditAvatar() async {
    final source = await _showImageSourceDialog();
    if (source == null) return;

    final XFile? picked = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final filename = picked.name.isEmpty ? 'avatar.jpg' : picked.name;

    // Show locally right away for instant feedback
    setState(() {
      _localImageBytes = bytes;
      _imageUploading  = true;
    });

    try {
      final newUrl = await _profileService.uploadProfileImage(
        bytes: bytes,
        filename: filename,
      );

      // Persist the new URL in session
      await _persistImageUrl(newUrl.isNotEmpty ? newUrl : null);

      if (mounted) {
        setState(() {
          _imageUrl       = newUrl.isNotEmpty ? newUrl : _imageUrl;
          _imageUploading = false;
        });
        _showSnack('Profile photo updated!', isError: false);
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _imageUploading = false);
        _showSnack(e.message, isError: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _imageUploading = false);
        _showSnack('Upload failed. Please try again.', isError: true);
      }
    }
  }

  Future<void> _persistImageUrl(String? url) async {
    final token    = await SessionStore.getToken() ?? '';
    final userId   = await SessionStore.getUserId() ?? 0;
    final role     = await SessionStore.getRole() ?? '';
    final email    = await SessionStore.getEmail() ?? '';
    final fullName = await SessionStore.getFullName() ?? '';
    await SessionStore.saveSession(
      token: token,
      userId: userId,
      role: role,
      email: email,
      fullName: fullName,
      imageUrl: url,
    );
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final cardBg = isDark ? const Color(0xFF112240) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF0D1B2E);
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Text(
                  'Change Profile Photo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _sourceOption(
                ctx,
                icon: Icons.photo_library_outlined,
                label: 'Choose from Gallery',
                source: ImageSource.gallery,
                textColor: textColor,
              ),
              _sourceOption(
                ctx,
                icon: Icons.camera_alt_outlined,
                label: 'Take a Photo',
                source: ImageSource.camera,
                textColor: textColor,
              ),
              if (_imageUrl != null || _localImageBytes != null)
                _removeOption(ctx, textColor),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _sourceOption(BuildContext ctx, {
    required IconData icon,
    required String label,
    required ImageSource source,
    required Color textColor,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: _blue, size: 20),
      ),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
      onTap: () => Navigator.pop(ctx, source),
    );
  }

  Widget _removeOption(BuildContext ctx, Color textColor) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Color(0xFFE53935), size: 20),
      ),
      title: const Text(
        'Remove Photo',
        style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w500),
      ),
      onTap: () async {
        Navigator.pop(ctx);
        setState(() {
          _localImageBytes = null;
          _imageUrl        = null;
        });
        await _persistImageUrl(null);
      },
    );
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? const Color(0xFFE53935) : _blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D1B2E) : const Color(0xFFF0F7FF);
    final cardColor = isDark ? const Color(0xFF112240) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0D1B2E);
    final textSecondary = isDark ? Colors.white60 : Colors.black54;
    final sectionHeaderColor = isDark ? Colors.white38 : Colors.black38;
    final dividerColor = isDark ? Colors.white10 : Colors.black.withOpacity(0.08);

    final appState = MyApp.of(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // ── Gradient header ───────────────────────────────
          SliverToBoxAdapter(
            child: Container(
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
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Column(
                    children: [
                      _buildAvatar(),
                      const SizedBox(height: 14),
                      _profileLoading
                          ? const SizedBox(
                              width: 24, height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              _fullName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                      const SizedBox(height: 4),
                      Text(
                        _email,
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                      ),
                      if (_role.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _role,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Settings body ─────────────────────────────────
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -16),
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Appearance & Language
                    _buildCard(cardColor: cardColor, dividerColor: dividerColor, children: [
                      _buildToggleRow(
                        icon: Icons.brightness_4_outlined,
                        label: l.darkMode,
                        value: isDark,
                        textPrimary: textPrimary,
                        onChanged: (v) =>
                            appState?.setThemeMode(v ? ThemeMode.dark : ThemeMode.light),
                      ),
                      Divider(color: dividerColor, height: 1),
                      _buildNavRow(
                        icon: Icons.language_outlined,
                        label: l.languageLabel,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentLanguage(context),
                              style: const TextStyle(
                                  color: _blue, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right, color: Colors.black26, size: 20),
                          ],
                        ),
                        textPrimary: textPrimary,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LanguageSelectionScreen(fromProfile: true),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 8),

                    _buildSectionHeader(l.health, sectionHeaderColor),
                    _buildCard(cardColor: cardColor, dividerColor: dividerColor, children: [
                      _buildNavRow(icon: Icons.favorite_outline, label: l.healthGoals, textPrimary: textPrimary, onTap: () {}),
                      Divider(color: dividerColor, height: 1),
                      _buildNavRow(icon: Icons.show_chart_outlined, label: l.healthIndicators, textPrimary: textPrimary, onTap: () {}),
                    ]),
                    const SizedBox(height: 8),

                    _buildSectionHeader(l.account, sectionHeaderColor),
                    _buildCard(cardColor: cardColor, dividerColor: dividerColor, children: [
                      _buildNavRow(icon: Icons.person_outline, label: l.personalInfo, textPrimary: textPrimary, onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalInfoScreen()));
                      }),
                      Divider(color: dividerColor, height: 1),
                      _buildNavRow(icon: Icons.phone_outlined, label: l.emergencyContact, textPrimary: textPrimary, onTap: () {}),
                      Divider(color: dividerColor, height: 1),
                      _buildNavRow(
                        icon: Icons.shield_outlined,
                        label: l.insurance,
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            l.comingSoon,
                            style: const TextStyle(
                                color: Color(0xFFF57C00), fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                        textPrimary: textPrimary,
                        onTap: () {},
                      ),
                    ]),
                    const SizedBox(height: 8),

                    _buildSectionHeader(l.preferences, sectionHeaderColor),
                    _buildCard(cardColor: cardColor, dividerColor: dividerColor, children: [
                      _buildNavRow(icon: Icons.notifications_outlined, label: l.notifications, textPrimary: textPrimary, onTap: () {}),
                      Divider(color: dividerColor, height: 1),
                      _buildNavRow(icon: Icons.help_outline, label: l.helpSupport, textPrimary: textPrimary, onTap: () {}),
                    ]),
                    const SizedBox(height: 16),

                    // Logout
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          leading: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0F0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.logout, color: Color(0xFFE53935), size: 18),
                          ),
                          title: Text(
                            l.logout,
                            style: const TextStyle(
                              color: Color(0xFFE53935),
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          onTap: () async {
                            await AuthService.logout();
                            if (context.mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                                (_) => false,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(l.appVersion, style: TextStyle(color: textSecondary, fontSize: 12)),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Avatar widget ───────────────────────────────────────────────────────────

  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 46,
            backgroundColor: Colors.white.withOpacity(0.2),
            // Priority: local picked bytes → remote URL → fallback icon
            child: _imageUploading
                ? const SizedBox(
                    width: 28, height: 28,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : _buildAvatarContent(),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: _onEditAvatar,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6),
                ],
              ),
              child: const Icon(Icons.camera_alt, color: _blue, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarContent() {
    // 1. Local bytes (just picked, not yet uploaded)
    if (_localImageBytes != null) {
      return ClipOval(
        child: Image.memory(
          _localImageBytes!,
          width: 92, height: 92,
          fit: BoxFit.cover,
        ),
      );
    }
    // 2. Remote URL from session
    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          _imageUrl!,
          width: 92, height: 92,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : const SizedBox(
                  width: 28, height: 28,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ),
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.person, color: Colors.white, size: 50),
        ),
      );
    }
    // 3. Fallback — initials or icon
    if (_fullName.isNotEmpty) {
      final parts = _fullName.trim().split(' ');
      final initials = parts.length >= 2
          ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
          : _fullName.substring(0, _fullName.length.clamp(1, 2)).toUpperCase();
      return Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.w800,
        ),
      );
    }
    return const Icon(Icons.person, color: Colors.white, size: 50);
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _currentLanguage(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    switch (locale) {
      case 'fr': return 'Français';
      case 'ar': return 'العربية';
      default:   return 'English';
    }
  }

  Widget _buildSectionHeader(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required Color cardColor,
    required Color dividerColor,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String label,
    required bool value,
    required Color textPrimary,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _blue, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _blue,
            activeTrackColor: _blue.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildNavRow({
    required IconData icon,
    required String label,
    required Color textPrimary,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _blue, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary)),
            ),
            trailing ?? const Icon(Icons.chevron_right, color: Colors.black26, size: 20),
          ],
        ),
      ),
    );
  }
}
