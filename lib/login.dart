import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:teste_login/dbHelper/mongodb.dart';
import 'package:teste_login/homePage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Verificar se o usuário já existe no MongoDB
        var existingUser = await MongoDatabase.userCollection.findOne({
          'email': googleUser.email,
        });

        if (existingUser == null) {
          // Se o usuário não existir, insira-o no MongoDB
          var newUser = {
            '_id': mongo.ObjectId(),
            'username': googleUser.displayName,
            'email': googleUser.email,
            'photoUrl': googleUser.photoUrl,
            // Outras informações, se necessário
          };
          await MongoDatabase.userCollection.insert(newUser);
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login bem-sucedido!'),
        ));

        // Navega para a HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao fazer login com Google: $e'),
      ));
    }
  }

  Future<void> _signOut() async {
    await _googleSignIn.signOut();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Você saiu da conta Google'),
    ));
    setState(() {
      _currentUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        actions: _currentUser != null
            ? [
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: _signOut,
                ),
              ]
            : null,
      ),
      body: Center(
        child: _currentUser == null
            ? ElevatedButton(
                onPressed: _signInWithGoogle,
                child: Text('Login com Google'),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Bem-vindo, ${_currentUser?.displayName}'),
                  ElevatedButton(
                    onPressed: _signOut,
                    child: Text('Sair'),
                  ),
                ],
              ),
      ),
    );
  }
}
