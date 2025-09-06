import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import './user_admin/admin_users_page.dart';
import 'pausa_activa/create_activity_content.dart';
import 'pausa_activa/edit_activities_content.dart';
import 'pausa_activa/create_plan_content.dart';
import 'pausa_activa/edit_plans_content.dart';
import 'pausa_activa/history_content.dart';
import 'notifications/notification_content.dart';
import 'notifications/saved_notification_plans.dart'; // Nuevo import
import 'process_management/process_upload_content.dart';
import 'process_management/process_groups_content.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Widget? _currentContent;
  bool _pausaActivaExpanded = false;
  bool _notificationsExpanded = false;
  bool _processManagementExpanded = false; // Add this line
  bool _isCollapsed = false; // New state for sidebar collapse

  void _handleMenuItemClick() {
    if (_isCollapsed) {
      setState(() => _isCollapsed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isCollapsed ? 65 : 250,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0067AC).withAlpha(26),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      axis: Axis.horizontal,
                      child: child,
                    ),
                  ),
                  child: _isCollapsed
                      ? _SidebarHeaderCollapsed(
                          key: const ValueKey('collapsed'),
                          onExpand: () => setState(() => _isCollapsed = false),
                        )
                      : _SidebarHeaderExpanded(
                          key: const ValueKey('expanded'),
                          onCollapse: () => setState(() => _isCollapsed = true),
                        ),
                ),
                if (!_isCollapsed) ...[
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 16),
                ],
                Expanded(child: _buildMenuItems()),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                if (_isCollapsed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildExitButton(),
                  )
                else
                  _buildExitButton(),
              ],
            ),
          ),
          Expanded(child: _buildMainContent()),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            _buildMenuItem(
              icon: Icons.people,
              title: 'Usuarios',
              onTap: () => setState(() {
                _currentContent = const AdminUsersPage();
              }),
            ),
            const SizedBox(height: 4),
            _buildExpandableMenuItem(
              icon: Icons.fitness_center,
              title: 'Administrar Actividades',
              isExpanded: _pausaActivaExpanded,
              onExpansionChanged: (value) {
                setState(() => _pausaActivaExpanded = value);
              },
              children: [
                _buildSubMenuItem(
                  title: 'Crear Actividad',
                  icon: Icons.add_circle_outline,
                  onTap: () => setState(() {
                    _currentContent = const CreateActivityContent();
                  }),
                ),
                _buildSubMenuItem(
                  title: 'Editar Actividades',
                  icon: Icons.edit_note,
                  onTap: () => setState(() {
                    _currentContent = const EditActivitiesContent();
                  }),
                ),
                _buildSubMenuItem(
                  title: 'Crear Plan de Pausas',
                  icon: Icons.playlist_add,
                  onTap: () => setState(() {
                    _currentContent = const CreatePlanContent();
                  }),
                ),
                _buildSubMenuItem(
                  title: 'Planes Creados',
                  icon: Icons.playlist_play,
                  onTap: () => setState(() {
                    _currentContent = const EditPlansContent();
                  }),
                ),
                _buildSubMenuItem(
                  title: 'Historial de Pausas',
                  icon: Icons.history,
                  onTap: () => setState(() {
                    _currentContent = const HistoryContent();
                  }),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _buildExpandableMenuItem(
              icon: Icons.notifications,
              title: 'Notificaciones',
              isExpanded: _notificationsExpanded,
              onExpansionChanged: (value) {
                setState(() => _notificationsExpanded = value);
              },
              children: [
                _buildSubMenuItem(
                  title: 'Crear Plan de Notificaciones',
                  icon: Icons.add_alarm,
                  onTap: () => setState(() {
                    _currentContent = const NotificationContent();
                  }),
                ),
                _buildSubMenuItem(
                  title: 'Planes Guardados',
                  icon: Icons.access_time,
                  onTap: () => setState(() {
                    _currentContent = const SavedNotificationPlans();
                  }),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _buildExpandableMenuItem(
              icon: Icons.cloud_upload,
              title: 'Gestión de Procesos',
              isExpanded: _processManagementExpanded,
              onExpansionChanged: (value) {
                setState(() => _processManagementExpanded = value);
              },
              children: [
                _buildSubMenuItem(
                  title: 'Subir Procesos',
                  icon: Icons.upload_file,
                  onTap: () => setState(() {
                    _currentContent = const ProcessUploadContent();
                  }),
                ),
                _buildSubMenuItem(
                  title: 'Grupos de Trabajo',
                  icon: Icons.group_work,
                  onTap: () => setState(() {
                    _currentContent = const ProcessGroupsContent();
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    final color = isDisabled ? Colors.grey : const Color(0xFF0067AC);
    
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        hoverColor: const Color(0xFF0067AC).withAlpha(13),
        splashColor: const Color(0xFF0067AC).withAlpha(26),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 45,
          padding: EdgeInsets.symmetric(
            horizontal: _isCollapsed ? 8 : 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: _isCollapsed ? 22 : 20,
              ),
              if (!_isCollapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableMenuItem({
    required IconData icon,
    required String title,
    required bool isExpanded,
    required ValueChanged<bool> onExpansionChanged,
    required List<Widget> children,
  }) {
    if (_isCollapsed) {
      return Tooltip(
        message: title,
        child: _buildMenuItem(
          icon: icon,
          title: title,
          onTap: () {
            _handleMenuItemClick();
            onExpansionChanged(!isExpanded);
          },
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isExpanded 
              ? const Color(0xFF0067AC).withAlpha(13)
              : Colors.transparent,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ExpansionTile(
            onExpansionChanged: onExpansionChanged,
            maintainState: true,
            leading: SizedBox(
              width: 24,
              height: 24,
              child: Icon(
                icon,
                color: isExpanded ? const Color(0xFF0067AC) : Colors.grey[700],
                size: 20,
              ),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: isExpanded ? const Color(0xFF0067AC) : Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            tilePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            childrenPadding: EdgeInsets.zero,
            expandedAlignment: Alignment.topLeft,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildSubMenuItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    if (_isCollapsed) {
      return Tooltip(
        message: title,
        child: _buildMenuItem(
          icon: icon,
          title: title,
          onTap: () {
            _handleMenuItemClick();
            onTap();
          },
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: const Color(0xFF0067AC).withAlpha(13),
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.only(left: 40, right: 8),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Icon(
                  icon,
                  color: const Color(0xFF0067AC),
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF0067AC),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExitButton() {
    if (_isCollapsed) {
      return Container(
        margin: const EdgeInsets.all(8),
        child: Material(
          color: Colors.red.shade400,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white, size: 20),
            onPressed: () => _showExitConfirmation(context),
            padding: const EdgeInsets.all(12),
            splashColor: Colors.redAccent,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton.icon(
        onPressed: () => _showExitConfirmation(context),
        icon: const Icon(Icons.exit_to_app, color: Colors.white, size: 20),
        label: const Text(
          'Cerrar Sesión',
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade400,
          padding: const EdgeInsets.symmetric(vertical: 12),
          minimumSize: const Size(double.infinity, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Seguro que quieres salir?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, AdminRoutes.login);
              },
              child: const Text('Salir'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMainContent() {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          // Header
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                const Text(
                  'Bienvenido, Administrador',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  color: const Color(0xFF0067AC),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // Área de contenido
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: _currentContent ?? const _WelcomeContent(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarHeaderExpanded extends StatelessWidget {
  final VoidCallback onCollapse;
  const _SidebarHeaderExpanded({super.key, required this.onCollapse});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Image.asset(
              'assets/imagenes/LOGOECOBREACK.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'ECOBREACK',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0067AC),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Panel Admin',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 24,
            height: 24,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onCollapse,
                child: const Icon(
                  Icons.chevron_left,
                  size: 16,
                  color: Color(0xFF0067AC),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarHeaderCollapsed extends StatelessWidget {
  final VoidCallback onExpand;
  const _SidebarHeaderCollapsed({super.key, required this.onExpand});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Image.asset(
              'assets/imagenes/LOGOECOBREACK.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 20,
            height: 20,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onExpand,
                child: const Icon(
                  Icons.chevron_right,
                  size: 14,
                  color: Color(0xFF0067AC),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeContent extends StatelessWidget {
  const _WelcomeContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.admin_panel_settings,
            size: 64,
            color: Color(0xFF0067AC).withAlpha(100),
          ),
          const SizedBox(height: 16),
          const Text(
            'Bienvenido al Panel de Administración',
            style: TextStyle(
              fontSize: 24,
              color: Color(0xFF0067AC),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Selecciona una opción del menú para comenzar',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
