import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.bar_chart_rounded,           label: 'Insights'),
      _NavItem(icon: Icons.format_list_bulleted_rounded, label: 'Tasks'),
      _NavItem(icon: Icons.home_outlined,               label: 'Home'),
      _NavItem(icon: Icons.chat_bubble_outline_rounded, label: 'Chat'),
      _NavItem(icon: Icons.person_outline_rounded,      label: 'Profile'),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: Container(
          // Shadow OUTSIDE the ClipRRect — critical so it renders correctly
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.navRadius),
            boxShadow: AppTheme.navShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.navRadius),
            child: BackdropFilter(
              // Real blur creates glass against any content that scrolls under nav
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                height: AppConstants.navHeight,
                decoration: BoxDecoration(
                  // Near-opaque white — glass is subtle but real
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius:
                      BorderRadius.circular(AppConstants.navRadius),
                  border: Border.all(
                    color: const Color(0xFFE8E8EC),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(items.length, (i) {
                    return _NavButton(
                      item: items[i],
                      isSelected: i == currentIndex,
                      onTap: () => onTap(i),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _NavButton extends StatefulWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.80,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _ctrl,
        child: SizedBox(
          width: 52,
          height: AppConstants.navHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with opacity
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: widget.isSelected ? 1.0 : 0.30,
                child: Icon(
                  widget.item.icon,
                  size: AppConstants.navIconSize,
                  color: AppTheme.primaryText,
                ),
              ),
              const SizedBox(height: 6),
              // Selected dot indicator — clean and minimal
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: widget.isSelected ? 4 : 0,
                height: widget.isSelected ? 4 : 0,
                decoration: BoxDecoration(
                  color: AppTheme.primaryText,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
