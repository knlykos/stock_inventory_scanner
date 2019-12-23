import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:odoo_api/odoo_api.dart';
import 'package:provider/provider.dart';
import 'package:stock_inventory_scanner/api/stock_inventory_line.dart';
import 'package:stock_inventory_scanner/provider/server_provider.dart';
import 'package:stock_inventory_scanner/provider/stock_inventory_line_state.dart';
//import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class StockInventoryLineScreen extends StatelessWidget {
  int stockInventoryId;
  int inventoryId;

  StockInventoryLineScreen({this.stockInventoryId, this.inventoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventario'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_to_photos),
            onPressed: () async {
//              final barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
//                  "#ff6666", "Cancel", true, ScanMode.BARCODE);
//              print(barcodeScanRes);
            },
          )
        ],
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

    getStockInventoryLineState() async {
      final result = await getSetBarcodeViewState(
          serverProvider: serverProvider, stockInventoryId: widget.inventoryId);
      stockInvState.stockInventoryLineState = result;
      final barcodes = await getAllBarcodes(serverProvider);
      stockInvState.allProductsBarcodes = barcodes;
      print({'barcodes', stockInvState.allProductsBarcodes});
      return result;
    }

    getStockInventoryLineState();
    // return Container();

    productList ??= getStockInventoryLineState();
    var futureBuilder = FutureBuilder(
        future: productList,
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final records = snapshot.data[0]['line_ids'];
            final length = snapshot.data[0]['line_ids'].length;
            print(snapshot.data[0]['line_ids']);
            print(json.encode(snapshot.data));
            print(length);
            return ListView.builder(
              itemCount: length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(records[index]['product_id']['display_name']),
                  subtitle: Text(
                      'Cantidad ${records[index]['product_qty'].toString()}'),
                  trailing: Icon(Icons.edit),
                  onTap: () {
//                    Navigator.push(
//                        context,
//                        MaterialPageRoute(
//                            builder: (context) => UpdateProductScreen(
//                              stockInventoryId: widget.stockInventoryId,
//                              stockInventoryLine: records[index],
//                              // title: records[index]['product'][0]
//                              //     ['display_name'],
//                            )));
                  },
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
          color: Colors.grey,
          child: TextField(
            textAlign: TextAlign.center,
            controller: searchController,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 15, height: 1),
            focusNode: myFocusNode,
            autofocus: true,
            onSubmitted: (e) {
              dynamic product;
              final barcodes = stockInvState.allProductsBarcodes;
              final state = stockInvState.stockInventoryLineState;
              final inventoryId = state[0]['id'];
              final locationStockId = state[0]['id'];
              final model = 'stock.inventory.line';
              final sessionData = serverProvider.authValues;
              int locationId;
              double qty;
              dynamic lineId;
              dynamic args;
              dynamic kargsParams;
              if (state[0]['line_ids'].length != 0) {
                for (var item in state[0]['line_ids']) {
                  if (item['product_id']['barcode'] == e) {
                    lineId = item;
                  }
                }

                qty = lineId['product_qty'] + 1;
                locationId = lineId['location_id'][0];
              } else {
                qty = 1;
                locationId = state[0]['location_ids'][0];
              }

              barcodes.asMap().forEach((i, f) {
                try {
                  if (f[e] != null) {
                    product = f[e];
                    args = {
                      'location_id': locationId,
                      'package_id': false,
                      'prod_lot_id': false,
                      'product_id': product['id'],
                      'product_qty': 1
                    };

                    kargsParams = {
                      'context': {
                        'lang': 'es_ES',
                        'tz': false,
                        'uid': 2,
                        'allowed_company_ids': [sessionData['company_id']],
                        'default_company_id': sessionData['company_id'],
                        'default_inventory_id': inventoryId,
                        'default_location_id': locationStockId,
                        'default_product_qty': 1,
                        'form_view_ref':
                            'stock_barcode.stock_inventory_line_barcode'
                      }
                    };
                  }
                } catch (e) {
                  print('El valor es null');
                }
                // if (f[i][e]['barcode'] == e) {
                //   product = f[e];
                //   print({
                //     'location_id': locationId,
                //     'package_id': false,
                //     'prod_lot_id': false,
                //     'product_id': product['id'],
                //     'product_qty': qty
                //   });

                serverProvider.client
                    .callKW(model, "create", [args], kwargs: kargsParams);
                // serverProvider.client.create('stock.inventory.line', {
                //   'location_id': 8,
                //   'package_id': false,
                //   'prod_lot_id': false,
                //   'product_id': product['id'],
                //   'product_qty': qty + 1
                // });
                // }
              });
            },
            // onSubmitted: (e) {},
          ),
        ),
        Flexible(
          child: futureBuilder,
        ),
        RawMaterialButton(
            constraints: BoxConstraints.tight(
              Size(MediaQuery.of(context).size.width, 60),
            ),
            onPressed: () {
//                  Navigator.push(context,
//                      MaterialPageRoute(builder: (context) => AddProductScreen()));
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
