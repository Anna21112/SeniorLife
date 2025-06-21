import 'package:flutter/material.dart';
import 'widgets/navigation_bars.dart';

class TelaCadastroDependente extends StatelessWidget {
  const TelaCadastroDependente({super.key});

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
            _campoTexto(label: 'Nome:'),
            const SizedBox(height: 10),
            _campoTexto(label: 'Idade:'),
            const SizedBox(height: 10),
            _campoTexto(label: 'Endereço:'),
            const SizedBox(height: 10),
            _campoTextoGrande(label: 'Restrições:'),
          ],
        ),
      ),
    );
  }

  // Campo de texto padrão
  Widget _campoTexto({required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 5),
        TextField(
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

  // Campo de texto grande (para restrições)
  Widget _campoTextoGrande({required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 5),
        TextField(
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
