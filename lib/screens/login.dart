import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'create_products.dart';
import 'home.dart';
import 'registration.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // void _Login(String username, String password, BuildContext context) async {
  //   ProviderState _providerState =
  //       Provider.of<ProviderState>(context, listen: false);
  //   try {
  //     if (await _providerState.LoginUser(email, password)) {
  //       Navigator.pushReplacement(context,
  //           MaterialPageRoute(builder: (context) => ProviderDashboard()));
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  String _email, _password;

  var _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              margin: EdgeInsets.all(10),
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        validator: (item) {
                          return item.contains("@")
                              ? null
                              : "Enter Valid Email";
                        },
                        onChanged: (item) {
                          setState(() {
                            _email = item;
                          });
                        },
                        decoration: InputDecoration(
                            hintText: "Enter ",
                            labelText: "Email",
                            border: OutlineInputBorder()),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        validator: (item) => item.length >= 6
                            ? null
                            : "Password must be 6 characters",
                        onChanged: (item) {
                          setState(() {
                            _password = item;
                          });
                        },
                        decoration: InputDecoration(
                            hintText: "Enter Password",
                            labelText: "Password",
                            border: OutlineInputBorder()),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        width: double.infinity,
                        child: RaisedButton(
                          color: Colors.green,
                          onPressed: () {
                            login();
                          },
                          child: Text('Login'),
                          textColor: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Registration()));
                            },
                            child: Text(
                              'Register Here',
                              style: TextStyle(fontSize: 15),
                            )),
                        alignment: Alignment.centerRight,
                      ),
                    ],
                  )),
            ),
    );
  }

  Duration get loginTime => Duration(milliseconds: 2250);
  void login() {
    if (_formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _password)
          .then((user) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: "Login Successful");
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false);
      }).catchError((onError) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: "error" + onError.toString());
      });
    }
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoggedIn = false;

  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  _login() async {
    try {
      await _googleSignIn.signIn();
      setState(() {
        _isLoggedIn = true;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => CreateBooks()));
      });
    } catch (err) {
      print(err);
    }
  }

  _logout() {
    _googleSignIn.signOut();
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: _isLoggedIn
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.network(
                      _googleSignIn.currentUser.photoUrl,
                      height: 50.0,
                      width: 50.0,
                    ),
                    Text(_googleSignIn.currentUser.displayName),
                    OutlineButton(
                      child: Text("Logout"),
                      onPressed: () {
                        _logout();
                        //Navigator.pushReplacement(context, MaterialPageRoute(builder :(context)=> New()));
                      },
                    )
                  ],
                )
              : Center(
                  child: OutlineButton(
                    child: Text("Login with Google"),
                    onPressed: () {
                      _login();
                    },
                  ),
                )),
    );
  }
}
