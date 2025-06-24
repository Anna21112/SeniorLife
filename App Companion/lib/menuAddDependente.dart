import 'package:flutter/material.dart';
import 'widgets/navigation_bars.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  bool _salvando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _idadeController.dispose();
    _enderecoController.dispose();
    _restricoesController.dispose();
    super.dispose();
  }

  Future<void> salvarDependente(
      String nome, String idade, String endereco, String restricoes) async {
    final url =
        Uri.parse('https://suaapi.com/dependentes'); // Troque pela sua URL real
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'idade': idade,
        'endereco': endereco,
        'restricoes': restricoes,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao salvar dependente');
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
            _campoTextoGrande(
                label: 'Restrições:', controller: _restricoesController),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _salvando
                  ? null
                  : () async {
                      setState(() => _salvando = true);
                      try {
                        await salvarDependente(
                          _nomeController.text,
                          _idadeController.text,
                          _enderecoController.text,
                          _restricoesController.text,
                        );
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
