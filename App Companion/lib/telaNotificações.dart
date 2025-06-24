import 'package:flutter/material.dart';
import 'widgets/navigation_bars.dart';
import '../telaAgenda.dart';

// NOVO ENUM para controlar o tipo de filtro aplicado.
enum FilterType { todos, comum, emergencia }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const AgendaScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- 1. Modelo de Dados (Sem alterações) ---
enum NotificationType { comum, emergencia }

class Notification {
  final String id;
  final String text;
  final String fullText;
  final NotificationType type;
  bool isRead;

  Notification({
    required this.id,
    required this.text,
    required this.fullText,
    required this.type,
    this.isRead = false,
  });
}

// --- 2. Simulação da API (Sem alterações) ---
Future<List<Notification>> fetchNotifications() async {
  await Future.delayed(const Duration(seconds: 1));
  return [
    Notification(
      id: '1',
      text: 'Rogério concluiu a caminhada',
      fullText:
          'Rogério concluiu a sua caminhada diária de 30 minutos às 08:15. Todos os sinais vitais permaneceram estáveis durante a atividade.',
      type: NotificationType.comum,
    ),
    Notification(
      id: '2',
      text: 'A consulta com Steve foi marcada',
      fullText:
          'Uma nova consulta com o Dr. Steve Rogers (Cardiologista) foi agendada para o dia 28/06/2025, às 14:00. Por favor, confirme a presença.',
      type: NotificationType.comum,
    ),
    Notification(
      id: '3',
      text: 'Rogério teve um aumento na pressão',
      fullText:
          'ALERTA DE EMERGÊNCIA: Foi detectado um aumento súbito na pressão arterial de Rogério para 160/100 mmHg às 09:30. A equipe de enfermagem já foi notificada e está a caminho. Por favor, monitore de perto.',
      type: NotificationType.emergencia,
    ),
    Notification(
      id: '4',
      text: 'Novo medicamento adicionado',
      fullText:
          'O Dr. Steve Rogers adicionou o medicamento "Sinvastatina 20mg" à prescrição de Rogério. A primeira dose deve ser administrada hoje à noite.',
      type: NotificationType.comum,
    ),
    Notification(
      id: '5',
      text: 'Alerta de Glicose Baixa',
      fullText:
          'ALERTA DE EMERGÊNCIA: O nível de glicose de Rogério caiu para 65 mg/dL. Ação imediata é necessária.',
      type: NotificationType.emergencia,
    ),
  ];
}

// --- 3. Tela Principal (Grandes Atualizações) ---
class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  // Variáveis de estado para gerenciar as listas e o filtro
  List<Notification> _allNotifications = [];
  List<Notification> _filteredNotifications = [];
  bool _isLoading = true;
  FilterType _currentFilter = FilterType.todos;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // Carrega as notificações da "API"
  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });
    _allNotifications = await fetchNotifications();
    _applyFilter(); // Aplica o filtro inicial (todos)
    setState(() {
      _isLoading = false;
    });
  }

  // Aplica o filtro atual à lista de notificações
  void _applyFilter() {
    setState(() {
      switch (_currentFilter) {
        case FilterType.comum:
          _filteredNotifications = _allNotifications
              .where((n) => n.type == NotificationType.comum)
              .toList();
          break;
        case FilterType.emergencia:
          _filteredNotifications = _allNotifications
              .where((n) => n.type == NotificationType.emergencia)
              .toList();
          break;
        case FilterType.todos:
        default:
          _filteredNotifications = List.from(_allNotifications);
          break;
      }
    });
  }

  // Exibe o diálogo de detalhes da notificação
  void _showNotificationDialog(
      BuildContext context, Notification notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            notification.type == NotificationType.emergencia
                ? 'Alerta de Emergência'
                : 'Detalhes da Notificação',
            style: TextStyle(
                color: notification.type == NotificationType.emergencia
                    ? Colors.red
                    : Colors.black87),
          ),
          content: SingleChildScrollView(child: Text(notification.fullText)),
          actions: <Widget>[
            TextButton(
              child: const Text('Fechar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // NOVO: Exibe o diálogo para seleção do filtro
  void _showFilterDialog() {
    FilterType selectedFilter = _currentFilter; // Inicia com o filtro atual
    showDialog(
      context: context,
      builder: (context) {
        // Usamos StatefulBuilder para que o diálogo possa ter seu próprio estado
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filtrar Notificações'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<FilterType>(
                    title: const Text('Todos'),
                    value: FilterType.todos,
                    groupValue: selectedFilter,
                    onChanged: (value) =>
                        setDialogState(() => selectedFilter = value!),
                  ),
                  RadioListTile<FilterType>(
                    title: const Text('Comum'),
                    value: FilterType.comum,
                    groupValue: selectedFilter,
                    onChanged: (value) =>
                        setDialogState(() => selectedFilter = value!),
                  ),
                  RadioListTile<FilterType>(
                    title: const Text('Emergência'),
                    value: FilterType.emergencia,
                    groupValue: selectedFilter,
                    onChanged: (value) =>
                        setDialogState(() => selectedFilter = value!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentFilter = selectedFilter;
                      _applyFilter();
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Constrói cada item da lista (agora com Dismissible para exclusão)
  Widget _buildNotificationItem(Notification notification) {
    final Color itemColor = notification.type == NotificationType.emergencia
        ? Colors.red
        : Colors.black54;
    final IconData itemIcon =
        notification.isRead ? Icons.drafts_outlined : Icons.mail_outline;

    return Dismissible(
      key: Key(notification.id), // Chave única para o widget
      direction: DismissDirection
          .startToEnd, // Permite arrastar da esquerda para a direita
      onDismissed: (direction) {
        // Guarda o item removido e seu índice para o "Desfazer"
        final removedItem = notification;
        final removedItemIndex = _allNotifications.indexOf(removedItem);

        setState(() {
          // Remove da lista principal e aplica o filtro novamente
          _allNotifications.remove(removedItem);
          _applyFilter();
        });

        // Mostra uma SnackBar com a opção de desfazer
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Notificação excluída"),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: () {
                setState(() {
                  // Reinsere o item na posição original e aplica o filtro
                  _allNotifications.insert(removedItemIndex, removedItem);
                  _applyFilter();
                });
              },
            ),
          ),
        );
      },
      background: Container(
        color: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () {
          if (!notification.isRead) {
            setState(() => notification.isRead = true);
          }
          _showNotificationDialog(context, notification);
        },
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: Row(
                children: [
                  Icon(itemIcon, color: itemColor, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      notification.text,
                      style: TextStyle(
                        color: itemColor,
                        fontSize: 16,
                        fontWeight:
                            notification.type == NotificationType.emergencia
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, indent: 20, endIndent: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Cabeçalho com "Agenda" e "Filtro" (onPressed do filtro atualizado)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ReminderScreen(), // ou TelaAgenda() se for esse o nome da sua tela!
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF43A5B4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Agenda',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed:
                        _showFilterDialog, // Chama a função do diálogo de filtro
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    label: const Text('Filtro',
                        style: TextStyle(color: Colors.white)),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF6FB563),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(thickness: 1.5),
              const SizedBox(height: 8),

              // Corpo da lista de notificações (agora verifica o estado de loading)
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredNotifications.isEmpty
                        ? const Center(
                            child: Text('Nenhuma notificação encontrada.'))
                        : ListView.builder(
                            itemCount: _filteredNotifications.length,
                            itemBuilder: (context, index) {
                              return _buildNotificationItem(
                                  _filteredNotifications[index]);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
