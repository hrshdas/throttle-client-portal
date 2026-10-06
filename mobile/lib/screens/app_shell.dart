import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/notification_provider.dart';
import '../screens/home/home_screen.dart';
import '../screens/insights/insights_screen.dart';
import '../screens/tasks/tasks_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../widgets/bottom_navigation.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 2; // Home

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final isAdmin = auth.userRole == 'THROTTLE_ADMIN' || auth.userRole == 'THROTTLE_STAFF';
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
      Provider.of<ChatProvider>(context, listen: false).loadChat(isAdmin: isAdmin);
      Provider.of<NotificationProvider>(context, listen: false).loadNotifications();
    });
  }

  final _screens = const [
    InsightsScreen(),
    TasksScreen(),
    HomeScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      // No gradient — clean flat background matches the reference exactly
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
