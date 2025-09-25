import 'package:flutter/material.dart';
import 'package:sst_admin/core/services/api_service.dart';
import 'package:sst_admin/core/services/serv_users/auth_service.dart';

class MotivosPage extends StatefulWidget {
  const MotivosPage({super.key});

  @override
  State<MotivosPage> createState() => _MotivosPageState();
}

class _MotivosPageState extends State<MotivosPage> {
  bool _loadingMotivos = false;
  bool _loadingMotivosUsuarios = false;
  ApiService api = ApiService();

  // Simulación de motivos
  List _motivos = [];

  // Simulación de motivos enviados por usuarios
  List<Map<String, dynamic>> _motivosUsuarios = [];

  @override
  void initState() {
    super.initState();
    _loadMotivos();
    _loadMotivosUsuarios();
    // _motivos = _loadMotivos();
  }

  Future<void> _loadMotivos() async {
    setState(() {
      _loadingMotivos = true;
    });
    final response = await api.get('/admin/motivos');
    setState(() {
      _motivos = (response['data'] as List?) ?? [];
      _loadingMotivos = false;
      debugPrint(_motivos.toString());
    });
  }

  Future<void> _loadMotivosUsuarios() async {
    setState(() {
      _loadingMotivosUsuarios = true;
    });
    final response = await api.get('/admin/motivos/comentarios');
    setState(() {
      _motivosUsuarios =
          (response['data'] as List?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [];
      _loadingMotivosUsuarios = false;
      debugPrint(_motivosUsuarios.toString());
    });
  }

  void _saveMotivo(
    String titulo,
    String descripcion,
    GlobalKey<FormState> formKey,
  ) async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      setState(() {
        _motivos.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'titulo': titulo,
          'descripcion': descripcion,
          'estado': true,
        });
      });
    }

    final token = await AuthService.getAdminToken();
    if (token == null) {
      throw Exception('No se encontró token de autenticación');
    }

    final response = await api.post(
      endpoint: '/admin/motivos', // Sin slash inicial
      data: {
        'titulo': titulo,
        'descripcion': descripcion,
        'estado': true, // Nuevo motivo activo por defecto
      },
      token: token,
    );

    Navigator.of(context).pop(); // Cerrar el diálogo

    if (response['status'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al crear el motivo. Intente nuevamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Guardado exitosamente.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _crearMotivo() async {
    final formKey = GlobalKey<FormState>();
    final TextEditingController tituloController = TextEditingController();
    final TextEditingController descripcionController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Crear Motivo',
            style: TextStyle(fontSize: 22, color: Color(0xFF0067AC)),
          ),
          content: SizedBox(
            width: 400, // Más ancho
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Motivo',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 156, 156, 156),
                        fontSize: 18, // Más grande
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF0067AC)),
                      ),
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Ingrese un título'
                                : null,
                    cursorColor: Color(0xFF0067AC),
                    style: const TextStyle(
                      color: Color(0xFF0067AC),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 24), // Más espacio
                  TextFormField(
                    controller: descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción (máx. 70 caracteres)',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 156, 156, 156),
                        fontSize: 18, // Más grande
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF0067AC)),
                      ),
                    ),
                    maxLength: 70,
                    maxLines: 1, // Más alto
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Ingrese una descripción'
                                : value.length > 70
                                ? 'Máximo 70 caracteres'
                                : null,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(fontSize: 16, color: Color(0xFF0067AC)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0067AC),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _saveMotivo(
                    tituloController.text.trim(),
                    descripcionController.text.trim(),
                    formKey,
                  );
                }
              },
              child: const Text(
                'Guardar',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _editarMotivo(Map motivo) async {
    final formKey = GlobalKey<FormState>();
    final TextEditingController tituloController = TextEditingController(
      text: motivo['titulo'] ?? '',
    );
    final TextEditingController descripcionController = TextEditingController(
      text: motivo['descripcion'] ?? '',
    );
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Editar Motivo',
            style: TextStyle(fontSize: 22, color: Color(0xFF0067AC)),
          ),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Motivo',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 156, 156, 156),
                        fontSize: 18,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF0067AC)),
                      ),
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Ingrese un título'
                                : null,
                    cursorColor: Color(0xFF0067AC),
                    style: const TextStyle(
                      color: Color(0xFF0067AC),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción (máx. 70 caracteres)',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 156, 156, 156),
                        fontSize: 18,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF0067AC)),
                      ),
                    ),
                    maxLength: 70,
                    maxLines: 1,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Ingrese una descripción'
                                : value.length > 70
                                ? 'Máximo 70 caracteres'
                                : null,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(fontSize: 16, color: Color(0xFF0067AC)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0067AC),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final token = await AuthService.getAdminToken();
                  if (token == null) {
                    throw Exception('No se encontró token de autenticación');
                  }

                  debugPrint(motivo.toString());
                  setState(() {
                    motivo['titulo'] = tituloController.text.trim();
                    motivo['descripcion'] = descripcionController.text.trim();
                  });

                  final response = await api.put(
                    endpoint: '/admin/motivos/${motivo['id']}',
                    data: {
                      'titulo': tituloController.text.trim(),
                      'descripcion': descripcionController.text.trim(),
                      'estado': motivo['estado'] ?? true,
                    },
                    token: token,
                  );
                  if (response['status'] != true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error al guardar los cambios.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Guardado exitosamente.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.of(context).pop();
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Guardado exitosamente.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text(
                'Guardar',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _actualizarEstadoMotivo(value, motivo) async {
    setState(() {
      motivo['estado'] = value;
    });
    final token = await AuthService.getAdminToken();
    if (token == null) {
      throw Exception('No se encontró token de autenticación');
    }

    final response = await api.put(
      endpoint: '/admin/motivos/${motivo['id']}', // Sin slash inicial
      data: {'estado': value},
      token: token,
    );

    if (response['status'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar el motivo.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? 'Motivo activado' : 'Motivo desactivado'),
        backgroundColor: value ? Colors.green : Colors.red,
      ),
    );
  }

  void _borrarMotivo(id) async {
    setState(() {
      _motivos.removeWhere((m) => m['id'] == id);
    });

    final token = await AuthService.getAdminToken();
    if (token == null) {
      throw Exception('No se encontró token de autenticación');
    }

    final response = await api.delete(
      endpoint: 'admin/motivos/$id', // Sin slash inicial
      token: token,
    );

    if (response['status'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Motivo no pudo ser eliminado.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Motivo eliminado exitosamente.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(_motivos.toString());
    // Mostrar todos los motivos recibidos, incluso si hay duplicados
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Gestión de Motivos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
          ), // Tamaño ajustado
        ),
        backgroundColor: const Color(0xFF0067AC),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24), // Bordes inferiores redondeados
          ),
        ),
        toolbarHeight: 90, // Altura ajustada
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0067AC),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Crear Motivo',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: _crearMotivo,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Motivos del sistema',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child:
                  _loadingMotivos
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        itemCount: _motivos.length,
                        itemBuilder: (context, index) {
                          final motivo = _motivos[index];
                          // Por defecto, si no tiene estado, se considera activo
                          final bool isActive = motivo['estado'] ?? true;
                          return ListTile(
                            title: Text(motivo['titulo'] ?? ''),
                            subtitle: Text(motivo['descripcion'] ?? ''),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: isActive,
                                  activeColor: Colors.green,
                                  inactiveThumbColor: Colors.red,
                                  onChanged: (value) {
                                    _actualizarEstadoMotivo(value, motivo);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _editarMotivo(motivo),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _borrarMotivo(motivo['id']),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
            const Divider(),
            SizedBox(height: 10),
            const Text(
              'Motivos enviados por usuarios',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child:
                  _loadingMotivosUsuarios
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        itemCount: _motivosUsuarios.length,
                        itemBuilder: (context, index) {
                          final motivo = _motivosUsuarios[index];
                          return ListTile(
                            title: Text('${motivo['username']}'),
                            subtitle: Text(motivo['motivo']),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
