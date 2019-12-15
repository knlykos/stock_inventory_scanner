import 'package:stock_inventory_scanner/provider/server_provider.dart';

class StockInventoryLineState extends ServerProvider {
  List<dynamic> _allProductsBarcodes;

  List<dynamic> get allProductsBarcodes {
    return _allProductsBarcodes;
  }

  set allProductsBarcodes(List<dynamic> barcodes) {
    _allProductsBarcodes = barcodes;
  }
}
