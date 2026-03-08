import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';

enum _GroupMode { choose, create, join }

class SetupGroupScreen extends StatefulWidget {
  const SetupGroupScreen({super.key});

  @override
  State<SetupGroupScreen> createState() => _SetupGroupScreenState();
}

class _SetupGroupScreenState extends State<SetupGroupScreen> {
  _GroupMode _mode = _GroupMode.choose;
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _createGroup() async {
    if (_controller.text.trim().isEmpty) {
      setState(() => _error = 'Ingresa un nombre para el grupo');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().createGroup(_controller.text.trim());
    } catch (e) {
      setState(() {
        _error = context.read<AuthProvider>().extractError(e);
        _loading = false;
      });
    }
  }

  Future<void> _joinGroup() async {
    if (_controller.text.trim().isEmpty) {
      setState(() => _error = 'Ingresa el codigo del grupo');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AuthProvider>().joinGroup(_controller.text.trim());
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
    final auth = context.watch<AuthProvider>();
    final hasGroups = auth.user?.groups.isNotEmpty ?? false;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.group, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(hasGroups ? 'Agregar Grupo' : 'Configurar Grupo',
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Crea un grupo nuevo o unite a uno existente con un codigo',
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.expense.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.expense.withValues(alpha: 0.3)),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(color: AppColors.expense)),
                ),
              if (_mode == _GroupMode.choose) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() {
                      _mode = _GroupMode.create;
                      _error = null;
                      _controller.clear();
                    }),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear grupo nuevo'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() {
                      _mode = _GroupMode.join;
                      _error = null;
                      _controller.clear();
                    }),
                    icon: const Icon(Icons.login),
                    label: const Text('Unirse con codigo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
              if (_mode == _GroupMode.create) ...[
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del grupo',
                    prefixIcon: Icon(Icons.group_add),
                  ),
                  onSubmitted: (_) => _createGroup(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _createGroup,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Crear grupo'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setState(() {
                    _mode = _GroupMode.choose;
                    _error = null;
                  }),
                  child: const Text('Volver'),
                ),
              ],
              if (_mode == _GroupMode.join) ...[
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Codigo del grupo',
                    prefixIcon: Icon(Icons.vpn_key),
                  ),
                  onSubmitted: (_) => _joinGroup(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _joinGroup,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Unirse al grupo'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setState(() {
                    _mode = _GroupMode.choose;
                    _error = null;
                  }),
                  child: const Text('Volver'),
                ),
              ],
              const SizedBox(height: 24),
              if (!hasGroups)
                TextButton(
                  onPressed: () => context.read<AuthProvider>().logout(),
                  child: const Text('Cerrar sesion',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
