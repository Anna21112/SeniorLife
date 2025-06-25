import 'package:flutter/material.dart';
import 'widgets/navigation_bars.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'global.dart';

class TelaCadastroDependente extends StatefulWidget {
  const TelaCadastroDependente({super.key});

  @override
  State<TelaCadastroDependente> createState() => _TelaCadastroDependenteState();
}

class _TelaCadastroDependenteState extends State<TelaCadastroDependente> {
  final _nomeController = TextEditingController();
  final _idadeController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _restricoesController = TextEditingController();
  final _senhaController = TextEditingController();
  final _emailController = TextEditingController();
  final _emergenciaController = TextEditingController();
  final _alergiaController = TextEditingController();

  bool _salvando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _idadeController.dispose();
    _enderecoController.dispose();
    _restricoesController.dispose();
    _senhaController.dispose();
    _emailController.dispose();
    _emergenciaController.dispose();
    _alergiaController.dispose();
    super.dispose();
  }

  Future<void> salvarDependente() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    // 1. Salva na tabela dependente
    final urlDependente = Uri.parse('$apiUrl/api/dependents/Cadastro');
    final responseDependente = await http.post(
      urlDependente,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'nome': _nomeController.text,
        'email': _emailController.text,
        'senha': _senhaController.text,
      }),
    );
    if (responseDependente.statusCode != 200 &&
        responseDependente.statusCode != 201) {
      throw Exception('Erro ao salvar dependente');
    }

    final dependenteData = jsonDecode(responseDependente.body);
    final dependenteId =
        dependenteData['data']?['dependente']?['id'] ?? dependenteData['id'];

    print('ID do dependente salvo: $dependenteId');

    // 2. Salva as informações adicionais (pegue o id do dependente salvo, se necessário)
    final urlInfo = Uri.parse('$apiUrl/api/emergency/');
    final responseInfo = await http.post(
      urlInfo,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'dependente_id': dependenteId,
        'nome': _nomeController.text,
        'idade': _idadeController.text,
        'alergias': _alergiaController.text,
        'historico': _restricoesController.text,
        'contato_emergencia': _emergenciaController.text,
      }),
    );
    if (responseInfo.statusCode != 200 && responseInfo.statusCode != 201) {
      throw Exception('Erro ao salvar informações do dependente');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      bottomNavigationBar: const CustomBottomNavBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          children: [
            const Icon(Icons.edit, color: Colors.green, size: 50),
            const SizedBox(height: 20),
            _campoTexto(label: 'Nome:', controller: _nomeController),
            const SizedBox(height: 10),
            _campoTexto(label: 'Idade:', controller: _idadeController),
            const SizedBox(height: 10),
            _campoTexto(label: 'Endereço:', controller: _enderecoController),
            const SizedBox(height: 10),
            _campoTexto(label: 'Senha:', controller: _senhaController),
            const SizedBox(height: 10),
            _campoTexto(label: 'Email:', controller: _emailController),
            const SizedBox(height: 10),
            _campoTexto(
                label: 'Contato de emergencia:',
                controller: _emergenciaController),
            const SizedBox(height: 10),
            _campoTexto(label: 'Alergias:', controller: _alergiaController),
            const SizedBox(height: 20),
            _campoTextoGrande(
                label: 'Histórico:', controller: _restricoesController),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _salvando
                  ? null
                  : () async {
                      setState(() => _salvando = true);
                      try {
                        await salvarDependente();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Dependente salvo com sucesso!')),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao salvar: $e')),
                        );
                      } finally {
                        setState(() => _salvando = false);
                      }
                    },
              child: _salvando
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Salvar alterações'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoTexto(
      {required String label, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF31A2C6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(width: 2, color: Color(0xFF31A2C6)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _campoTextoGrande(
      {required String label, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFFFFAFA),
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF31A2C6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(width: 2, color: Color(0xFF31A2C6)),
            ),
          ),
        ),
      ],
    );
  }
}
