import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/transactions_provider.dart';
import '../providers/dashboard_provider.dart';
import '../services/category_service.dart';
import '../widgets/transaction_form_sheet.dart';
import 'dashboard_screen.dart';
import 'transactions_screen.dart';
import 'categories_screen.dart';
import 'group_members_sheet.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    TransactionsScreen(),
    CategoriesScreen(),
  ];

  void _copyGroupCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.income, size: 18),
            const SizedBox(width: 8),
            Text('Codigo copiado: $code'),
          ],
        ),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddTransaction() async {
    final categories = await CategoryService.getCategories();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransactionFormSheet(
        categories: categories,
        onSave: (data) async {
          await context.read<TransactionsProvider>().createTransaction(data);
          if (mounted) {
            context.read<DashboardProvider>().loadAll();
          }
        },
      ),
    );
  }

  void _showMembers() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const GroupMembersSheet(),
    );
  }

  void _showGroupSwitcher() {
    final auth = context.read<AuthProvider>();
    final groups = auth.user?.groups ?? [];
    final activeGroup = auth.user?.activeGroup;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
            const Text('Mis Grupos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...groups.map((group) => ListTile(
                  leading: Icon(
                    Icons.group,
                    color: group.isActive
                        ? AppColors.primaryLight
                        : AppColors.textSecondary,
                  ),
                  title: Text(group.name,
                      style: TextStyle(
                        fontWeight:
                            group.isActive ? FontWeight.w600 : FontWeight.normal,
                        color: group.isActive ? AppColors.primaryLight : Colors.white,
                      )),
                  subtitle: Text(
                    group.role == 'owner' ? 'Admin' : 'Miembro',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  trailing: group.isActive
                      ? const Icon(Icons.check_circle,
                          color: AppColors.primaryLight, size: 20)
                      : null,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  onTap: () async {
                    if (!group.isActive) {
                      Navigator.pop(ctx);
                      await auth.switchGroup(group.id);
                      if (mounted) {
                        context.read<DashboardProvider>().loadAll();
                        context.read<TransactionsProvider>().load();
                      }
                    }
                  },
                )),
            if (activeGroup != null) ...[
              const Divider(color: AppColors.border),
              ListTile(
                leading: const Icon(Icons.copy, size: 20, color: AppColors.textSecondary),
                title: Text('Copiar codigo: ${activeGroup.code}',
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                onTap: () {
                  _copyGroupCode(activeGroup.code);
                  Navigator.pop(ctx);
                },
              ),
            ],
            ListTile(
              leading:
                  const Icon(Icons.add, size: 20, color: AppColors.primaryLight),
              title: const Text('Crear o unirse a grupo',
                  style: TextStyle(color: AppColors.primaryLight, fontSize: 14)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              onTap: () {
                Navigator.pop(ctx);
                // Navigate to setup group - the auth gate will handle it
                // We set needsGroup temporarily by navigating
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const _AddGroupScreen(),
                ));
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _showGroupSwitcher,
          child: Row(
            children: [
              const Icon(Icons.group, size: 20, color: AppColors.primaryLight),
              const SizedBox(width: 8),
              Text(auth.user?.activeGroupName ?? 'Cuentas Claras',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 4),
              const Icon(Icons.unfold_more,
                  size: 18, color: AppColors.textSecondary),
            ],
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Text(
                (auth.user?.name ?? 'U')[0].toUpperCase(),
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            color: AppColors.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            offset: const Offset(0, 48),
            onSelected: (value) {
              if (value == 'logout') {
                auth.logout();
              } else if (value == 'biometric') {
                auth.toggleBiometric(!auth.biometricEnabled);
              } else if (value == 'members') {
                _showMembers();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(auth.user?.name ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(auth.user?.email ?? '',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'members',
                child: Row(
                  children: [
                    Icon(Icons.people, size: 18, color: AppColors.primaryLight),
                    SizedBox(width: 8),
                    Text('Miembros del grupo'),
                  ],
                ),
              ),
              if (auth.biometricAvailable)
                PopupMenuItem(
                  value: 'biometric',
                  child: Row(
                    children: [
                      Icon(Icons.fingerprint,
                          size: 18,
                          color: auth.biometricEnabled
                              ? AppColors.income
                              : AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(auth.biometricEnabled
                            ? 'Desactivar bloqueo'
                            : 'Activar bloqueo biometrico'),
                      ),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: AppColors.expense),
                    SizedBox(width: 8),
                    Text('Cerrar sesion',
                        style: TextStyle(color: AppColors.expense)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _showAddTransaction,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_rounded),
                label: 'Transacciones'),
            BottomNavigationBarItem(
                icon: Icon(Icons.category_rounded), label: 'Categorias'),
          ],
        ),
      ),
    );
  }
}

/// Inline screen for adding a group without leaving the main app flow
class _AddGroupScreen extends StatefulWidget {
  const _AddGroupScreen();

  @override
  State<_AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<_AddGroupScreen> {
  final _controller = TextEditingController();
  bool _isCreate = true;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = context.read<AuthProvider>();
      if (_isCreate) {
        await auth.createGroup(_controller.text.trim());
      } else {
        await auth.joinGroup(_controller.text.trim());
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = context.read<AuthProvider>().extractError(e);
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Grupo')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Crear')),
                ButtonSegment(value: false, label: Text('Unirse')),
              ],
              selected: {_isCreate},
              onSelectionChanged: (v) => setState(() {
                _isCreate = v.first;
                _controller.clear();
                _error = null;
              }),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText:
                    _isCreate ? 'Nombre del grupo' : 'Codigo del grupo',
                prefixIcon:
                    Icon(_isCreate ? Icons.group_add : Icons.vpn_key),
              ),
              onSubmitted: (_) => _submit(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: const TextStyle(color: AppColors.expense, fontSize: 13)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(_isCreate ? 'Crear grupo' : 'Unirse al grupo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
