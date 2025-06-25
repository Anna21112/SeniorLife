import 'package:flutter/material.dart';
import 'menuAddDependente.dart';
import 'widgets/navigation_bars.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'global.dart';
import 'telaExibirPerfilDepen.dart';

class TelaAdicionarDependente extends StatelessWidget {
  const TelaAdicionarDependente({super.key});

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

  Future<List<Dependente>> buscarDependentes() async {
    // Faça a requisição para sua API e retorne a lista de dependentes
    // Exemplo:
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('$apiUrl/api/dependents/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final dependentes = data['data']['dependentes'] as List;
      return dependentes.map((json) => Dependente.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao buscar dependentes');
    }
  }

  // ...existing imports...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: FutureBuilder<List<Dependente>>(
        future: buscarDependentes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum dependente cadastrado.'));
          }
          final dependentes = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            itemCount: dependentes.length,
            itemBuilder: (context, index) {
              final dependente = dependentes[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _randomColor(dependente.nome),
                    child: Text(
                      dependente.nome.isNotEmpty
                          ? dependente.nome[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    dependente.nome,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        tooltip: 'Ver perfil',
                        onPressed: () {
                          // Navegar para tela de exibição do perfil do dependente
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TelaExibirPerfilDepen(dependente: dependente),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: 'Editar',
                        onPressed: () {
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(
                                   builder: (_) =>
                                       TelaExibirPerfilDepen(dependente: dependente),
                                 ),
                               );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Excluir',
                        onPressed: () async {
                           final confirm = await showDialog<bool>(
                             context: context,
                             builder: (context) => AlertDialog(
                             title: const Text('Excluir dependente'),
                             content: Text('Tem certeza que deseja excluir ${dependente.nome}?'),
                             actions: [
                                TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                              ),
                      ],
                  ),
              );
                            if (confirm == true) {
                              final prefs = await SharedPreferences.getInstance();
                              final token = prefs.getString('token');
                              final response = await http.delete(
                                Uri.parse('$apiUrl/api/dependents/${dependente.id}'),
                                headers: {
                                  'Content-Type': 'application/json',
                                  'Authorization': 'Bearer $token',
                                  'ngrok-skip-browser-warning': 'true',
                                },
                            );
                            if (response.statusCode == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${dependente.nome} excluído com sucesso!')),
      );
      // Atualiza a lista após exclusão
                              (context as Element).reassemble();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro ao excluir dependente')),
      );
    }
  }
                        },
                      ),
                    ],
                  ),
                  onTap: () async {
                    // Salva o dependente selecionado como padrão
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('dependente_padrao_id', dependente.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('${dependente.nome} definido como padrão!')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TelaCadastroDependente(),
              ),
            );
          },
          icon: const Icon(Icons.add, color: Colors.green),
          label: const Text(
            'Adicionar dependente',
            style: TextStyle(color: Colors.black),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Colors.green),
            elevation: 3,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
