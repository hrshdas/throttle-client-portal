import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glass_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
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
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    final userName = authProvider.userName;
    final userEmail = user?['email'] ?? 'raj@blueforce.com';
    final userRole = authProvider.userRole;
    final orgName = authProvider.orgName;

    final initials = userName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join();

    return FadeTransition(
      opacity: _fadeAnim,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.screenPadding,
                24,
                AppConstants.screenPadding,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryText,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildProfileCard(userName, orgName, initials),
                    const SizedBox(height: AppConstants.sectionGap),
                    _buildInfoCard(userEmail, orgName, userRole),
                    const SizedBox(height: AppConstants.sectionGap),
                    _buildSettingsCard(context),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(String name, String org, String initials) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.primaryText,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials.isEmpty ? 'T' : initials,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryText,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                org,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String email, String org, String role) {
    final items = [
      _InfoItem(Icons.mail_outline_rounded, 'Email', email),
      _InfoItem(Icons.business_outlined, 'Company Tenant', org),
      _InfoItem(Icons.badge_outlined, 'Role', role),
    ];

    return GlassCard(
      child: Column(
        children: items.asMap().entries.map((e) {
          return Column(
            children: [
              if (e.key > 0)
                Divider(height: 1, color: Colors.black.withOpacity(0.05)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    Icon(
                      e.value.icon,
                      size: 18,
                      color: AppTheme.secondaryText,
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.value.label,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppTheme.tertiaryText,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          e.value.value,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final items = [
      _SettingItem(Icons.settings_outlined, 'Account Settings', false, null),
      _SettingItem(Icons.notifications_outlined, 'Notifications', false, null),
      _SettingItem(Icons.help_outline_rounded, 'Help & Support', false, null),
      _SettingItem(Icons.logout_rounded, 'Sign Out', true, () => authProvider.logout()),
    ];

    return GlassCard(
      child: Column(
        children: items.asMap().entries.map((e) {
          return Column(
            children: [
              if (e.key > 0)
                Divider(height: 1, color: Colors.black.withOpacity(0.05)),
              GestureDetector(
                onTap: e.value.onTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Icon(
                        e.value.icon,
                        size: 18,
                        color: e.value.isDestructive
                            ? Colors.red.shade400
                            : AppTheme.secondaryText,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          e.value.label,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: e.value.isDestructive
                                ? Colors.red.shade400
                                : AppTheme.primaryText,
                          ),
                        ),
                      ),
                      if (!e.value.isDestructive)
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: AppTheme.tertiaryText,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  const _InfoItem(this.icon, this.label, this.value);
}

class _SettingItem {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback? onTap;
  const _SettingItem(this.icon, this.label, this.isDestructive, this.onTap);
}
