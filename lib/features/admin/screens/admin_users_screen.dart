import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/features/admin/providers/admin_provider.dart';

/// Admin User Management — view users, toggle status, filter by role.
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _roleFilter = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    if (admin.isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));

    final filtered = admin.users.where((u) {
      if (_roleFilter != 'all' && u.role != _roleFilter) return false;
      if (_searchQuery.isNotEmpty && !u.name.toLowerCase().contains(_searchQuery) && !u.email.toLowerCase().contains(_searchQuery)) return false;
      return true;
    }).toList();

    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
      child: Column(
        children: [
          _buildHeader(admin),
          _buildToolBar(admin),
          Expanded(child: _buildUserTable(filtered, admin)),
        ],
      ),
    );
  }

  Widget _buildHeader(AdminProvider admin) {
    final active = admin.users.where((u) => u.status == 'active').length;
    final suspended = admin.users.where((u) => u.status == 'suspended').length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 4),
      child: Row(
        children: [
          const Icon(Icons.people, color: AppTheme.primaryColor, size: 24),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('User Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Manage roles, access, and user status across the platform', style: TextStyle(fontSize: 12, color: Colors.white38)),
              ],
            ),
          ),
          _pill('${admin.users.length} Total', Colors.white54),
          const SizedBox(width: 8),
          _pill('$active Active', AppTheme.successColor),
          const SizedBox(width: 8),
          _pill('$suspended Suspended', AppTheme.errorColor),
        ],
      ),
    );
  }

  Widget _pill(String l, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: c.withValues(alpha: 0.25))),
      child: Text(l, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: c)),
    );
  }

  Widget _buildToolBar(AdminProvider admin) {
    final roles = ['all', ...admin.users.map((u) => u.role).toSet()];
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 8),
      child: Row(
        children: [
          // Search
          SizedBox(
            width: 260,
            height: 38,
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              style: const TextStyle(fontSize: 12, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search users...',
                hintStyle: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.3)),
                prefixIcon: Icon(Icons.search, size: 18, color: Colors.white.withValues(alpha: 0.3)),
                filled: true,
                fillColor: AppTheme.darkCard,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Role filter chips
          ...roles.map((r) {
            final sel = _roleFilter == r;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(r == 'all' ? 'All Roles' : r.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: sel ? Colors.white : Colors.white54)),
                selected: sel,
                selectedColor: AppTheme.primaryColor.withValues(alpha: 0.25),
                backgroundColor: AppTheme.darkCard,
                showCheckmark: false,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: BorderSide(color: sel ? AppTheme.primaryColor.withValues(alpha: 0.4) : Colors.white10),
                onSelected: (_) => setState(() => _roleFilter = r),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildUserTable(List<AdminUser> users, AdminProvider admin) {
    return Container(
      margin: const EdgeInsets.fromLTRB(28, 8, 28, 20),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 50, child: Text('', style: TextStyle(fontSize: 10))),
                const Expanded(flex: 3, child: Text('USER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1))),
                const Expanded(flex: 2, child: Text('EMAIL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1))),
                const SizedBox(width: 80, child: Text('ROLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1))),
                const SizedBox(width: 70, child: Text('STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1))),
                const SizedBox(width: 90, child: Text('LAST LOGIN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1))),
                const SizedBox(width: 60, child: Text('DEVICES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1))),
                const SizedBox(width: 60, child: Text('ACTIONS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1))),
                const SizedBox(width: 70, child: Text('ACTIONS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1))),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: users.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10, indent: 20, endIndent: 20),
              itemBuilder: (ctx, i) => _buildUserRow(users[i], admin),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRow(AdminUser u, AdminProvider admin) {
    final isActive = u.status == 'active';
    final roleColor = _roleColor(u.role);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Avatar
          SizedBox(
            width: 50,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Color(int.parse(u.avatarColor.replaceFirst('#', '0xFF'))).withValues(alpha: 0.2),
              child: Text(u.name[0].toUpperCase(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(int.parse(u.avatarColor.replaceFirst('#', '0xFF'))))),
            ),
          ),
          // Name
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                Text('Joined ${_timeAgo(u.createdAt)}', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.3))),
              ],
            ),
          ),
          // Email
          Expanded(
            flex: 2,
            child: Text(u.email, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)), overflow: TextOverflow.ellipsis),
          ),
          // Role badge
          SizedBox(
            width: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
              child: Text(u.role.toUpperCase(), textAlign: TextAlign.center, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: roleColor, letterSpacing: 0.4)),
            ),
          ),
          // Status
          SizedBox(
            width: 70,
            child: Row(
              children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: isActive ? AppTheme.successColor : AppTheme.errorColor, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(u.status, style: TextStyle(fontSize: 11, color: isActive ? AppTheme.successColor : AppTheme.errorColor)),
              ],
            ),
          ),
          // Last login
          SizedBox(width: 90, child: Text(_timeAgo(u.lastLogin), style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4)))),
          // Devices
          SizedBox(width: 60, child: Text('${u.devicesOwned}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.7)))),
          // Actions today
          SizedBox(width: 60, child: Text('${u.actionsToday}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.7)))),
          // Action buttons
          SizedBox(
            width: 70,
            child: Row(
              children: [
                Tooltip(
                  message: isActive ? 'Suspend' : 'Activate',
                  child: InkWell(
                    onTap: () => admin.toggleUserStatus(u.id),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: (isActive ? AppTheme.errorColor : AppTheme.successColor).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
                      child: Icon(isActive ? Icons.block : Icons.check_circle_outline, size: 14, color: isActive ? AppTheme.errorColor : AppTheme.successColor),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Tooltip(
                  message: 'View Details',
                  child: InkWell(
                    onTap: () => _showUserDetails(u),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
                      child: const Icon(Icons.visibility, size: 14, color: AppTheme.primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin': return AppTheme.errorColor;
      case 'owner': return AppTheme.primaryColor;
      case 'member': return AppTheme.successColor;
      case 'viewer': return AppTheme.secondaryColor;
      default: return Colors.white54;
    }
  }

  void _showUserDetails(AdminUser u) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Color(int.parse(u.avatarColor.replaceFirst('#', '0xFF'))).withValues(alpha: 0.2),
                  child: Text(u.name[0].toUpperCase(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(int.parse(u.avatarColor.replaceFirst('#', '0xFF'))))),
                ),
                const SizedBox(height: 14),
                Text(u.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(u.email, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
                const SizedBox(height: 18),
                _detailRow('Role', u.role.toUpperCase()),
                _detailRow('Status', u.status),
                _detailRow('Last Login', _timeAgo(u.lastLogin)),
                _detailRow('Created', _timeAgo(u.createdAt)),
                _detailRow('Devices Owned', '${u.devicesOwned}'),
                _detailRow('Actions Today', '${u.actionsToday}'),
                const SizedBox(height: 18),
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close', style: TextStyle(color: AppTheme.primaryColor))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String l, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(l, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)))),
          Expanded(child: Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70))),
        ],
      ),
    );
  }

  String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}
