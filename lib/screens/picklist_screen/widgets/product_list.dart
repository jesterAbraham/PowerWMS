import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:scanner/api.dart';
import 'package:scanner/models/picklist_line.dart';
import 'package:scanner/widgets/barcode_input.dart';

filter(String search) => (PicklistLine line) =>
    search == '' || line.product.ean == search || line.product.uid == search;

class ProductList extends StatefulWidget {
  const ProductList(this.lines, {Key? key}) : super(key: key);

  final List<PicklistLine> lines;

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    var test = filter(_search);
    return SliverList(
        delegate: SliverChildListDelegate([
              Column(
                children: [
                  ListTile(
                    title: BarcodeInput((value, barcode) {
                      setState(() {
                        _search = value;
                        final lines = widget.lines.where(test);
                        if (lines.length == 1) {
                          Navigator.of(context)
                              .pushNamed('/product', arguments: lines.first);
                        }
                      });
                    }),
                  ),
                  Divider(),
                ],
              ),
            ].toList() +
            widget.lines
                .where(test)
                .map((line) => Column(
                      children: [
                        ListTile(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed('/product', arguments: line);
                          },
                          leading: Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: FutureBuilder<Response<Uint8List>>(
                              future: getProductImage(line.product.id),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Image.memory(snapshot.data!.data!);
                                }
                                return Center(
                                    child:
                                        Text(line.product.uid.substring(0, 1)));
                              },
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(line.product.uid,
                                  style: TextStyle(fontSize: 13)),
                              Text(
                                line.product.description,
                                style: TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text('${line.pickAmount} x ${line.product.unit}'),
                              Text(line.location ?? '',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[400],
                                  )),
                            ],
                          ),
                          trailing: Icon(Icons.chevron_right),
                        ),
                        Divider(height: 5),
                      ],
                    ))
                .toList()));
  }
}
