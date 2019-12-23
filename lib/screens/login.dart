import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_inventory_scanner/provider/server_provider.dart';
import 'package:stock_inventory_scanner/screens/stock_inventory_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // OdooClient client;
  final odooUrl = TextEditingController(text: 'https://nkodex.odoo.com');
  final odooUser = TextEditingController(text: 'nlopezg87@gmail.com');
  final odooPassword = TextEditingController(text: 'Nefo123..');
  final odooDB = TextEditingController();
  String dbSelected;
  List odooDBList;
  @override
  void initState() {
    super.initState();
    this.dbSelected = null;
    this.odooDBList = [''];
  }

  @override
  Widget build(BuildContext context) {
    final serverProvider = Provider.of<ServerProvider>(context);

    final snackBar = SnackBar(
        content: Text('Verifique sus credenciales'),
        action: SnackBarAction(
          label: 'REINTENTAR',
          onPressed: () {},
        ));

    void getDatabaseList() async {
      serverProvider.getInstance(host: odooUrl.text);
      var dbs = await serverProvider.getDatabases();
      print(dbs);
      setState(() {
        this.odooDBList = dbs;
      });
    }

    // final GlobalKey<ScaffoldState> _scaffoldKey =
    //     new GlobalKey<ScaffoldState>();
    Future<bool> serverAuth() async {
      serverProvider.getInstance(
          user: odooUser.text,
          password: odooPassword.text,
          database: dbSelected,
          host: odooUrl.text);

      final auth = await serverProvider.authentication();
      print(auth);
      return auth;
    }

    return Scaffold(body: Builder(
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Container(),
              ),
              Container(
                child: Text(
                  'Welcome Back!',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                ),
              ),
              TextFormField(
                controller: odooUrl,
                obscureText: false,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    hintText: 'URL',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () {
                        getDatabaseList();
                      },
                    )),
                onSaved: (e) {
                  // print(e);
                },
              ),
              DropdownButton<dynamic>(
                isExpanded: true,
                value: this.dbSelected,
                icon: Icon(Icons.keyboard_arrow_down),
                iconSize: 24,
                elevation: 16,
                onChanged: (dynamic newValue) {
                  setState(() {
                    this.dbSelected = newValue;
                  });
                },
                items: this
                    .odooDBList
                    .map<DropdownMenuItem<dynamic>>((dynamic value) {
                  return DropdownMenuItem<dynamic>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              TextFormField(
                controller: odooUser,
                obscureText: false,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(hintText: 'Usuario'),
              ),
              TextFormField(
                controller: odooPassword,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(hintText: 'Contraseña'),
              ),
              Expanded(
                child: Container(),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      color: Colors.indigo,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text('Login'),
                      onPressed: () async {
                        final isAuth = await serverAuth();
                        print(isAuth);

                        if (isAuth) {
                          print('is Auth');
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      StockInventoryScreen()));
                        } else {
                          Scaffold.of(context).showSnackBar(snackBar);
                        }
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    ));
  }
}
