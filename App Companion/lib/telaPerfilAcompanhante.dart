import 'dart:math';
import 'package:flutter/material.dart';
import 'widgets/navigation_bars.dart';

// Simulação de dados vindos do backend
class Usuario {
  String nome;
  final String endereco;
  final String email;
  final String telefone;

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
    // Aqui você buscaria do backend. Exemplo fixo:
    usuario = Usuario(
      nome: 'Paula Fernandes',
      endereco: 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
      email: 'xxxxxxxxxxxxxxx@xxxxxxxxx',
      telefone: '(XX) xxxxx-xxxx',
    );
    avatarColor = _randomColor(usuario.nome);
  }

  Color _randomColor(String s) {
    // Gera cor baseada na primeira letra do nome
    final colors = [
      Colors.orange,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
    ];
    int code = s.codeUnitAt(0);
    return colors[code % colors.length];
  }

  void _editarNome() async {
    final novoNome = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: usuario.nome);
        return AlertDialog(
          title: const Text('Editar nome'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Novo nome'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
    if (novoNome != null && novoNome.isNotEmpty && novoNome != usuario.nome) {
      setState(() {
        usuario.nome = novoNome;
        avatarColor = _randomColor(novoNome);
      });
      // Aqui você faria a chamada para atualizar no backend
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      bottomNavigationBar: const CustomBottomNavBar(),
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
                const Text(
                  'Meu Perfil',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _editarNome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Editar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _infoLinha('Nome :', usuario.nome),
            const Divider(),
            _infoLinha('Endereço :', usuario.endereco),
            const Divider(),
            _infoLinha('E-mail :', usuario.email),
            const Divider(),
            _infoLinha('Telefones :', usuario.telefone),
            const Divider(),
          ],
        ),
      ),
    );
  }

  Widget _infoLinha(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
