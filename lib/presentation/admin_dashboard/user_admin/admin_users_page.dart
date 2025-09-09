import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_service.dart';
import 'user_stats_dialog.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  String _searchQuery = '';
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await ApiService().get('/admin/usersAll');
      final users = (response['data'] as List).cast<Map<String, dynamic>>();

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'No disponible';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('d MMMM, y - HH:mm', 'es_ES').format(date);
    } catch (e) {
      return dateString;
    }
  }

  void _showUserDetails(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Container(
              width: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0067AC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 30,
                          child: Text(
                            (user['name'] ?? user['displayName'] ?? 'U')[0]
                                .toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontFamily: 'HelveticaRounded',
                              color: Color(0xFF0067AC),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['name'] ??
                                    user['displayName'] ??
                                    'Usuario',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'HelveticaRounded',
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                user['email'] ?? 'Sin correo',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _infoRow('UID', user['uid'] ?? 'N/A'),
                        _infoRow(
                          'Fecha de registro',
                          user['creationTime'] ?? 'N/A',
                        ),
                        _infoRow(
                          'Último acceso',
                          user['lastSignInTime'] ?? 'N/A',
                        ),
                        _infoRow('Estado', user['status'] ?? 'N/A'),
                        if (user['gender'] != null)
                          _infoRow('Género', user['gender']),
                        if (user['lastName'] != null)
                          _infoRow('Apellido', user['lastName']),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red.shade400,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'Cerrar',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'HelveticaRounded',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showUserStats(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder:
          (context) => UserStatsDialog(
            userId: user['uid'],
            userName: user['name'] ?? user['displayName'] ?? 'Usuario',
          ),
    );
  }

  Widget _infoRow(String label, String value) {
    String displayValue = value;

    // Traducir estados
    if (label == 'Estado') {
      displayValue = value == 'active' ? 'Activo' : 'Inactivo';
    }
    // Formatear fechas
    else if (label == 'Fecha de registro' || label == 'Último acceso') {
      displayValue = _formatDate(value);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0067AC),
              fontFamily: 'HelveticaRounded',
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: const TextStyle(fontFamily: 'HelveticaRounded'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers =
        _users.where((user) {
          final searchLower = _searchQuery.toLowerCase();
          final name =
              (user['name'] ?? user['displayName'] ?? '')
                  .toString()
                  .toLowerCase();
          final email = (user['email'] ?? '').toString().toLowerCase();
          return name.contains(searchLower) || email.contains(searchLower);
        }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0067AC).withAlpha(26), // 0.1 * 255 ≈ 26
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF0067AC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Gestión de Usuarios',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'HelveticaRounded',
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 400, // Aumentado de 300 a 400
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Buscar usuarios por nombre o correo...',
                      hintStyle: TextStyle(
                        color: const Color(0xFF0067AC).withAlpha(128),
                        fontFamily: 'HelveticaRounded',
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: const Color(0xFF0067AC).withAlpha(128),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16), // Agregado espacio al final
              ],
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0067AC),
                      ),
                    )
                    : _error != null
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: $_error',
                            style: TextStyle(
                              color: Colors.red.shade300,
                              fontFamily: 'HelveticaRounded',
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF0067AC,
                                ).withAlpha(13), // 0.05 * 255 ≈ 13
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF0067AC),
                              radius: 25,
                              child: Text(
                                (user['name'] ?? user['displayName'] ?? 'U')[0]
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'HelveticaRounded',
                                ),
                              ),
                            ),
                            title: Text(
                              user['name'] ?? user['displayName'] ?? 'Usuario',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'HelveticaRounded',
                                color: Color(0xFF0067AC),
                              ),
                            ),
                            subtitle: Text(
                              user['email'] ?? 'Sin correo',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontFamily: 'HelveticaRounded',
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildActionButton(
                                  icon: Icons.bar_chart,
                                  color: const Color(0xFFC6DA23),
                                  onPressed:
                                      () => _showUserStats(context, user),
                                ),
                                const SizedBox(width: 8),
                                _buildActionButton(
                                  icon: Icons.info_outline,
                                  color: const Color(0xFF0067AC),
                                  onPressed:
                                      () => _showUserDetails(context, user),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha(26), // 0.1 * 255 ≈ 26
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        tooltip: icon == Icons.bar_chart ? 'Ver estadísticas' : 'Ver detalles',
      ),
    );
  }
}
