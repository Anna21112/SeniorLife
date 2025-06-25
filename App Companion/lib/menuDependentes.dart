import 'package:flutter/material.dart';
import 'menuAddDependente.dart';
import 'widgets/navigation_bars.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'global.dart';

class TelaAdicionarDependente extends StatelessWidget {
  const TelaAdicionarDependente({super.key});

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: FutureBuilder<List<Dependente>>(
        future: buscarDependentes(), // Implemente essa função para buscar os dependentes da API
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum dependente cadastrado.'));
          }
          final dependentes = snapshot.data!;
          return ListView.builder(
      itemCount: dependentes.length,
      itemBuilder: (context, index) {
        final dependente = dependentes[index];
        return ListTile(
          title: Text(dependente.nome),
          onTap: () async {
            // Salva o dependente selecionado como padrão
            final prefs = await SharedPreferences.getInstance();
            prefs.setString('dependente_padrao_id', dependente.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${dependente.nome} definido como padrão!')),
            );
          },
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
      floatingActionButtonLocation: FloatingActionButtonLocation
          .centerDocked, // Centraliza acima da BottomBar
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
