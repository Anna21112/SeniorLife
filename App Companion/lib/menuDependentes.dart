import 'package:flutter/material.dart';
import 'menuAddDependente.dart';
import 'widgets/navigation_bars.dart';

class TelaAdicionarDependente extends StatelessWidget {
  const TelaAdicionarDependente({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: const SizedBox.shrink(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TelaCadastroDependente(),
              ),
            );
          },
          icon: const Icon(Icons.add, color: Colors.green),
          label: const Text(
            'Adicionar dependente',
            style: TextStyle(color: Colors.black),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Colors.green),
            elevation: 3,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .centerDocked, // Centraliza acima da BottomBar
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
