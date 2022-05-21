import 'package:calendar_app/data_types/authentication.dart';
import 'package:calendar_app/main.dart';
import 'package:calendar_app/util/input_blocker.dart';
import 'package:flutter/material.dart';
import 'package:calendar_app/data_types/credentials.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _username;
  String? _password;

  String? _usernameErrorOverride;
  String? _passwordErrorOverride;

  Future<void> doLogin(bool newUser) async {
    if (_formKey.currentState!.validate()) {
      final result = await wrapServiceRequest(context, Authentication.login(
        UserCredentials(_username!, _password!), newUser
      ));

      if (result.ok) {
        switch (result.value!) {
          case LoginResult.wrongPassword: _passwordErrorOverride = 'Senha incorreta'; break;
          case LoginResult.wrongUsername: _usernameErrorOverride = 'Esse usuário não existe'; break;
          case LoginResult.takenUsername: _usernameErrorOverride = 'Esse usuário já existe'; break;
          case LoginResult.failed: break;
          case LoginResult.ok:
            Navigator.of(context).pushReplacementNamed(AppRoute.events.name);
            break;
        }

        _formKey.currentState!.validate();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 80,
          left: 30,
          right: 30,
        ),

        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Calendário',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),
                TextFormField(
                  maxLength: 50,
                  onChanged: (value) {
                    _username = value;
                    _usernameErrorOverride = null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (_usernameErrorOverride != null) return _usernameErrorOverride;
                    if (value == null || value.isEmpty) return 'Digite um nome';
                    if (value.contains(RegExp('[^a-zA-Z0-9_]+'))) return 'Caractere não é permitido';
                  },
                  decoration: const InputDecoration(
                    label: Text('Nome'),
                  ),
                ),

                const SizedBox(height: 20),
                TextFormField(
                  maxLength: 50,
                  obscureText: true,
                  onChanged: (value) {
                    _password = value;
                    _passwordErrorOverride = null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (_passwordErrorOverride != null) return _passwordErrorOverride;
                    if (value == null || value.isEmpty) return 'Digite uma senha';
                    if (value.contains(RegExp('[^a-zA-Z0-9_]+'))) return 'Caractere não é permitido';
                  },
                  decoration: const InputDecoration(
                    label: Text('Senha'),
                  ),
                ),

                const SizedBox(height: 40),
                TextButton(
                  child: const Text('Entrar'),
                  onPressed: () => doLogin(false),
                ),

                const SizedBox(height: 25),
                TextButton(
                  child: const Text('Criar nova conta'),
                  onPressed: () => doLogin(true),
                ),
              ],
            )
          ),
        ),
      ),
    );
  }
}