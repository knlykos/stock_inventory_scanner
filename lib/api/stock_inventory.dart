import 'package:stock_inventory_scanner/provider/server_provider.dart';

Future<List<dynamic>> getStockInventory(ServerProvider serverProvider) async {
  List<dynamic> response = [];

  final stockInventory =
  await serverProvider.client.searchRead('stock.inventory', [
    ["state", "=", "confirm"]
  ], [
    "name",
    "date",
    "location_ids",
    "product_ids",
    "company_id",
    "state"
  ]);

  if (!stockInventory.hasError()) {
    response = stockInventory.getResult()['records'];
  }
  return response;
}
