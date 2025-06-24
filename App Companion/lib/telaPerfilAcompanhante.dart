import 'package:flutter/material.dart';
import 'widgets/navigation_bars.dart';
import 'main.dart';

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
  late Usuario usuario;
  late Color avatarColor;

  @override
  void initState() {
    super.initState();
    usuario = Usuario(
      nome: 'Paula Fernandes',
      endereco: 'Rua Exemplo, 123',
      email: 'paula@email.com',
      telefone: '(11) 99999-9999',
    );
    avatarColor = _randomColor(usuario.nome);
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
    final resultado = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        final nomeController = TextEditingController(text: usuario.nome);
        final enderecoController =
            TextEditingController(text: usuario.endereco);
        final emailController = TextEditingController(text: usuario.email);
        final telefoneController =
            TextEditingController(text: usuario.telefone);

        return AlertDialog(
          title: const Text('Editar Perfil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  autofocus: true,
                ),
                TextField(
                  controller: enderecoController,
                  decoration: const InputDecoration(labelText: 'Endereço'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: telefoneController,
                  decoration: const InputDecoration(labelText: 'Telefone'),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
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
                  'endereco': enderecoController.text.trim(),
                  'email': emailController.text.trim(),
                  'telefone': telefoneController.text.trim(),
                });
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (resultado != null) {
      setState(() {
        usuario.nome = resultado['nome'] ?? usuario.nome;
        usuario.endereco = resultado['endereco'] ?? usuario.endereco;
        usuario.email = resultado['email'] ?? usuario.email;
        usuario.telefone = resultado['telefone'] ?? usuario.telefone;
        avatarColor = _randomColor(usuario.nome);
      });
      // Aqui você pode chamar sua API para salvar as alterações no backend
    }
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const TelaLogin()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
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
            _infoLinha('Endereço:', usuario.endereco),
            const Divider(),
            _infoLinha('E-mail:', usuario.email),
            const Divider(),
            _infoLinha('Telefones:', usuario.telefone),
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
}
