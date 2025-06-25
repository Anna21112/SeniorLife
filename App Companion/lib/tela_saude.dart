import 'package:flutter/material.dart';
import 'widgets/navigation_bars.dart';
import 'global.dart';

// Modelo de dados para medicação
class Medication {
  String name;
  String dosage;
  String frequency;
  Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
  });
}

// Modelo de dados simples (histórico, info médica, restrições)
class SimpleItem {
  String description;
  SimpleItem({required this.description});
}

// Tela principal de saúde
class MedicalDataScreen extends StatefulWidget {
  const MedicalDataScreen({super.key});

  @override
  State<MedicalDataScreen> createState() => _MedicalDataScreenState();
}

class _MedicalDataScreenState extends State<MedicalDataScreen> {
  int _selectedTabIndex = 3;
  late Future<String> _userNameFuture;

  // Listas de dados para cada aba
  final List<Medication> _medications = [
    Medication(name: 'Rivotril', dosage: '40mg', frequency: '6 em 6 hrs'),
    Medication(name: 'Dipirona', dosage: '100mg', frequency: '8 em 8 hrs'),
    Medication(name: 'Alprazolan', dosage: '150mg', frequency: '5 em 5 hrs'),
  ];
  final List<SimpleItem> _historyItems = [
    SimpleItem(description: 'Consulta de rotina - Dr. House'),
  ];
  final List<SimpleItem> _medicalInfoItems = [
    SimpleItem(description: 'Alergia a amendoim'),
  ];
  final List<SimpleItem> _restrictions = [
    SimpleItem(description: 'Evitar esforço físico intenso'),
  ];

  @override
  void initState() {
    super.initState();
    _userNameFuture = _fetchUserName();
  }

  // Simula chamada de API para buscar nome do usuário
  Future<String> _fetchUserName() async {
    await Future.delayed(const Duration(seconds: 2));
    return "Maria Silva";
  }

  // Diálogo para adicionar/editar itens simples
  void _showSimpleItemDialog({
    required List<SimpleItem> list,
    SimpleItem? item,
    int? index,
    required String title,
  }) {
    final formKey = GlobalKey<FormState>();
    final isEditing = item != null;
    final controller = TextEditingController(text: item?.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Item' : 'Adicionar $title'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Descrição'),
            validator: (value) =>
                value!.trim().isEmpty ? 'Campo obrigatório' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  final newItem = SimpleItem(description: controller.text);
                  if (isEditing) {
                    list[index!] = newItem;
                  } else {
                    list.add(newItem);
                  }
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('SALVAR'),
          ),
        ],
      ),
    );
  }

  // Diálogo para adicionar/editar medicação
  void _showMedicationDialog({Medication? medication, int? index}) {
    final formKey = GlobalKey<FormState>();
    final isEditing = medication != null;

    final nameController = TextEditingController(text: medication?.name);
    final dosageController = TextEditingController(text: medication?.dosage);
    final frequencyController = TextEditingController(
      text: medication?.frequency,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Medicação' : 'Adicionar Medicação'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: dosageController,
                  decoration: const InputDecoration(labelText: 'Dosagem'),
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: frequencyController,
                  decoration: const InputDecoration(labelText: 'Frequência'),
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  final newMed = Medication(
                    name: nameController.text,
                    dosage: dosageController.text,
                    frequency: frequencyController.text,
                  );
                  if (isEditing) {
                    _medications[index!] = newMed;
                  } else {
                    _medications.add(newMed);
                  }
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('SALVAR'),
          ),
        ],
      ),
    );
  }

  void _confirmDeletion({
    required VoidCallback onConfirm,
    required String itemName,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza de que deseja remover "$itemName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('NÃO'),
          ),
          TextButton(
            onPressed: () {
              setState(onConfirm);
              Navigator.of(context).pop();
            },
            child: const Text('SIM'),
          ),
        ],
      ),
    );
  }

  // Tabs
  Widget _buildTabBar() {
    final tabs = ['Histórico', 'Info. Med.', 'Restrições', 'Medicações'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabs.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: _buildTabItem(tabs[index], index),
          );
        }),
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8BC34A) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
          border: isSelected
              ? null
              : const Border(
                  bottom: BorderSide(color: Color(0xFF8BC34A), width: 2.0),
                ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleItemList({
    required List<SimpleItem> list,
    required String title,
  }) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Nenhum item em "$title"',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return ListTile(
          title: Text(item.description),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showSimpleItemDialog(
                  list: list,
                  item: item,
                  index: index,
                  title: title,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => _confirmDeletion(
                  onConfirm: () => list.removeAt(index),
                  itemName: item.description,
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) =>
          const Divider(height: 1, indent: 16, endIndent: 16),
    );
  }

  Widget _buildMedicationList() {
    if (_medications.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'Nenhuma medicação adicionada.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _medications.length,
      itemBuilder: (context, index) {
        final med = _medications[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(med.name, style: const TextStyle(fontSize: 16)),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  med.dosage,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  med.frequency,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () =>
                    _showMedicationDialog(medication: med, index: index),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => _confirmDeletion(
                  onConfirm: () => _medications.removeAt(index),
                  itemName: med.name,
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) =>
          const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
    );
  }

  Widget _buildContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildSimpleItemList(list: _historyItems, title: 'Histórico');
      case 1:
        return _buildSimpleItemList(
          list: _medicalInfoItems,
          title: 'Info. Med.',
        );
      case 2:
        return _buildSimpleItemList(list: _restrictions, title: 'Restrições');
      case 3:
      default:
        return _buildMedicationList();
    }
  }

  void _onFabPressed() {
    switch (_selectedTabIndex) {
      case 0:
        _showSimpleItemDialog(list: _historyItems, title: 'Histórico');
        break;
      case 1:
        _showSimpleItemDialog(list: _medicalInfoItems, title: 'Info. Med.');
        break;
      case 2:
        _showSimpleItemDialog(list: _restrictions, title: 'Restrição');
        break;
      case 3:
      default:
        _showMedicationDialog();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: FutureBuilder<String>(
          future: _userNameFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Acompanhe os dados médicos de\n'),
                    TextSpan(
                      text: 'Carregando...',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontSize: 18),
              );
            } else if (snapshot.hasError) {
              return const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Acompanhe os dados médicos de\n'),
                    TextSpan(
                      text: 'Erro ao carregar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontSize: 18),
              );
            } else if (snapshot.hasData) {
              return Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Acompanhe os dados médicos de\n'),
                    TextSpan(
                      text: snapshot.data!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black, fontSize: 18),
              );
            }
            return const Text('');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTabBar(),
            const SizedBox(height: 20),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        child: const Icon(Icons.add, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
