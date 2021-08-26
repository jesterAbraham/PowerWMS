import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scanner/models/picklist_line.dart';
import 'package:scanner/models/settings.dart';
import 'package:scanner/widgets/barcode_input.dart';
import 'package:scanner/widgets/product_image.dart';
import 'package:sliver_tools/sliver_tools.dart';

filter(String search) => (PicklistLine line) =>
    search == '' || line.product.ean == search || line.product.uid == search;

const blue = Color(0xFF034784);
const white = Colors.white;
final black = Colors.grey[900];

class PicklistBody extends StatefulWidget {
  const PicklistBody(this.lines, {Key? key}) : super(key: key);

  final List<PicklistLine> lines;

  @override
  _PicklistBodyState createState() => _PicklistBodyState();
}

class _PicklistBodyState extends State<PicklistBody> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      children: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              ListTile(
                title: BarcodeInput((value, barcode) {
                  setState(() {
                    final lines = widget.lines.where(filter(value));
                    if (lines.length == 1) {
                      Navigator.of(context)
                          .pushNamed('/product', arguments: lines.first);
                    } else {
                      _search = value;
                    }
                  });
                }),
              ),
              Divider(),
            ],
          ),
        ),
        Consumer<ValueNotifier<Settings>>(builder: (_, value, __) {
          final lines = widget.lines;
          final settings = value.value;
          if (settings.finishedProductsAtBottom) {
            lines.sort((a, b) => a.status - b.status);
          }
          return SliverList(
              delegate: SliverChildListDelegate(
                  lines.where(filter(_search)).map((line) {
            var fullyPicked = line.isFullyPicked();
            return Column(
              children: [
                ListTile(
                  tileColor: fullyPicked ? blue : null,
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed('/product', arguments: line);
                  },
                  leading: ProductImage(line.product.id, width: 60),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line.product.uid,
                        style: TextStyle(
                          fontSize: 13,
                          color: fullyPicked ? white : black,
                        ),
                      ),
                      if (line.product.description != null)
                        Text(
                          line.product.description!,
                          style: TextStyle(
                            fontSize: 16,
                            color: fullyPicked ? white : black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(
                        '${line.pickAmount} (${line.product.unit})',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: fullyPicked ? white : black,
                        ),
                      ),
                    ],
                  ),
                  subtitle: line.location != null
                      ? Text(
                          line.location!,
                          style: TextStyle(
                            fontSize: 13,
                            color: fullyPicked ? white : Colors.grey[400],
                          ),
                        )
                      : null,
                  trailing: Icon(
                    Icons.chevron_right,
                    color: fullyPicked ? white : black,
                  ),
                ),
                Divider(
                  height: 1,
                  color: fullyPicked ? blue : null,
                ),
              ],
            );
          }).toList()));
        }),
      ],
    );
  }
}