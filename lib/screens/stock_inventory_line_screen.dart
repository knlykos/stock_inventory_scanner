import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:odoo_api/odoo_api.dart';
import 'package:provider/provider.dart';
import 'package:stock_inventory_scanner/api/stock_inventory_line.dart';
import 'package:stock_inventory_scanner/provider/server_provider.dart';
import 'package:stock_inventory_scanner/provider/stock_inventory_line_state.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:stock_inventory_scanner/screens/add_product_screen.dart';

class StockInventoryLineScreen extends StatelessWidget {
  int stockInventoryId;
  int inventoryId;

  StockInventoryLineScreen({this.stockInventoryId, this.inventoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventario'),
        actions: <Widget>[],
      ),
      body: StockInventoryLineListView(
        inventoryId: inventoryId,
      ),
    );
  }
}

class StockInventoryLineListView extends StatefulWidget {
  final int stockInventoryId;
  final int inventoryId;

  StockInventoryLineListView({Key key, this.stockInventoryId, this.inventoryId})
      : super(key: key);
  @override
  _StockInventoryLineListViewState createState() =>
      _StockInventoryLineListViewState();
}

class _StockInventoryLineListViewState
    extends State<StockInventoryLineListView> {
  OdooClient client;
  List<dynamic> data;
  List<dynamic> products;
  int length;
  TextEditingController searchController;
  ServerProvider serverProvider;
  Future<List<dynamic>> productList;
  FocusNode myFocusNode;

  Image imageFromBase64String(String base64String) {
    if (base64String != null) {
      return Image.memory(base64Decode(base64String));
    }
  }

  String numberValidator(String value) {
    if (value == null) {
      return null;
    }
    final n = num.tryParse(value);
    if (n == null) {
      return '"$value" is not a valid number';
    }
    return null;
  }

  @override
  void initState() {
    myFocusNode = FocusNode();
    this.data = [];
    products = [];
    length = 0;
    // TODO: implement initState
    searchController = new TextEditingController();

    super.initState();
  }

  void dispose() {
    // Limpia el nodo focus cuando se haga dispose al formulario
    myFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serverProvider = Provider.of<ServerProvider>(context);
    final stockInvState = Provider.of<StockInventoryLineState>(context);

    getStockInventoryLineState(stockInvState, serverProvider, widget);
    // return Container();

    productList ??=
        getStockInventoryLineState(stockInvState, serverProvider, widget);
    var futureBuilder = FutureBuilder(
        future:
            getStockInventoryLineState(stockInvState, serverProvider, widget),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final records = snapshot.data[0]['line_ids'];
            final length = snapshot.data[0]['line_ids'].length;
            return ListView.builder(
              itemCount: length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(records[index]['product_id']['display_name']),
                  subtitle: Text(
                      'Cantidad ${records[index]['product_qty'].toString()}'),
                  trailing: Icon(Icons.edit),
                  onTap: () {},
                );
              },
            );
          } else {
            return Container(child: Text('Cargando'));
          }
        });
    return Container(
        child: Column(
      children: <Widget>[
        Container(
            width: MediaQuery.of(context).size.width,
            height: 30,
            color: Colors.white,
            child: Row(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      height: 30,
                      width: MediaQuery.of(context).size.width - 88,
                      child: TextField(
                          textAlign: TextAlign.center,
                          controller: searchController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 15, height: 1),
                          focusNode: myFocusNode,
                          autofocus: true,
                          onSubmitted: (e) {
                            readBarcode(
                                e, serverProvider, stockInvState, widget);
                          }
                          // onSubmitted: (e) {},
                          ),
                    ),
                  ],
                ),
                MaterialButton(
                  child: Icon(Icons.add),
                  onPressed: () {
                    // TODO: agregar una configuracion para pasar el dato al input o pasar el valor directo. en caso de formulas.
                    FlutterBarcodeScanner.scanBarcode(
                            "#ff6666", "Cancelar", true, ScanMode.DEFAULT)
                        .then((barcode) {
                      // readBarcode(
                      //     barcode, serverProvider, stockInvState, widget);
                      this.searchController.text = barcode;
                      this.myFocusNode.requestFocus();
                    });
                  },
                  color: Colors.red,
                  textColor: Colors.white,
                )
              ],
            )),
        Flexible(
          child: futureBuilder,
        ),
        RawMaterialButton(
            constraints: BoxConstraints.tight(
              Size(MediaQuery.of(context).size.width, 60),
            ),
            onPressed: () {
              print({
                'stockInvState',
                stockInvState.stockInventoryLineState[0]['location_ids'][0]
              });
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddProductScreen(
                            inventoryId: widget.inventoryId,
                            stockLocationId: stockInvState
                                .stockInventoryLineState[0]['location_ids'][0],
                          )));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.add),
                Text('AÑADIR PRODUCTO',
                    style: TextStyle(fontWeight: FontWeight.w800))
              ],
            ),
            elevation: 8,
            fillColor: Colors.white),
        RawMaterialButton(
          fillColor: Colors.green,
          constraints: BoxConstraints.tight(
            Size(MediaQuery.of(context).size.width, 60),
          ),
          onPressed: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.check,
                color: Colors.white,
              ),
              Text('VALIDAR',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, color: Colors.white))
            ],
          ),
          // shape: new CircleBorder(),
          elevation: 5,
        ),
      ],
    ));

    // return Container();
  }
}
