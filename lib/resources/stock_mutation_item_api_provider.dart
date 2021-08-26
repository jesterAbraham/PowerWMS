import 'dart:async';

import 'package:dio/dio.dart';
import 'package:scanner/dio.dart';
import 'package:scanner/models/stock_mutation_item.dart';

class StockMutationItemApiProvider {
  Future<List<StockMutationItem>> getStockMutationItems(
    int picklistId,
    int productId,
  ) {
    return dio.post(
      '/stockmutation/list',
      data: {
        'productId': productId,
        'picklistId': picklistId,
        'skipPaging': true,
      },
    ).then((response) => (response.data!['data'] as List<dynamic>)
        .map((json) => StockMutationItem.fromJson(json))
        .toList());
  }

  Future<Response<Map<String, dynamic>>> cancelStockMutationItem(int id) {
    return dio.post('/stockmutation/$id/cancel');
  }
}