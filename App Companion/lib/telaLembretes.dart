import 'dart:async';

import 'package:flutter/material.dart';
import 'widgets/navigation_bars.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'global.dart';

class Lembrete {
  String id;
  String titulo;
  String descricao;
  String type; // <-- Adicione aqui
  bool concluido;
  Lembrete({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.type,
    this.concluido = false,
  });
}

class TelaLembretes extends StatefulWidget {
  const TelaLembretes({super.key});

  @override
  State<TelaLembretes> createState() => _TelaLembretesState();
}

class _TelaLembretesState extends State<TelaLembretes> {
  Future<List<Lembrete>> buscarLembretesPorTipo(String tipo) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final dependentePadraoId = prefs.getString('dependente_padrao_id');

    final response = await http.get(
      Uri.parse('$apiUrl/api/rotinas/$dependentePadraoId/activity?type=$tipo'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Resposta da API: $data');
      final lembretes = data['data']['activity'] as List;
      return lembretes
          .map((json) => Lembrete(
                id: json['_id'] ?? '',
                titulo: json['title'] ?? '',
                descricao: json['description'] ?? '',
                type: json['type'] ?? '',
                concluido: false,
              ))
          .toList();
    } else {
      throw Exception('Erro ao buscar lembretes');
    }
  }

  Future<void> salvarLembreteNoBackend(Lembrete lembrete, String tipo) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final dependentePadraoId = prefs.getString('dependente_padrao_id');

    final body = jsonEncode({
      'title': lembrete.titulo,
      'description': lembrete.descricao,
      'type': tipo,
      'schedule': DateTime.now().toUtc().toIso8601String(),
    });
    print('Enviando body: $body'); // <-- Adicione este print

    final response = await http.post(
      Uri.parse('$apiUrl/api/rotinas/$dependentePadraoId/activity'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      print('Erro: ${response.body}');
      throw Exception('Erro ao salvar lembrete');
    }
  }

  Future<void> excluirLembreteNoBackend(String id, String tipo) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final dependentePadraoId = prefs.getString('dependente_padrao_id');

    final response = await http.delete(
      Uri.parse('$apiUrl/api/rotinas/$dependentePadraoId/activity/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erro ao excluir lembrete');
    }
  }

  Future<void> editarLembreteNoBackend(Lembrete lembrete, String tipo) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final dependentePadraoId = prefs.getString('dependente_padrao_id');

    final response = await http.put(
      Uri.parse(
          '$apiUrl/api/rotinas/$dependentePadraoId/activity/${lembrete.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        'title': lembrete.titulo,
        'description': lembrete.descricao,
        'type': tipo,
        'schedule': DateTime.now().toUtc().toIso8601String(),
      }),
    );
    print('PUT body: ${jsonEncode({
          'title': lembrete.titulo,
          'description': lembrete.descricao,
          'type': tipo,
          'schedule': DateTime.now().toUtc().toIso8601String(),
        })}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao editar lembrete');
    }
  }

  int _abaSelecionada = 0;

  final List<Lembrete> _ativFisica = [];
  final List<Lembrete> _alimentacao = [];
  final List<Lembrete> _medicacao = [];

  List<Lembrete> get _lembretesAtuais {
    switch (_abaSelecionada) {
      case 0:
        return _ativFisica;
      case 1:
        return _alimentacao;
      case 2:
        return _medicacao;
      default:
        return [];
    }
  }

  String get _tituloAba {
    switch (_abaSelecionada) {
      case 0:
        return 'Atv. Físicas';
      case 1:
        return 'Alimentação';
      case 2:
        return 'Medicação';
      default:
        return '';
    }
  }

  void _adicionarOuEditarLembrete({Lembrete? lembrete, int? index}) {
    final tituloController =
        TextEditingController(text: lembrete?.titulo ?? '');
    final descricaoController =
        TextEditingController(text: lembrete?.descricao ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(lembrete == null ? 'Adicionar Lembrete' : 'Editar Lembrete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tituloController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final titulo = tituloController.text.trim();
              final descricao = descricaoController.text.trim();
              if (titulo.isEmpty || descricao.isEmpty) return;
              if (lembrete == null) {
                final tipo = _abaSelecionada == 0
                    ? 'atividade fisica'
                    : _abaSelecionada == 1
                        ? 'alimentacao'
                        : 'medicacao';
                final novoLembrete = Lembrete(
                    id: '', titulo: titulo, descricao: descricao, type: tipo);
                await salvarLembreteNoBackend(novoLembrete, tipo);
                final lembretes = await buscarLembretesPorTipo(tipo);
                setState(() {
                  _lembretesAtuais
                    ..clear()
                    ..addAll(lembretes);
                });
              } else if (index != null) {
                final tipo = _abaSelecionada == 0
                    ? 'atividade fisica'
                    : _abaSelecionada == 1
                        ? 'alimentacao'
                        : 'medicacao';
                final editado = Lembrete(
                  id: lembrete.id,
                  titulo: titulo,
                  descricao: descricao,
                  type: tipo,
                  concluido: lembrete.concluido,
                );
                await editarLembreteNoBackend(editado, tipo);
                final lembretes = await buscarLembretesPorTipo(tipo);
                setState(() {
                  _lembretesAtuais
                    ..clear()
                    ..addAll(lembretes);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _removerLembrete(int index) async {
    final lembrete = _lembretesAtuais[index];
    final tipo = _abaSelecionada == 0
        ? 'atividade fisica'
        : _abaSelecionada == 1
            ? 'alimentacao'
            : 'medicacao';
    await excluirLembreteNoBackend(lembrete.id, tipo);
    final lembretes = await buscarLembretesPorTipo(tipo);
    setState(() {
      _lembretesAtuais
        ..clear()
        ..addAll(lembretes);
    });
  }

  void _alternarConclusao(int index) {
    setState(() {
      _lembretesAtuais[index].concluido = !_lembretesAtuais[index].concluido;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      bottomNavigationBar: const CustomBottomNavBar(),
      body: Column(
        children: [
          // Abas
          Padding(
            padding: const EdgeInsets.only(top: 12.0, left: 8, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AbaBotao(
                  texto: 'Atv. Físicas',
                  selecionada: _abaSelecionada == 0,
                  onTap: () async {
                    setState(() => _abaSelecionada = 0);
                    final lembretes =
                        await buscarLembretesPorTipo('atividade fisica');
                    setState(() => _ativFisica
                      ..clear()
                      ..addAll(lembretes));
                  },
                ),
                _AbaBotao(
                  texto: 'Alimentação',
                  selecionada: _abaSelecionada == 1,
                  onTap: () async {
                    setState(() => _abaSelecionada = 1);
                    final lembretes =
                        await buscarLembretesPorTipo('alimentacao');
                    setState(() => _alimentacao
                      ..clear()
                      ..addAll(lembretes));
                  },
                ),
                _AbaBotao(
                  texto: 'Medicação',
                  selecionada: _abaSelecionada == 2,
                  onTap: () async {
                    setState(() => _abaSelecionada = 2);
                    final lembretes = await buscarLembretesPorTipo('medicacao');
                    setState(() => _medicacao
                      ..clear()
                      ..addAll(lembretes));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _lembretesAtuais.isEmpty
                ? Center(
                    child: Text(
                      'Nenhum lembrete em $_tituloAba',
                      style: const TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  )
                : ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    itemCount: _lembretesAtuais.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final lembrete = _lembretesAtuais[index];
                      return ListTile(
                        leading: Checkbox(
                          value: lembrete.concluido,
                          onChanged: (_) => _alternarConclusao(index),
                        ),
                        title: Text(lembrete.titulo,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(lembrete.descricao),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _adicionarOuEditarLembrete(
                                lembrete: lembrete,
                                index: index,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
                              onPressed: () => _removerLembrete(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, top: 8),
            child: FloatingActionButton(
              onPressed: () => _adicionarOuEditarLembrete(),
              backgroundColor: const Color(0xFF31A2C6),
              child: const Icon(Icons.add, size: 36),
            ),
          ),
        ],
      ),
    );
  }
}

class _AbaBotao extends StatelessWidget {
  final String texto;
  final bool selecionada;
  final VoidCallback onTap;
  const _AbaBotao({
    required this.texto,
    required this.selecionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selecionada ? const Color(0xFF8BC34A) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border(
              bottom: BorderSide(
                color: selecionada ? const Color(0xFF8BC34A) : Colors.grey,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              texto,
              style: TextStyle(
                color: selecionada ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
