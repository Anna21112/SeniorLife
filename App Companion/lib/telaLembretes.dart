import 'package:flutter/material.dart';
import 'widgets/navigation_bars.dart';

class Lembrete {
  String descricao;
  bool concluido;
  Lembrete({required this.descricao, this.concluido = false});
}

class TelaLembretes extends StatefulWidget {
  const TelaLembretes({super.key});

  @override
  State<TelaLembretes> createState() => _TelaLembretesState();
}

class _TelaLembretesState extends State<TelaLembretes> {
  int _abaSelecionada = 0;

  final List<Lembrete> _ativFisica = [
    Lembrete(descricao: 'FAZER 20 FLEXÕES'),
    Lembrete(descricao: 'ALONGAR AS COSTAS PELO MENOS 1 VEZ'),
    Lembrete(descricao: 'FAZER 30 POLICHINELOS'),
  ];
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
    final controller = TextEditingController(text: lembrete?.descricao ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(lembrete == null ? 'Adicionar Lembrete' : 'Editar Lembrete'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Descrição'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final texto = controller.text.trim();
              if (texto.isEmpty) return;
              setState(() {
                if (lembrete == null) {
                  _lembretesAtuais.add(Lembrete(descricao: texto));
                } else if (index != null) {
                  _lembretesAtuais[index] = Lembrete(
                    descricao: texto,
                    concluido: lembrete.concluido,
                  );
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _removerLembrete(int index) {
    setState(() {
      _lembretesAtuais.removeAt(index);
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
                  onTap: () => setState(() => _abaSelecionada = 0),
                ),
                _AbaBotao(
                  texto: 'Alimentação',
                  selecionada: _abaSelecionada == 1,
                  onTap: () => setState(() => _abaSelecionada = 1),
                ),
                _AbaBotao(
                  texto: 'Medicação',
                  selecionada: _abaSelecionada == 2,
                  onTap: () => setState(() => _abaSelecionada = 2),
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
                        title: Text(
                          lembrete.descricao,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            decoration: lembrete.concluido
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
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
