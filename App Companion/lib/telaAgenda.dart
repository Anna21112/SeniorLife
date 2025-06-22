import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importe para formatação de data
import 'package:table_calendar/table_calendar.dart';
import 'widgets/navigation_bars.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  late final ValueNotifier<Map<DateTime, List<String>>> _events;
  final TextEditingController _eventController = TextEditingController();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    final may2025 = DateTime.utc(2025, 5);
    final june2025 = DateTime.utc(2025, 6, 21); // Dia atual para exemplo
    _events = ValueNotifier({
      DateTime.utc(may2025.year, may2025.month, 15): [
        'Consulta com o Dr. Steve'
      ],
      DateTime.utc(may2025.year, may2025.month, 23): ['Exame de Sangue'],
      // Adicionando um evento no dia de hoje para teste
      DateTime.utc(june2025.year, june2025.month, june2025.day): [
        'Entregar projeto Flutter'
      ],
    });
  }

  @override
  void dispose() {
    _events.dispose();
    _eventController.dispose();
    super.dispose();
  }

  List<String> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _events.value[normalizedDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Lembrete'),
          content: TextField(
            controller: _eventController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Digite seu lembrete',
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Adicionar'),
              onPressed: () {
                if (_eventController.text.isEmpty) return;
                final normalizedDay = DateTime.utc(
                    _selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
                _events.value = {
                  ..._events.value,
                  normalizedDay: [
                    ..._getEventsForDay(normalizedDay),
                    _eventController.text,
                  ],
                };
                _eventController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Alinha o título à esquerda
            children: [
              // Calendário
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.lightBlue.shade200),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: TableCalendar(
                  locale: 'pt_BR',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: _onDaySelected,
                  calendarFormat: CalendarFormat.month,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(fontSize: 18.0),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue.shade400,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: Colors.red[700],
                      shape: BoxShape.circle,
                    ),
                  ),
                  eventLoader: _getEventsForDay,
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24.0),

              // Título da seção de lembretes
              Text(
                'Lembretes do Mês', // Título alterado
                style: Theme.of(context)
                    .textTheme
                    .titleLarge, // Estilo um pouco maior
              ),
              const SizedBox(height: 8.0),

              // Lista de lembretes do mês
              ValueListenableBuilder<Map<DateTime, List<String>>>(
                valueListenable: _events,
                builder: (context, value, _) {
                  final eventsForMonth = value.entries
                      .where((entry) =>
                          entry.key.month == _focusedDay.month &&
                          entry.key.year == _focusedDay.year)
                      .toList();
                  eventsForMonth.sort((a, b) => a.key.compareTo(b.key));
                  if (eventsForMonth.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                            'Nenhum lembrete para este mês.'), // Mensagem alterada
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: eventsForMonth.length,
                    itemBuilder: (context, index) {
                      final entry = eventsForMonth[index];
                      final day = entry.key;
                      final events = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Dia ${DateFormat.d('pt_BR').format(day)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const Divider(),
                            ...events.map(
                              (event) => Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: ListTile(
                                  title: Text(event),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.remove_circle,
                                        color: Colors.red),
                                    onPressed: () {
                                      final normalizedDay = DateTime.utc(
                                          day.year, day.month, day.day);
                                      final updatedEventsForDay =
                                          List<String>.from(events)
                                            ..remove(event);
                                      final currentEvents =
                                          Map<DateTime, List<String>>.from(
                                              _events.value);

                                      if (updatedEventsForDay.isEmpty) {
                                        currentEvents.remove(normalizedDay);
                                      } else {
                                        currentEvents[normalizedDay] =
                                            updatedEventsForDay;
                                      }
                                      _events.value = currentEvents;
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 40.0),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEventDialog,
        icon: const Icon(Icons.add),
        label: const Text('Novo Lembrete'),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
