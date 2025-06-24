import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final nomeController = TextEditingController();
  final sobrenomeController = TextEditingController();
  final dataController = TextEditingController();
  final telefoneController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  Future<void> _enviarCadastro() async {
    final url = Uri.parse('https://2d51-2804-61ac-110b-8200-449-b065-d943-e36e.ngrok-free.app/api/caregivers/cadastro');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': emailController.text,
        'nome': nomeController.text,
        'senha': senhaController.text,
      }),
    );
    // Trate a resposta conforme necessário
    if (response.statusCode == 200) {
      Navigator.pop(context); 
    } else {
      // Erro
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(const Color(0xFF7AC77E)),
            shape: WidgetStateProperty.all(const CircleBorder()),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(''),
        titleTextStyle: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            constraints: const BoxConstraints.expand(),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/imagens/backgroundSenior.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(child: _retanguloCadastro()),
        ],
      ),
    );
  }

  Widget _retanguloCadastro() {
    return Container(
      margin: const EdgeInsets.all(30),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      width: 350,
      height: 700,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6FF),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 5),
            Text(
              'Cadastro',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _CampoTexto(label: 'Nome'),
            SizedBox(height: 15),
            _CampoTexto(label: 'Sobrenome'),
            SizedBox(height: 15),
            _CampoData(label: 'Data de Nascimento'),
            SizedBox(height: 15),
            _CampoTexto(label: 'Telefone'),
            SizedBox(height: 15),
            _CampoTexto(label: 'E-mail'),
            SizedBox(height: 25),
            _CampoTexto(label: 'Senha', isSenha: true), // <-- Aqui!
            SizedBox(height: 25),
            _BotaoContinuar(),
          ],
        ),
      ),
    );
  }
}

class _CampoTexto extends StatelessWidget {
  final String label;
  final bool isSenha;
  final TextEditingController controller;
  const _CampoTexto({required this.label, this.isSenha = false, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Text(
            '$label:',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 280,
          height: 40,
          child: TextField(
            controller: controller,
            obscureText: isSenha,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFFFAFA),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  width: 1,
                  color: Color(0xFF31A2C6),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  width: 2,
                  color: Color(0xFF31A2C6),
                ),
              ),
            ),
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}

class _CampoData extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  const _CampoData({required this.label, required this.controller});

  @override
  State<_CampoData> createState() => _CampoDataState();
}

class _CampoDataState extends State<_CampoData> {
  DateTime? _dataSelecionada;

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(() {
        _dataSelecionada = picked;
        widget.controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Text(
            '${widget.label}:',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontFamily: 'Open Sans',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 280,
          height: 40,
          child: TextField(
            controller: widget.controller,
            readOnly: true,
            onTap: () => _selecionarData(context),
            decoration: InputDecoration(
              hintText: 'dd/mm/aaaa',
              filled: true,
              fillColor: const Color(0xFFFFFAFA),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  width: 1,
                  color: Color(0xFF31A2C6),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  width: 2,
                  color: Color(0xFF31A2C6),
                ),
              ),
              suffixIcon: const Icon(
                Icons.calendar_today,
                color: Color(0xFF31A2C6),
              ),
            ),
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}