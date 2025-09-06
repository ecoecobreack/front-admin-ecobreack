import 'package:flutter/material.dart';
import '../../../../data/models/user.dart';

class UserSelectionDialog extends StatefulWidget {
  final List<User> allUsers;
  final List<User> selectedUsers;
  final Color groupColor;
  final String groupName;

  const UserSelectionDialog({
    super.key,
    required this.allUsers,
    required this.selectedUsers,
    required this.groupColor,
    required this.groupName,
  });

  @override
  State<UserSelectionDialog> createState() => _UserSelectionDialogState();
}

class _UserSelectionDialogState extends State<UserSelectionDialog> {
  final searchController = TextEditingController();
  String searchQuery = '';
  late List<User> selectedUsers;

  @override
  void initState() {
    super.initState();
    debugPrint('🔄 Iniciando UserSelectionDialog');
    debugPrint('📊 Estado inicial:');
    debugPrint('- Total usuarios: ${widget.allUsers.length}');
    debugPrint('- Usuarios seleccionados: ${widget.selectedUsers.length}');
    selectedUsers = List<User>.from(widget.selectedUsers);
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = searchQuery.isEmpty
        ? widget.allUsers
        : widget.allUsers.where((user) {
            final name = user.name.toLowerCase();
            final email = user.email.toLowerCase();
            final query = searchQuery.toLowerCase();
            return name.contains(query) || email.contains(query);
          }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        height: 600,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.groupColor.withAlpha(26),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.groupColor.withAlpha(13),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.group, color: widget.groupColor, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Gestionar Usuarios - ${widget.groupName}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: widget.groupColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSearchBar(),
                ],
              ),
            ),
            // Selection Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: _buildSelectionHeader(),
            ),
            // User List
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildUserList(filteredUsers),
              ),
            ),
            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: _buildActions(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Buscar usuarios...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: widget.groupColor),
          border: InputBorder.none,
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    searchController.clear();
                    setState(() => searchQuery = '');
                  },
                )
              : null,
        ),
        onChanged: (value) => setState(() => searchQuery = value),
      ),
    );
  }

  Widget _buildSelectionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.groupColor.withAlpha(13),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people, color: widget.groupColor, size: 16),
              const SizedBox(width: 8),
              Text(
                'Seleccionados: ${selectedUsers.length}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: widget.groupColor,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (selectedUsers.isNotEmpty)
          TextButton.icon(
            onPressed: () => setState(() => selectedUsers.clear()),
            icon: Icon(Icons.clear_all, color: widget.groupColor, size: 20),
            label: Text(
              'Limpiar selección',
              style: TextStyle(color: widget.groupColor),
            ),
          ),
      ],
    );
  }

  Widget _buildUserList(List<User> users) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              searchQuery.isEmpty ? Icons.group_off : Icons.search_off,
              size: 48,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty
                  ? 'No hay usuarios disponibles'
                  : 'No se encontraron usuarios',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) => _buildUserItem(users[index]),
      padding: const EdgeInsets.symmetric(vertical: 8),
    );
  }

  Widget _buildUserItem(User user) {
    final isSelected = selectedUsers.any((selected) => selected.id == user.id);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: isSelected ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isSelected ? widget.groupColor : Colors.grey[200],
          child: Text(
            _getInitials(user.name),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(
          user.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? widget.groupColor : Colors.grey[800],
          ),
        ),
        subtitle: Text(
          user.email,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
        trailing: Checkbox(
          value: isSelected,
          onChanged: (_) => _toggleUserSelection(user),
          activeColor: widget.groupColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        onTap: () => _toggleUserSelection(user),
        selected: isSelected,
        selectedTileColor: widget.groupColor.withAlpha(13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
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
      const SizedBox(width: 12),
      ElevatedButton(
        onPressed: () => Navigator.pop(context, selectedUsers),
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
          elevation: 2,
        ),
        child: const Text(
          'Guardar',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    ];
  }

  void _toggleUserSelection(User user) {
    debugPrint('🔄 Toggle selección de usuario:');
    debugPrint('- ID: ${user.id}');
    debugPrint('- Nombre: ${user.name}');

    setState(() {
      final isCurrentlySelected = selectedUsers.any((selected) => selected.id == user.id);
      debugPrint('- ¿Actualmente seleccionado?: $isCurrentlySelected');

      if (isCurrentlySelected) {
        selectedUsers.removeWhere((selected) => selected.id == user.id);
        debugPrint('❌ Usuario removido de la selección');
      } else {
        selectedUsers.add(user);
        debugPrint('✅ Usuario añadido a la selección');
      }

      debugPrint('📊 Total seleccionados: ${selectedUsers.length}');
      debugPrint('📊 IDs seleccionados: ${selectedUsers.map((u) => u.id).join(", ")}');
    });
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    return name[0].toUpperCase();
  }
}
