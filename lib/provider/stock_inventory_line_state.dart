import 'package:stock_inventory_scanner/provider/server_provider.dart';

class StockInventoryLineState extends ServerProvider {
  List<dynamic> _stockInventoryLineState;
  List<dynamic> _allProductsBarcodes;

  List<dynamic> get stockInventoryLineState {
    return _stockInventoryLineState;
  }

  set stockInventoryLineState(List<dynamic> state) {
    _stockInventoryLineState = state;
  }

  List<dynamic> get allProductsBarcodes {
    return _allProductsBarcodes;
  }

  set allProductsBarcodes(List<dynamic> barcodes) {
    _allProductsBarcodes = barcodes;
  }
}
