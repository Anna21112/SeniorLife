import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/navigation_bars.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';
import 'global.dart';

// Simulação de dados vindos do backend
class Usuario {
  String nome;
  String endereco;
  String email;
  String telefone;

  Usuario({
    required this.nome,
    required this.endereco,
    required this.email,
    required this.telefone,
  });
}

class TelaPerfilAcompanhante extends StatefulWidget {
  const TelaPerfilAcompanhante({super.key});

  @override
  State<TelaPerfilAcompanhante> createState() => _TelaPerfilAcompanhanteState();
}

class _TelaPerfilAcompanhanteState extends State<TelaPerfilAcompanhante> {
  Usuario usuario = Usuario(nome: '', endereco: '', email: '', telefone: '');
  Color avatarColor = Colors.blueAccent;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final acompanhante_id = prefs.getString('acompanhante_id');
    final response = await http.get(
      Uri.parse('$apiUrl/api/caregivers/$acompanhante_id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Perfil acompanhante: $data');

      usuario = Usuario(
        nome: data['nome'] ?? '',
        email: data['email'] ?? '',
        endereco: data['endereco'] ?? '',
        telefone: data['telefone'] ?? '',
      );
      setState(() {
        usuario = usuario;
        avatarColor = _randomColor(usuario.nome);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Color _randomColor(String s) {
    final colors = [
      Colors.orange,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
    ];
    int code = s.isNotEmpty ? s.codeUnitAt(0) : 0;
    return colors[code % colors.length];
  }

  void _editarPerfil() async {
    final nomeController = TextEditingController(text: usuario.nome);
    final emailController = TextEditingController(text: usuario.email);

    final resultado = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
              autofocus: true,
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, {
                'nome': nomeController.text.trim(),
                'email': emailController.text.trim(),
              });
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (resultado != null) {
      setState(() {
        usuario.nome = resultado['nome'] ?? usuario.nome;
        usuario.email = resultado['email'] ?? usuario.email;
        avatarColor = _randomColor(usuario.nome);
      });
      // Aqui você pode fazer uma requisição para atualizar no backend, se quiser.
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final acompanhante_id = prefs.getString('acompanhante_id');
      await http.put(
        Uri.parse('$apiUrl/api/caregivers/$acompanhante_id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'nome': usuario.nome,
          'email': usuario.email,
        }),
      );
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('acompanhante_id');
    // Se houver outros dados de sessão, remova aqui também

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const TelaLogin()),
      (Route<dynamic> route) => false,
    );
  }

  Widget _infoLinha(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(valor, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: const CustomAppBar(), // Substitua o AppBar padrão
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            const SizedBox(height: 10),
            CircleAvatar(
              radius: 38,
              backgroundColor: avatarColor,
              child: Text(
                usuario.nome.isNotEmpty ? usuario.nome[0].toUpperCase() : '',
                style: const TextStyle(
                  fontSize: 38,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  usuario.nome,
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                  onPressed: _editarPerfil,
                  tooltip: 'Editar perfil',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _infoLinha('E-mail:', usuario.email),
            const Divider(),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF0000),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(), // Adicione esta linha
    );
  }
}
