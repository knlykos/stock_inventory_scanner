import 'package:odoo_api/odoo_api_connector.dart';
import 'package:stock_inventory_scanner/provider/models/response.dart';
import 'package:stock_inventory_scanner/provider/server_provider.dart';
import 'package:stock_inventory_scanner/provider/stock_inventory_line_state.dart';

readBarcode(String e, ServerProvider serverProvider,
    StockInventoryLineState stockInvState, dynamic widget) async {
  var changes =
      await setNewStockInventoryLine(e, stockInvState, serverProvider);
  // print({'dataaaaaaaaaaaaaaaaaaaaaaa', data.getError()});
  if (changes.hasError() == false) {
    await getStockInventoryLineState(stockInvState, serverProvider, widget);
    serverProvider.update();
  }
}

Future<List<dynamic>> getStockInventoryLineState(
    StockInventoryLineState stockInvState,
    ServerProvider serverProvider,
    dynamic widget) async {
  final result = await getSetBarcodeViewState(
      serverProvider: serverProvider, stockInventoryId: widget.inventoryId);
  stockInvState.stockInventoryLineState = result;
  final barcodes = await getAllBarcodes(serverProvider);
  stockInvState.allProductsBarcodes = barcodes;
  print({'barcodes', stockInvState.allProductsBarcodes});
  return result;
}

// TODO: convertir en clase y hacer enumeraciones llamada method, y color create, update, delete de odoo;
Future<OdooResponse> setNewStockInventoryLine(
    String e,
    StockInventoryLineState stockInvState,
    ServerProvider serverProvider) async {
  dynamic product;
  final barcodes = stockInvState.allProductsBarcodes;
  final state = stockInvState.stockInventoryLineState;
  final inventoryId = state[0]['id'];
  final locationStockId = state[0]['location_ids'][0];
  final model = 'stock.inventory.line';
  final sessionData = serverProvider.authValues;

  var productExistInList = false;
  String method;
  int locationId;
  double qty;
  dynamic lineId;
  dynamic args;
  dynamic kargsParams;
  Future<OdooResponse> response;
  bool hasPattern;
  bool hasError;

  // verifica si el codigo de barras esta formateado, para actualizar la cantidad indicada
  // el formado debe de ir formado por 3 puntos para indicar que se esta agregando el modificador.

  var barcode = e.split('...');

  if (barcode.length == 2) {
    if (barcode[0].length > 0) {
      if (barcode[1].length > 0) {
        // TODO: Crear una validacion y mostrar en el frontend un mensaje de error si fuera el caso.
        hasPattern = true;
      }
    }
    // busca si el producto se encuentra disponible en el estado
    // si se encuentra actualiza, sino crea uno nuevo en el servidor.
    // establece la variable con el nombre del metodo que se va a usar.
    e = barcode[0];
  } else {
    hasPattern = false;
  }
  if (state[0]['line_ids'].length != 0) {
    for (var item in state[0]['line_ids']) {
      if (item['product_id']['barcode'] == e) {
        productExistInList = true;
        method = 'write';
        lineId = item["id"];
        if (hasPattern) {
          qty = double.parse(barcode[1]);
        } else {
          qty = item['product_qty'] + 1;
        }
      }
      if (productExistInList != true) {
        method = 'create';
        qty = 1;
        locationId = state[0]['location_ids'][0];
      }
    }
  } else {
    method = 'create';
    qty = 1;
    locationId = state[0]['location_ids'][0];
  }

  kargsParams = {
    'context': {
      'lang': 'es_ES',
      'tz': false,
      'uid': 2,
      'allowed_company_ids': [sessionData.companyId],
      'default_company_id': sessionData.companyId,
      'default_inventory_id': inventoryId,
      'default_location_id': locationStockId,
      'default_product_qty': 1,
      'form_view_ref': 'stock_barcode.stock_inventory_line_barcode'
    }
  };

  switch (method) {
    case 'create':
      barcodes.asMap().forEach((i, f) {
        try {
          if (f[e] != null) {
            product = f[e];
            args = {
              'location_id': locationId,
              'package_id': false,
              'prod_lot_id': false,
              'product_id': product['id'],
              'product_qty': qty
            };
          }
        } catch (e) {
          print('El valor es null');
        }
      });
      response = serverProvider.client
          .callKW(model, method, [args], kwargs: kargsParams);
      break;
    case 'write':
      args = [
        [lineId],
        {'product_qty': qty}
      ];
      response = serverProvider.client
          .callKW(model, method, args, kwargs: kargsParams);
      break;
  }

  return response;
}

productExist() {}

Future<List<dynamic>> getSetBarcodeViewState(
    {ServerProvider serverProvider, int stockInventoryId}) async {
  print(stockInventoryId);
  List<dynamic> stockInventory;

  final stockInventoryRes =
      await serverProvider.client.searchRead('stock.inventory', [
    ['id', '=', stockInventoryId]
  ], [
    'id',
    'company_id',
    'line_ids',
    'location_ids',
    'product_ids',
    'name',
    'state'
  ]);
  stockInventory = stockInventoryRes.getResult()['records'];
  final lineIdsRes =
      await serverProvider.client.searchRead('stock.inventory.line', [
    ['id', 'in', stockInventory[0]['line_ids']]
  ], [
    'id',
    'location_id',
    'package_id',
    'product_id',
    'product_qty',
    'product_uom_id',
    'theoretical_qty'
  ]);
  List<int> productProductVals = [];
  for (var lineId in lineIdsRes.getResult()['records']) {
    productProductVals.add(lineId['product_id'][0]);
  }
  final stockInventoryLine = lineIdsRes.getResult()['records'];
  final productProductRes =
      await serverProvider.client.searchRead('product.product', [
    ['id', 'in', productProductVals]
  ], [
    'barcode',
    'id',
    'display_name',
    'tracking'
  ]);
  final productProduct = productProductRes.getResult()['records'];

  for (var stockLine in stockInventoryLine) {
    for (var product in productProduct) {
      if (stockLine['product_id'][0] == product['id']) {
        stockLine['product_id'] = product;
      }
    }
  }
  stockInventory[0]['line_ids'] = stockInventoryLine;
  // print({'stockInventory', json.encode(stockInventory)});
  return stockInventory;
}

Future<List<dynamic>> getAllBarcodes(ServerProvider serverProvider) async {
  List<dynamic> response = [];
  dynamic barcodeProducts;

  final barcodeProductsRes =
      await serverProvider.client.searchRead('product.product', [
    ['barcode', '!=', false]
  ], [
    'id',
    'display_name',
    'barcode',
    'name',
    'tracking',
    'uom_id'
  ]);

  if (!barcodeProductsRes.hasError()) {
    barcodeProducts = barcodeProductsRes.getResult()['records'];
    print(barcodeProducts.length);
    for (var item in barcodeProducts) {
      // print(item);
      response.add({item['barcode']: item});
    }
  }
  return response;
}

getAllLocationByBarcode(ServerProvider serverProvider) async {
  List<Map<String, dynamic>> response = [];
  dynamic barcodeLocations;
  final barcodeLocationsRes =
      await serverProvider.client.searchRead('stock.location', [
    ['barcode', '!=', false]
  ], [
    'id',
    'display_name',
    'barcode',
    'parent_path',
  ]);

  if (!barcodeLocationsRes.hasError()) {
    barcodeLocations = barcodeLocationsRes.getResult()['records'];
    print(barcodeLocations.length);
    for (var item in barcodeLocations) {
      response.add({item['barcode']: item});
    }
    print(response);
    return response;
  }
}

getBarcodeNomenclatures(ServerProvider serverProvider) async {
  List<Map<String, dynamic>> response = [];
  String path = '/web/dataset/call_kw/barcode.rule/search_read';
  serverProvider.client.connect();
  Map<String, dynamic> params = {
    "args": [
      [
        ["barcode_nomenclature_id", "=", 1]
      ],
      ["name", "sequence", "type", "encoding", "pattern", "alias"]
    ],
    "model": "barcode.rule",
    "method": "search_read",
    "kwargs": {}
  };
  Map payload = serverProvider.client.createPayload(params);
  String url = serverProvider.client.createPath(path);
  final barcodeNomRes = await serverProvider.client.callRequest(url, payload);
  if (!barcodeNomRes.hasError()) {
    response = barcodeNomRes.getResult()['records'];
  }
  return response;
}

Future<OdooResponse> nameSearch(
    e, context, ServerProvider serverProvider) async {
  const model = 'product.product';
  const method = 'name_search';
  final args = [];
  final kwargs = {
    "name": e,
    "args": [
      [
        "type",
        "in",
        ["product"]
      ]
    ],
    "operator": "ilike",
    "limit": 8,
    "context": {
      "lang": "es_ES",
      "tz": false,
      "uid": 2,
      "allowed_company_ids": [1]
    }
  };
  // TODO: Descomentar para llamar a la api
  var data =
      await serverProvider.client.callKW(model, method, args, kwargs: kwargs);
  return data;
}

onChangeStockInventoryLine(
    dynamic product, ServerProvider serverProvider) async {
  print(product);
  const model = 'stock.inventory.line';
  const method = 'onchange';
  final args = [
    [],
    {
      "product_qty": product['product_qty'],
      "company_id": 1,
      "location_id": product['location_id'][0],
      "product_tracking": product['product_id']['tracking'],
      "state": false,
      "product_id": product['product_id']['id'],
      "prod_lot_id": false,
      "theoretical_qty": product['theoretical_qty'],
      "product_uom_id": false,
      "package_id": false
    },
    "product_id",
    {
      "product_tracking": "",
      "state": "",
      "product_id": "1",
      "prod_lot_id": "1",
      "theoretical_qty": "",
      "product_qty": "",
      "company_id": "",
      "product_uom_id": "1",
      "location_id": "1",
      "package_id": "1"
    }
  ];
  final kwargs = {
    "context": {
      "lang": "en_US",
      "tz": false,
      "uid": 2,
      "allowed_company_ids": [1],
      "default_company_id": 1,
      "default_inventory_id": 1,
      "default_location_id": 8,
      "default_product_qty": 1,
      "form_view_ref": "stock_barcode.stock_inventory_line_barcode"
    }
  };
  // TODO: Descomentar para llamar a la api
  var data =
      await serverProvider.client.callKW(model, method, args, kwargs: kwargs);
  return data;
}

Future<OdooResponse> readProduct(
    int productId, ServerProvider serverProvider) async {
  List<dynamic> stockInventory;
  final lineIdsRes =
      await serverProvider.client.searchRead('stock.inventory.line', [
    ['id', 'in', productId]
  ], [
    "product_tracking",
    "state",
    "product_id",
    "prod_lot_id",
    "theoretical_qty",
    "product_qty",
    "company_id",
    "product_uom_id",
    "location_id",
    "package_id",
    "display_name"
  ]);
  return lineIdsRes;
}

Future<ResponseApi> createProduct(
    dynamic odooRequest, ServerProvider serverProvider) async {
  ResponseApi response = new ResponseApi();
  // Recibe este map
  // {
  //   "product_qty": 2,
  //   "location_id": 8,
  //   "product_id": 8,
  //   "product_lot_id": false,
  //   "package_id": false
  // }
  OdooResponse odooResponse =
      await serverProvider.client.create('stock.inventory.line', odooRequest);

  if (odooResponse.hasError() == false) {
    response.code = odooResponse.getStatusCode();
    response.message = 'ok';
    response.data = odooResponse.getResult();
  } else {
    response.code = odooResponse.getStatusCode();
    response.message = odooResponse.getErrorMessage();
    response.data = [];
  }

  return response;
}

Future<ResponseApi> stockLocationNameGet(
    int locationId, ServerProvider serverProvider) async {
  ResponseApi response = new ResponseApi();
  var data = await serverProvider.client.callKW('stock.location', 'name_get', [
    [locationId]
  ], kwargs: {});

  if (data.hasError() == false) {
    response.code = data.getStatusCode();
    response.message = 'ok';
    response.data = data.getResult();
  } else {
    response.code = data.getStatusCode();
    response.message = data.getErrorMessage();
    response.data = [];
  }
  return response;
}
