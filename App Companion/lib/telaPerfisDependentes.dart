import 'package:flutter/material.dart';
import 'dart:async';

// --- Modelo de Dados ---
class Profile {
  final int id;
  String name;

  Profile({required this.id, required this.name});
}

// --- Simulação do Serviço de API ---
class ProfileApiService {
  // Lista em memória para simular um banco de dados
  static final List<Profile> _profiles = [
    Profile(id: 1, name: 'Rogério Almeida'),
    Profile(id: 2, name: 'Clark Quente'),
    Profile(id: 3, name: 'Chico Moedas'),
  ];

  // Simula a busca de perfis da API
  static Future<List<Profile>> getProfiles() async {
    await Future.delayed(const Duration(seconds: 2)); // Simula latência de rede
    return List.from(_profiles);
  }

  // Simula a exclusão de um perfil
  static Future<void> deleteProfile(int id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _profiles.removeWhere((profile) => profile.id == id);
  }

  // Simula a atualização de um perfil
  static Future<void> updateProfile(int id, String newName) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _profiles.indexWhere((profile) => profile.id == id);
    if (index != -1) {
      _profiles[index].name = newName;
    }
  }
}

// --- Ponto de Entrada da Aplicação ---
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Perfis',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        // A thematização da AppBar foi mantida, caso você decida adicioná-la de volta.
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF31A1C6),
          foregroundColor: Colors.white,
          elevation: 1,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const ProfileManagementScreen(),
    );
  }
}

// --- Tela Principal ---
class ProfileManagementScreen extends StatefulWidget {
  const ProfileManagementScreen({super.key});

  @override
  State<ProfileManagementScreen> createState() =>
      _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen> {
  late Future<List<Profile>> _profilesFuture;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  // Carrega ou recarrega os perfis
  void _loadProfiles() {
    setState(() {
      _profilesFuture = ProfileApiService.getProfiles();
    });
  }

  // Mostra o diálogo de confirmação para exclusão
  void _showDeleteConfirmation(Profile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o perfil de ${profile.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Não'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              // Mostra um indicador de carregamento
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );

              await ProfileApiService.deleteProfile(profile.id);

              Navigator.of(context).pop(); // Fecha o loading
              Navigator.of(context).pop(); // Fecha o diálogo de confirmação
              _loadProfiles(); // Recarrega a lista
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // O Scaffold agora não tem mais a propriedade 'appBar'.
    return Scaffold(
      body: FutureBuilder<List<Profile>>(
        future: _profilesFuture,
        builder: (context, snapshot) {
          // Em carregamento
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Se houver erro
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar perfis: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar Novamente'),
                    onPressed: _loadProfiles,
                  ),
                ],
              ),
            );
          }
          // Se os dados foram carregados com sucesso
          final profiles = snapshot.data!;

          if (profiles.isEmpty) {
            return const Center(child: Text('Nenhum perfil encontrado.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: profiles.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Colors.green[100],
                  child: Text(
                    profile.name.isNotEmpty
                        ? profile.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(profile.name),
                trailing: Wrap(
                  spacing: 8, // espaço entre os botões
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF31A1C6),
                        foregroundColor: Colors.white,
                      ),
                      // AÇÃO: Navega para a tela de edição que você irá criar
                      onPressed: () {
                        // O código abaixo irá causar um erro até que a tela EditProfileScreen seja criada e importada.
                        /*
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                EditProfileScreen(profile: profile),
                          ),
                        );
                        */
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Navegando para a tela de edição...'),
                          ),
                        );
                      },
                      child: const Text('Editar'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF0000),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _showDeleteConfirmation(profile),
                      child: const Text('Excluir'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
