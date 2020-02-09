import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:stock_inventory_scanner/api/stock_inventory_line.dart';
import 'package:stock_inventory_scanner/provider/server_provider.dart';
import 'package:stock_inventory_scanner/provider/stock_inventory_line_state.dart';

class AddProductScreen extends StatelessWidget {
  int stockInventoryId;
  int inventoryId;
  int stockLocationId;
  AddProductScreen(
      {this.stockInventoryId, this.inventoryId, this.stockLocationId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Inventario'),
          actions: <Widget>[],
        ),
        body: AddProduct(
          inventoryId: inventoryId,
          stockLocationId: this.stockLocationId,
        ));
  }
}

class AddProduct extends StatefulWidget {
  int stockInventoryId;
  int inventoryId;
  int stockLocationId;
  AddProduct({this.stockInventoryId, this.inventoryId, this.stockLocationId});
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  List<dynamic> productList = ['asdasd', 'asdasdas'];
  List<dynamic> products;
  dynamic product;
  ServerProvider serverProvider;
  StockInventoryLineState stockInvState;
  TextEditingController productTextController;
  TextEditingController theoricalQtyController;
  TextEditingController qtyTextController;
  TextEditingController locationTextController;

  @override
  Widget build(BuildContext context) {
    this.productTextController = TextEditingController();
    this.theoricalQtyController = TextEditingController(text: '0.000');
    this.qtyTextController = TextEditingController(text: '1.000');
    this.locationTextController = TextEditingController();

    final serverProvider = Provider.of<ServerProvider>(context);
    final stockInvState = Provider.of<StockInventoryLineState>(context);
    getStockInventoryLineState(stockInvState, serverProvider, widget);
    print({
      'estadoooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo',
      jsonEncode(stockInvState.stockInventoryLineState)
    });
    final stockLocationData =
        stockLocationNameGet(widget.stockLocationId, serverProvider)
            .then((onValue) {
      print(onValue);
      this.locationTextController.text = onValue.data[0][1];
    }).catchError((onError) {
      print(onError);
    });

    return Container(
        child: Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(15),
          child: Column(
            children: <Widget>[
              TypeAheadField(
                suggestionsCallback: (pattern) async {
                  final response =
                      await nameSearch(pattern, context, serverProvider);

                  if (response.hasError() == false) {
                    return response.getResult();
                  }
                },
                itemBuilder: (context, suggestion) {
                  print({'sug', suggestion[1]});
                  return ListTile(
                    leading: Icon(Icons.shopping_cart),
                    title: Text(suggestion[1]),
                    // subtitle: Text('\$${suggestion['price']}'),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  this.product = suggestion;
                  stockInvState.stockInventoryLineState[0]['line_ids']
                      .asMap()
                      .forEach((f, i) {
                    if (i['product_id']['id'] == suggestion[0]) {
                      print(jsonEncode(i));
                      onChangeStockInventoryLine(i, serverProvider);
                    }
                  });

                  this.productTextController.text = suggestion[1];
                  // Navigator.of(context).push(
                  //     MaterialPageRoute(builder: (context) => AddProductScreen()));
                },
                textFieldConfiguration: TextFieldConfiguration(
                  controller: this.productTextController,
                  autofocus: true,
                  decoration: InputDecoration(labelText: 'Producto'),
                ),
              ),
              TextField(
                decoration: (InputDecoration(labelText: 'Cantidad Teorica')),
                controller: this.theoricalQtyController,
                enabled: false,
              ),
              TextField(
                decoration: (InputDecoration(labelText: 'Cantidad Real')),
                controller: this.qtyTextController,
              ),
              TypeAheadField(
                suggestionsCallback: (pattern) async {
                  final response =
                      await nameSearch(pattern, context, serverProvider);

                  if (response.hasError() == false) {
                    return response.getResult();
                  }
                },
                itemBuilder: (context, suggestion) {
                  print({'sug', suggestion[1]});
                  return ListTile(
                    leading: Icon(Icons.shopping_cart),
                    title: Text(suggestion[1]),
                    // subtitle: Text('\$${suggestion['price']}'),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  this.product = suggestion;
                  stockInvState.stockInventoryLineState[0]['line_ids']
                      .asMap()
                      .forEach((f, i) {
                    if (i['product_id']['id'] == suggestion[0]) {
                      print(jsonEncode(i));
                      onChangeStockInventoryLine(i, serverProvider);
                    }
                  });

                  this.productTextController.text = suggestion[1];
                  // Navigator.of(context).push(
                  //     MaterialPageRoute(builder: (context) => AddProductScreen()));
                },
                textFieldConfiguration: TextFieldConfiguration(
                  controller: this.locationTextController,
                  autofocus: true,
                  decoration: InputDecoration(labelText: 'Ubicacion'),
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: Container(),
        ),
        Row(
          children: <Widget>[
            RawMaterialButton(
                constraints: BoxConstraints.tight(
                  Size(MediaQuery.of(context).size.width / 2, 60),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddProductScreen(
                                inventoryId: widget.inventoryId,
                              )));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('DESCARTAR',
                        style: TextStyle(fontWeight: FontWeight.w800))
                  ],
                ),
                elevation: 1,
                fillColor: Colors.white),
            RawMaterialButton(
                constraints: BoxConstraints.tight(
                  Size(MediaQuery.of(context).size.width / 2, 60),
                ),
                onPressed: () {
                  print(this.product[0]);
                  final productWrite = {
                    "product_qty": this.qtyTextController.value.text,
                    "location_id": widget.stockLocationId,
                    "product_id": this.product[0],
                    "product_lot_id": false,
                    "package_id": false
                  };

                  print(productWrite);
                  // createProduct(e, serverProvider);
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => AddProductScreen(
                  //               inventoryId: widget.inventoryId,
                  //             )));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('CONFIRMAR',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.white))
                  ],
                ),
                elevation: 1,
                fillColor: Colors.green)
          ],
        )
      ],
    ));
  }
}
