import 'package:flutter/foundation.dart';
import 'package:odoo_api/odoo_api.dart';
import 'package:odoo_api/odoo_user_response.dart';

class ServerProvider with ChangeNotifier {
  String _host;
  String _user;
  String _password;
  String _database;
  String _sessionId;
  bool _isAuth;
  bool _debug = true;
  OdooClient _client;
  OdooUser authValues;

  getInstance({String user, String password, String database, String host}) {
    print({user, password, database, host});
    this._user = user;
    this._password = password;
    this._database = database;
    this._host = host;
    this._client = new OdooClient(this._host);
  }

  OdooClient get client {
    _client.debugRPC(true);
    return _client;
  }

  Future<List<dynamic>> getDatabases() async {
    this._client = new OdooClient(this._host);
    this._client.debugRPC(true);
    final response = await this._client.getDatabases();
    return response;
  }

  Future<bool> authentication() async {
    final auth = await this
        ._client
        .authenticate(this._user, this._password, this._database);
    this._isAuth = auth.isSuccess;
    this.authValues = auth.getUser();
    if (this._isAuth == true) {
      this._sessionId = auth.getSessionId();
      this._client.setSessionId(this._sessionId);
    }
    return this._isAuth;
  }

  update() {
    notifyListeners();
  }
}
