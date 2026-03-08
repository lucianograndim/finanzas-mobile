import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/group.dart';
import '../providers/auth_provider.dart';
import '../services/group_service.dart';

class GroupMembersSheet extends StatefulWidget {
  const GroupMembersSheet({super.key});

  @override
  State<GroupMembersSheet> createState() => _GroupMembersSheetState();
}

class _GroupMembersSheetState extends State<GroupMembersSheet> {
  List<GroupMember>? _members;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final auth = context.read<AuthProvider>();
    final groupId = auth.user?.activeGroupId;
    if (groupId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      _members = await GroupService.getGroupMembers(groupId);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final activeGroup = auth.user?.activeGroup;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Miembros del Grupo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )
          else if (activeGroup == null)
            const Text('No se pudo cargar la informacion',
                style: TextStyle(color: AppColors.textSecondary))
          else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.group, color: AppColors.primaryLight),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(activeGroup.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text('Codigo: ${activeGroup.code}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary)),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: activeGroup.code));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Codigo copiado'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: const Icon(Icons.copy,
                                  size: 14, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_members != null && _members!.isNotEmpty)
              ...(_members!.map((m) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            m.name.isNotEmpty
                                ? m.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                              Text(m.email,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        if (m.role == 'owner')
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('Admin',
                                style: TextStyle(
                                    fontSize: 11, color: AppColors.primaryLight)),
                          ),
                      ],
                    ),
                  )))
            else
              const Text('No hay miembros',
                  style: TextStyle(color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
