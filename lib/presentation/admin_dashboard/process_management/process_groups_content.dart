import 'package:flutter/material.dart';
import '../../../core/services/serv_users/user_service.dart';
import '../../../core/services/serv_actividades/process_group_service.dart';
import './components/user_selection_dialog.dart';
import '../../../data/models/user.dart';
import '../../../data/models/process_group.dart';

class ProcessGroupsContent extends StatefulWidget {
  const ProcessGroupsContent({super.key});

  @override
  State<ProcessGroupsContent> createState() => _ProcessGroupsContentState();
}

class _ProcessGroupsContentState extends State<ProcessGroupsContent> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();
  final ProcessGroupService _groupService = ProcessGroupService();
  final List<ProcessGroup> _groups = [];
  final _users = <User>[];
  Color _selectedColor = const Color(0xFF0067AC);
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadGroups();
  }

  Future<void> _loadUsers() async {
    try {
      debugPrint('🔄 Iniciando carga de usuarios...');
      final userService = UserService();
      final usersData = await userService.getUsers();

      debugPrint('📦 Datos de usuarios recibidos: ${usersData.length}');
      debugPrint('🔍 Primer usuario: ${usersData.firstOrNull}');

      setState(() {
        _users.clear();
        _users.addAll(
          usersData.map((data) {
            debugPrint('🔄 Convirtiendo usuario: $data');
            return User.fromMap(data);
          }),
        );
      });

      debugPrint('✅ Usuarios cargados exitosamente: ${_users.length}');
    } catch (e, stackTrace) {
      debugPrint('❌ Error cargando usuarios: $e');
      debugPrint('📚 StackTrace: $stackTrace');
    }
  }

  Future<void> _loadGroups() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final groups = await _groupService.getGroups();

      if (mounted) {
        setState(() {
          _groups.clear();
          _groups.addAll(groups);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.group_work, size: 32, color: Color(0xFF0067AC)),
              const SizedBox(width: 16),
              const Text(
                'Grupos de Trabajo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0067AC),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showCreateGroupDialog,
                icon: const Icon(Icons.add),
                label: const Text('Nuevo Grupo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0067AC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : _groups.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                          ),
                      itemCount: _groups.length,
                      itemBuilder:
                          (context, index) => _buildGroupCard(_groups[index]),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.group_add,
            size: 64,
            color: const Color(0xFF0067AC).withAlpha(100),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay grupos creados',
            style: TextStyle(
              fontSize: 24,
              color: Color(0xFF0067AC),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crea un grupo para empezar a administrar procesos',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(ProcessGroup group) {
    return InkWell(
      onTap: () => _showGroupDetailsDialog(group),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFFAFAFA),
            border: Border.all(color: group.color, width: 2),
            boxShadow: [
              BoxShadow(
                color: group.color.withAlpha(26), // 0.1 * 255 ≈ 26
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: group.color.withAlpha(26), // 0.1 * 255 ≈ 26
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.group, color: group.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        Text(
                          '${group.members.length} miembros',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildPopupMenu(group),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: group.color.withAlpha(13), // 0.05 * 255 ≈ 13
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  group.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(ProcessGroup group) {
    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      child: PopupMenuButton(
        icon: Icon(Icons.more_vert, color: group.color),
        position: PopupMenuPosition.under,
        offset: const Offset(0, 8),
        itemBuilder:
            (context) => [
              PopupMenuItem(
                value: 'members',
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: group.color.withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.group, color: group.color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Gestionar Usuarios',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'edit',
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.orange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Editar',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Eliminar',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
        onSelected: (value) {
          switch (value) {
            case 'members':
              _showManageUsersDialog(group);
              break;
            case 'edit':
              _editGroup(group);
              break;
            case 'delete':
              _deleteGroup(group);
              break;
          }
        },
      ),
    );
  }

  void _showGroupDetailsDialog(ProcessGroup group) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: 800,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: group.color.withAlpha(26), // 0.1 * 255 ≈ 26
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: group.color.withAlpha(26), // 0.1 * 255 ≈ 26
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.group, color: group.color, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                group.name,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: group.color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                group.description,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Miembros del Grupo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: group.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: group.members.length,
                      itemBuilder: (context, index) {
                        final user = group.members[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: group.color,
                            child: Text(
                              user.name[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(user.name),
                          subtitle: Text(user.email),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Cerrar',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Seleccionar Color'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildColorOption(const Color(0xFF0067AC)),
                      _buildColorOption(const Color(0xFFC6DA23)),
                      _buildColorOption(const Color(0xFFFF6B6B)),
                      _buildColorOption(const Color(0xFF9C27B0)),
                      _buildColorOption(const Color(0xFF4CAF50)),
                      _buildColorOption(const Color(0xFFFFA726)),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildColorOption(Color color) {
    return InkWell(
      onTap: () {
        setState(() => _selectedColor = color);
        Navigator.pop(context);
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(77), // 0.3 * 255 ≈ 77
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateGroupDialog() {
    _groupNameController.clear();
    _descriptionController.clear();
    _selectedColor = const Color(0xFF0067AC);

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0067AC).withAlpha(26),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0067AC).withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.group_add,
                          color: Color(0xFF0067AC),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Crear Nuevo Grupo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0067AC),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFormLabel('Nombre del Grupo'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _groupNameController,
                          decoration: _buildInputDecoration(
                            'Ingrese el nombre del grupo',
                          ),
                          validator:
                              (value) =>
                                  value?.isEmpty ?? true
                                      ? 'El nombre es requerido'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        _buildFormLabel('Descripción'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: _buildInputDecoration(
                            'Ingrese una descripción',
                          ),
                          maxLines: 3,
                          validator:
                              (value) =>
                                  value?.isEmpty ?? true
                                      ? 'La descripción es requerida'
                                      : null,
                        ),
                        const SizedBox(height: 24),
                        _buildFormLabel('Color del Grupo'),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _showColorPicker,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: _selectedColor.withAlpha(26),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _selectedColor),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.palette, color: _selectedColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Seleccionar Color',
                                  style: TextStyle(
                                    color: _selectedColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _createGroup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0067AC),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Crear Grupo'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _createGroup() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final newGroup = await _groupService.createGroup(
          name: _groupNameController.text,
          description: _descriptionController.text,
          color: _selectedColor,
        );

        if (!mounted) return;

        setState(() {
          _groups.add(newGroup);
        });

        if (!mounted) return;
        Navigator.pop(context);
        _showSnackBar('Grupo creado exitosamente');
      } catch (e) {
        if (!mounted) return;
        _showSnackBar('Error al crear grupo: $e', isError: true);
      }
    }
  }

  void _editGroup(ProcessGroup group) {
    _groupNameController.text = group.name;
    _descriptionController.text = group.description;
    _selectedColor = group.color;

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _selectedColor.withAlpha(26),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _selectedColor.withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.edit, color: _selectedColor),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Editar Grupo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _selectedColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFormLabel('Nombre del Grupo'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _groupNameController,
                          decoration: _buildInputDecoration(
                            'Ingrese el nombre del grupo',
                          ),
                          validator:
                              (value) =>
                                  value?.isEmpty ?? true
                                      ? 'El nombre es requerido'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        _buildFormLabel('Descripción'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: _buildInputDecoration(
                            'Ingrese una descripción',
                          ),
                          maxLines: 3,
                          validator:
                              (value) =>
                                  value?.isEmpty ?? true
                                      ? 'La descripción es requerida'
                                      : null,
                        ),
                        const SizedBox(height: 24),
                        _buildFormLabel('Color del Grupo'),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _showColorPicker,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: _selectedColor.withAlpha(26),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _selectedColor),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.palette, color: _selectedColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Cambiar Color',
                                  style: TextStyle(
                                    color: _selectedColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              final updatedGroup = ProcessGroup(
                                id: group.id,
                                name: _groupNameController.text,
                                description: _descriptionController.text,
                                color: _selectedColor,
                                members: group.members,
                              );

                              final result = await _groupService.updateGroup(
                                updatedGroup,
                              );

                              if (!mounted) return;

                              setState(() {
                                final index = _groups.indexWhere(
                                  (g) => g.id == group.id,
                                );
                                if (index != -1) {
                                  _groups[index] = result;
                                }
                              });

                              if (!mounted) return;
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              _showSnackBar('Grupo actualizado exitosamente');
                            } catch (e) {
                              if (!mounted) return;
                              if (!context.mounted) return;
                              _showSnackBar(
                                'Error al actualizar grupo: $e',
                                isError: true,
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Guardar Cambios'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _showManageUsersDialog(ProcessGroup group) async {
    try {
      debugPrint('🔄 Abriendo diálogo de gestión de usuarios');
      debugPrint('📊 Estado actual del grupo:');
      debugPrint('- ID: ${group.id}');
      debugPrint('- Nombre: ${group.name}');
      debugPrint('- Miembros actuales: ${group.members.length}');
      debugPrint('- Total usuarios disponibles: ${_users.length}');

      final result = await showDialog<List<User>>(
        context: context,
        builder:
            (context) => UserSelectionDialog(
              allUsers: _users,
              selectedUsers: group.members,
              groupColor: group.color,
              groupName: group.name,
            ),
      );

      if (result != null && mounted) {
        try {
          final updatedGroup = await _groupService.updateGroupMembers(
            group.id,
            result,
          );

          if (!mounted) return;

          setState(() {
            final index = _groups.indexWhere((g) => g.id == group.id);
            if (index != -1) {
              _groups[index] = updatedGroup;
            }
          });

          debugPrint('✅ Grupo actualizado con ${result.length} miembros');
          debugPrint(
            '📊 IDs de miembros: ${result.map((u) => u.id).join(", ")}',
          );
        } catch (e) {
          if (!mounted) return;
          _showSnackBar('Error al actualizar miembros: $e', isError: true);
        }
      }
    } catch (e, stackTrace) {
      if (!mounted) return;
      debugPrint('❌ Error en gestión de usuarios: $e');
      debugPrint('📚 StackTrace: $stackTrace');
    }
  }

  void _deleteGroup(ProcessGroup group) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.red),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Confirmar eliminación',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Está seguro que desea eliminar el grupo "${group.name}"?',
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Esta acción no se puede deshacer.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await _groupService.deleteGroup(group.id);

                    if (!mounted) return;
                    setState(() {
                      _groups.removeWhere((g) => g.id == group.id);
                    });

                    if (!dialogContext.mounted) return;
                    Navigator.pop(dialogContext);
                    _showSnackBar('Grupo eliminado exitosamente');
                  } catch (e) {
                    if (!mounted) return;
                    if (!dialogContext.mounted) return;
                    Navigator.pop(dialogContext);
                    _showSnackBar('Error al eliminar grupo: $e', isError: true);
                  }
                },
                icon: const Icon(Icons.delete_outline, size: 20),
                label: const Text('Eliminar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildFormLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF64748B),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF0067AC), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red[400]!),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red[400]!, width: 2),
      ),
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
