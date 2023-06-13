import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../pick_list_overview/view/pick_list_overview.dart';
import '../../model/pick_list_model.dart';
import '../../provider/pick_list_provider.dart';

class OpenTabWidget extends StatelessWidget {
  const OpenTabWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PickListNew>>(
      future: context.read<PickListProviderV2>().getOpenData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data?.isEmpty ?? true
              ? Center(
                  child: Text('Data not found'),
                )
              : ListView.separated(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final reversedIndex = snapshot.data!.length - 1 - index;
                    final list = snapshot.data![reversedIndex];
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PickListOverViewV2(
                              data: list,
                            ),
                          ),
                        );
                      },
                      leading: Container(
                        width: 40,
                        height: 40,
                        color: statusColor(list.status ?? 0),
                        alignment: Alignment.center,
                        child: Text(
                          '${list.lines}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                list.uid ?? 'Uid not found',
                                style: TextStyle(fontSize: 12),
                              ),
                              if (list.uid?.isNotEmpty ?? false)
                                SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  (list.debtor?.city?.isEmpty ?? true)
                                      ? AppLocalizations.of(context)!
                                          .unavailable
                                      : list.debtor!.city.toString(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Text(list.debtor?.name ?? 'Name not found'),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                  ),
                );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('${snapshot.error}'),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          if (snapshot.data == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Center(
              child: Text('Error'),
            );
          }
        } else {
          return Center(
            child: Text('Error'),
          );
        }
      },
    );
  }

  Color statusColor(int number) {
    switch (number) {
      case 2:
        return Color(0xFF034784);
      case 1:
        return Colors.black;
      case 8:
        return Color(0Xff777777);
      case 7:
        return Color(0xFFed6f56);
      default:
        return Colors.black;
    }
  }
}
