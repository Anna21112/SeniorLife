import 'package:flutter/material.dart';
import 'widgets/navigation_bars.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'global.dart';

// Modelo para representar os dados do usuário que vêm da API.
class User {
  String name;
  int age;
  String address;
  List<String> phones;

  User({
    required this.name,
    required this.age,
    required this.address,
    required this.phones,
  });

  // Um método factory para criar um User a partir de um JSON (exemplo)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      age: json['age'],
      address: json['address'],
      phones: List<String>.from(json['phones']),
    );
  }

  // Método para converter o User em JSON para enviar para a API
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'address': address,
      'phones': phones,
    };
  }
}

class TelaExibirPerfilDepen extends StatefulWidget {
  final Dependente dependente;

  const TelaExibirPerfilDepen({super.key, required this.dependente});

  @override
  State<TelaExibirPerfilDepen> createState() => _TelaExibirPerfilDepenState();
}

class _TelaExibirPerfilDepenState extends State<TelaExibirPerfilDepen> {
  // Futuro para armazenar os dados do usuário que virão da API.
  late Future<User> _userFuture;

  // Flag para controlar o modo de edição.
  bool _isEditing = false;

  // Controladores para os campos de texto no modo de edição.
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _addressController;
  late TextEditingController _phonesController;

  @override
  void initState() {
    super.initState();
    // Inicia a busca pelos dados do usuário quando o widget é criado.
    _userFuture = _fetchUserData();
  }

  Future<User> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final dependenteId = widget.dependente.id;

    final response = await http.get(
      Uri.parse('$apiUrl/api/emergency/$dependenteId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final emergency = data['data'];
      // Ajuste os campos conforme o retorno da sua API!
      return User(
        name: emergency['nome'] ?? '',
        age: emergency['idade'] ?? 0,
        address: emergency['alergias'] ?? '',
        phones: emergency['contato_emergencia'] != null
            ? [emergency['contato_emergencia'].toString()]
            : [],
      );
    } else {
      throw Exception('Erro ao buscar dados do dependente');
    }
  }

  Future<void> _updateUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final dependenteId = widget.dependente.id;

    final response = await http.put(
      Uri.parse('$apiUrl/api/emergency/$dependenteId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        'nome': user.name,
        'idade': user.age,
        'alergias': user.address,
        'contato_emergencia': user.phones.isNotEmpty ? user.phones.first : '',
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao atualizar dados do dependente');
    }
  }

  void _toggleEditMode(User currentUser) {
    setState(() {
      if (_isEditing) {
        // Se estava editando, agora vai salvar
        final updatedUser = User(
          name: _nameController.text,
          age: int.tryParse(_ageController.text) ?? currentUser.age,
          address: _addressController.text,
          phones:
              _phonesController.text.split(',').map((p) => p.trim()).toList(),
        );

        _updateUserData(updatedUser).then((_) {
          setState(() {
            _userFuture = Future.value(updatedUser);
          });
        }).catchError((error) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Erro ao salvar: $error')));
        });
      } else {
        // Se estava visualizando, agora vai editar
        _nameController = TextEditingController(text: currentUser.name);
        _ageController =
            TextEditingController(text: currentUser.age.toString());
        _addressController = TextEditingController(text: currentUser.address);
        _phonesController =
            TextEditingController(text: currentUser.phones.join(', '));
      }
      _isEditing = !_isEditing;
    });
  }

  @override
  void dispose() {
    if (_isEditing) {
      _nameController.dispose();
      _ageController.dispose();
      _addressController.dispose();
      _phonesController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // O Scaffold é o corpo principal. É aqui que você integra suas barras.
    return Scaffold(
      appBar: const CustomAppBar(),
      // O FutureBuilder é usado para construir a interface com base no estado do futuro.
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Erro ao carregar perfil: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            final user = snapshot.data!;
            return SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.green,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nome e Botão Editar/Salvar
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: _isEditing
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 90.0),
                                child: TextField(
                                  controller: _nameController,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                  decoration: const InputDecoration.collapsed(
                                      hintText: 'Nome'),
                                ),
                              )
                            : Text(
                                user.name,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF31A1C6),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _toggleEditMode(user),
                          child: Text(_isEditing ? 'Salvar' : 'Editar'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Seção de Informações
                  _isEditing ? _buildEditForm() : _buildInfoDisplay(user),
                ],
              ),
            );
          }
          return const Center(
              child: Text('Nenhum dado de usuário encontrado.'));
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildInfoDisplay(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Nome', user.name),
        _buildInfoRow('Idade', user.age.toString()),
        _buildInfoRow('Alergias', user.address),
        _buildInfoRow('Telefones', user.phones.join('\n')),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        _buildTextFormField(_ageController, 'Idade',
            keyboardType: TextInputType.number),
        _buildTextFormField(_addressController, 'Alergias'),
        _buildTextFormField(
            _phonesController, 'Telefones (separados por vírgula)'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
        ),
      ),
    );
  }
}
