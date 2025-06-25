import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'global.dart';

// MODELO ACTIVITYITEM (ATUALIZADO)
class ActivityItem {
  final String id;
  final String time;
  final String activity;
  final String info;
  bool checked;

  ActivityItem({
    required this.id,
    required this.time,
    required this.activity,
    required this.info,
    this.checked = false,
  });

  // ALTERADO: Factory constructor agora lê o novo formato JSON da API
  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    bool isChecked = json['status'] == 'concluido';

    String formattedTime = "00:00";
    if (json['schedule'] != null) {
      try {
        DateTime parsedDate = DateTime.parse(json['schedule']);
        formattedTime = DateFormat('HH:mm').format(parsedDate);
      } catch (e) {
        print("Erro ao formatar data do JSON: $e");
      }
    }

    return ActivityItem(
      id: json['_id'] as String,
      time: formattedTime,
      activity: json['title'] as String, // Mapeia 'title' para 'activity'
      info: json['description'] as String,
      checked: isChecked,
    );
  }
}

class PhysicalActivityPage extends StatefulWidget {
  const PhysicalActivityPage({super.key});

  @override
  State<PhysicalActivityPage> createState() => _PhysicalActivityPageState();
}

class _PhysicalActivityPageState extends State<PhysicalActivityPage> {
  String? _userId;
  String? _userToken;
  List<ActivityItem> activityItems = [];
  bool isLoading = true;
  String? error;

  final TextStyle _popupTextStyle = const TextStyle(fontSize: 22);

  @override
  void initState() {
    super.initState();
    _loadUserDataAndFetchRoutines();
  }

  // ALTERADO: Nome da função para refletir que busca todas as rotinas
  Future<void> _loadUserDataAndFetchRoutines() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
      _userToken = prefs.getString('userToken');
    });

    if (_userId == null || _userToken == null) {
      setState(() {
        error = "Usuário não autenticado. Por favor, faça login novamente.";
        isLoading = false;
      });
      return;
    }
    _fetchRoutines();
  }

  // ALTERADO: Busca todas as rotinas e filtra por 'atividade fisica'
  Future<void> _fetchRoutines() async {
    if (_userId == null) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final url = Uri.parse('$apiUrl/api/rotinas/$_userId/activity');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $_userToken',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> decodedResponse = json.decode(response.body);
        List<dynamic> allActivities = decodedResponse['data']['activity'];

        // AQUI ESTÁ A MUDANÇA PRINCIPAL: Filtra por 'atividade fisica'
        List<ActivityItem> filteredItems = allActivities
            .where((item) => item['type'] == 'atividade fisica')
            .map((json) => ActivityItem.fromJson(json))
            .toList();

        setState(() {
          activityItems = filteredItems;
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Falha ao carregar atividades: ${response.statusCode}.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Ocorreu um erro de conexão: $e';
        isLoading = false;
      });
    }
  }

  // ALTERADO: Envia a atualização de status no formato que a API espera
  Future<void> _updateActivityItemStatus(
    String activityId,
    bool newCheckedStatus,
  ) async {
    if (_userToken == null) return;

    String newApiStatus = newCheckedStatus ? 'concluido' : 'pendente';

    try {
      final url = Uri.parse('$apiUrl/api/rotinas/$activityId');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $_userToken',
        },
        body: jsonEncode(<String, String>{'status': newApiStatus}),
      );

      if (response.statusCode == 200) {
        print('Status do item $activityId atualizado para $newApiStatus');
      } else {
        throw Exception('Falha ao atualizar status na API: ${response.body}');
      }
    } catch (e) {
      setState(() {
        final itemIndex = activityItems.indexWhere(
          (item) => item.id == activityId,
        );
        if (itemIndex != -1) {
          activityItems[itemIndex].checked = !newCheckedStatus;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao salvar alteração. Tente novamente.'),
        ),
      );
      print('Erro ao atualizar status do item $activityId: $e');
    }
  }

  void _showActivityInfo(
    BuildContext context,
    String activityName,
    String activityInfo,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Informações sobre:\n$activityName',
            style: _popupTextStyle.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Text(
              activityInfo,
              style: _popupTextStyle,
              textAlign: TextAlign.center,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Fechar',
                style: _popupTextStyle.copyWith(color: Colors.orange),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Center(
                  child: RichText(
                    text: const TextSpan(
                      text: 'Como estão suas ',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: 'Atividades',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: '?',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const SizedBox(width: 40 + 16),
                      SizedBox(
                        width: 80,
                        child: Text(
                          'Horário',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Atividade',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),
                const Divider(thickness: 1),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/elements/footer.png',
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  bottom: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: Image.asset(
                        'assets/icons/home.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                error!,
                style: const TextStyle(color: Colors.red, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _loadUserDataAndFetchRoutines,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }
    if (activityItems.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma atividade encontrada.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
      itemCount: activityItems.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final item = activityItems[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() => item.checked = !item.checked);
                _updateActivityItemStatus(item.id, item.checked);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(border: Border.all(width: 2)),
                child: item.checked
                    ? const Icon(Icons.check, color: Colors.green, size: 35.0)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 60,
              child: Text(
                item.time,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.activity,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 36,
              height: 36,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Image.asset(
                  'assets/icons/info_icon.png',
                  fit: BoxFit.contain,
                ),
                onPressed: () =>
                    _showActivityInfo(context, item.activity, item.info),
              ),
            ),
          ],
        );
      },
    );
  }
}
