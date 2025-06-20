import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';

class MenuGerenciamento extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Definindo cores para fácil customização
    const Color borderColor = Color(0xFF4CAF50); // Verde da borda
    const Color addIconBgColor = Color(0xFF65B868); // Verde do ícone de adicionar
    const Color editIconColor = Color(0xFF47A5C5); // Azul do ícone de editar

    return Card(
      // Card para dar o efeito de elevação e cantos arredondados
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: const BorderSide(color: borderColor, width: 2.0),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        width: 300, // Largura do menu, ajuste conforme necessário
        child: Column(
          mainAxisSize: MainAxisSize.min, // Faz a coluna ter o tamanho dos filhos
          children: [
            // --- Seção da Lista de Dependentes ---
            _buildDependentRow(
              icon: Icons.person_outline,
              name: 'Rogério Almeida',
              onTap: () {
                print('Selecionou Rogério Almeida');
              },
            ),
            _buildDependentRow(
              icon: Icons.person_outline,
              name: 'Clark Quente',
              onTap: () {
                print('Selecionou Clark Quente');
              },
            ),
            _buildDependentRow(
              icon: Icons.person_outline,
              name: 'Chico Moedas',
              onTap: () {
                print('Selecionou Chico Moedas');
              },
            ),

            // --- Divisor ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Divider(
                thickness: 1.0,
                color: Colors.black38,
              ),
            ),

            // --- Seção de Ações ---
            _buildActionRow(
              title: 'Adicionar dependente',
              iconWidget: const CircleAvatar(
                radius: 14,
                backgroundColor: addIconBgColor,
                child: Icon(Icons.add, color: Colors.white, size: 20),
              ),
              onTap: () {
                print('Clicou em Adicionar dependente');
              },
            ),
            _buildActionRow(
              title: 'Editar Dependentes',
              iconWidget: const Icon(Icons.edit, color: editIconColor, size: 28),
              onTap: () {
                print('Clicou em Editar Dependentes');
              },
            ),
          ],
        ),
      ),
    );
  }

}
// ...existing code...
Widget _buildDependentRow({
  required IconData icon,
  required String name,
  required VoidCallback onTap,
}) {
  return ListTile(
    leading: Icon(icon),
    title: Text(name),
    onTap: onTap,
  );
}

Widget _buildActionRow({
  required String title,
  required Widget iconWidget,
  required VoidCallback onTap,
}) {
  return ListTile(
    leading: iconWidget,
    title: Text(title),
    onTap: onTap,
  );
}