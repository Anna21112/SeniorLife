import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'cadastro.dart';
import 'esqueciSenha.dart';
import 'menuDependentes.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Senior Life',
      debugShowCheckedModeBanner: false,
      home: TelaLogin(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('pt', 'BR'), Locale('en', 'US')],
    );
  }
}

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  bool _carregando = false;

  Future<void> _fazerLogin() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();
    

    if (email.isEmpty || senha.isEmpty) {
      _mostrarErro('Preencha todos os campos.');
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://2d51-2804-61ac-110b-8200-449-b065-d943-e36e.ngrok-free.app/api/caregivers/login'), // Substitua pela sua URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': senha}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token']; // ajuste se o nome do campo for diferente

        // Salva o token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TelaAdicionarDependente()),
        );
      } else {
        _mostrarErro('E-mail ou senha inválidos.');
      }
    } catch (e) {
      _mostrarErro('Erro de conexão: $e');
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  void _mostrarErro(String mensagem) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Erro'),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          Center(child: _retanguloLogin()),
        ],
      ),
    );
  }

  Widget _retanguloLogin() {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6FF),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 4)),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset('assets/imagens/logo.png', height: 70),
            const SizedBox(height: 10),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(text: 'Bem-vindo(a) ao '),
                  TextSpan(
                    text: 'Sênior',
                    style: TextStyle(color: Colors.blue),
                  ),
                  TextSpan(text: ' '),
                  TextSpan(
                    text: 'Life',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            _campoTexto(
              label: 'E-mail',
              hint: 'exemplo@gmail.com',
              controller: _emailController,
            ),
            const SizedBox(height: 20),
            _campoTexto(
              label: 'Senha',
              hint: 'Digite sua senha',
              isSenha: true,
              controller: _senhaController,
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TelaRecuperarSenha(),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF31A2C6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 42),
                  ),
                  child: const Text(
                    'Esqueci minha senha',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaCadastro()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF31A2C6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text(
                    'Cadastre-se',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _carregando ? null : _fazerLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7AC77E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
              ),
              child: _carregando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Entrar',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
            ),

            const SizedBox(height: 10),

            // Botão de teste para pular o login
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TelaAdicionarDependente(),
                  ),
                );
              },
              child: const Text(
                'Entrar (Teste - pular login)',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoTexto({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isSenha = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            label,
            style: const TextStyle(color: Colors.black, fontSize: 18),
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            obscureText: isSenha,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFFFAFA),
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF31A2C6)),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFF31A2C6),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
