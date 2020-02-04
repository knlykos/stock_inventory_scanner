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
  AddProductScreen({this.stockInventoryId, this.inventoryId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Inventario'),
          actions: <Widget>[],
        ),
        body: addProduct(
          inventoryId: inventoryId,
        ));
  }
}

class addProduct extends StatefulWidget {
  int stockInventoryId;
  int inventoryId;
  addProduct({this.stockInventoryId, this.inventoryId});
  @override
  _addProductState createState() => _addProductState();
}

class _addProductState extends State<addProduct> {
  List<dynamic> productList = ['asdasd', 'asdasdas'];
  List<dynamic> products;
  dynamic product;
  ServerProvider serverProvider;
  StockInventoryLineState stockInvState;
  final TextEditingController productTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final serverProvider = Provider.of<ServerProvider>(context);
    final stockInvState = Provider.of<StockInventoryLineState>(context);
    getStockInventoryLineState(stockInvState, serverProvider, widget);
    print({
      'estadoooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo',
      jsonEncode(stockInvState.stockInventoryLineState)
    });
    return Container(
      padding: EdgeInsets.all(15),
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
          ),
          TextField(
            decoration: (InputDecoration(labelText: 'Cantidad Real')),
          ),
          DropdownButton<dynamic>(
            isExpanded: true,
            value: this.product,
            icon: Icon(Icons.keyboard_arrow_down),
            iconSize: 24,
            elevation: 16,
            onChanged: (dynamic product) {
              setState(() {
                this.product = product;
              });
            },
            items: this
                .productList
                .map<DropdownMenuItem<dynamic>>((dynamic value) {
              return DropdownMenuItem<dynamic>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
