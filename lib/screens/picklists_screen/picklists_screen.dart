import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scanner/dio.dart';
import 'package:scanner/main.dart';
import 'package:scanner/models/picklist.dart';
import 'package:scanner/providers/settings_provider.dart';
import 'package:scanner/resources/picklist_line_repository.dart';
import 'package:scanner/resources/picklist_repository.dart';
import 'package:scanner/screens/picklist_screen/picklist_screen.dart';
import 'package:scanner/screens/picklists_screen/widgets/picklist_view.dart';
import 'package:scanner/screens/picklists_screen/widgets/search_field.dart';
import 'package:scanner/widgets/wms_app_bar.dart';

class PicklistsScreen extends StatefulWidget {
  static const routeName = '/picklists';

  const PicklistsScreen({Key? key}) : super(key: key);

  @override
  _PicklistScreenState createState() => _PicklistScreenState();
}

class _PicklistScreenState extends State<PicklistsScreen> with RouteAware {
  final _refreshController = RefreshController(initialRefresh: false);
  final _refreshControllerPicked = RefreshController(initialRefresh: false);
  String _search = '';
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  late PicklistLineRepository lineRepository;
  var isShowKeyboard = true;

  _moveToPickList(Picklist picklist) {
    Future.microtask(() {
      setState(() {
        textEditingController.clear();
        _search = '';
      });
      if (!mounted) return;
      Navigator.pushNamed(context, PicklistScreen.routeName,
          arguments: picklist);
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      lineRepository = context.read<PicklistLineRepository>();
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe routeAware
    navigationObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() async {
    setState(() {
      this.focusNode.requestFocus();
    });
    super.didPopNext();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    focusNode.dispose();
    _refreshController.dispose();
    _refreshControllerPicked.dispose();
    // Unsubscribe routeAware
    navigationObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<PicklistRepository>();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: WMSAppBar(
          context.watch<SettingProvider>().userInfo?.firstName ?? '    ',
          preferredSize: kToolbarHeight + 100,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(100),
            child: Column(
              children: [
                TabBar(
                  onTap: (int index) {
                    setState(() {
                      this.isShowKeyboard = (index == 0);
                    });
                  },
                  tabs: [
                    Tab(
                      text: AppLocalizations.of(context)!
                          .picklistsOpen
                          .toUpperCase(),
                    ),
                    Tab(
                      text: AppLocalizations.of(context)!
                          .picklistsRevise
                          .toUpperCase(),
                    ),
                  ],
                ),
                SearchField(_search, (value) {
                  setState(() {
                    _search = value;
                    if (value == '' || value.isEmpty) {
                      this.focusNode.requestFocus();
                    }
                  });
                }, this.textEditingController, this.focusNode, false),
              ],
            ),
          ),
        ),
        body: StreamBuilder<List<Picklist>>(
          stream: repository.getPicklistsStream(_search),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              if (snapshot.error is NoConnection) {
                return errorWidget(
                    mgs: AppLocalizations.of(context)!.internet_disconnected);
              } else if (snapshot.error is Failure) {
                return errorWidget(mgs: (snapshot.error as Failure).message);
              } else {
                return Container(
                  child: Text('Something is wrong.'),
                );
              }
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              final notPicked = snapshot.data!
                  .where((element) => element.isNotPicked())
                  .toList();
              final picked = snapshot.data!
                  .where((element) => element.isPicked())
                  .toList();
              if (notPicked.length == 1 && (_search != '') &&
                  (notPicked.first.uid.contains(_search) ||
                      notPicked.first.debtor.name.contains(_search))) {
                _moveToPickList(notPicked.first);
              }
              return TabBarView(
                children: [
                  PicklistView(
                    notPicked,
                    _refreshController,
                    () async {
                      await Future.wait([
                        repository.clear(),
                        lineRepository.clear(),
                      ]);
                      _refreshController.refreshCompleted();
                      setState(() {});
                    },
                    onTap: (Picklist picklist) {
                      _moveToPickList(picklist);
                    },
                  ),
                  PicklistView(
                    picked,
                    _refreshControllerPicked,
                    () async {
                      await Future.wait([
                        repository.clear(),
                        lineRepository.clear(),
                      ]);
                      _refreshControllerPicked.refreshCompleted();
                      setState(() {});
                    },
                    onTap: (Picklist picklist) {
                      _moveToPickList(picklist);
                    },
                  ),
                ],
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget errorWidget({required String mgs}) {
    return Container(
      margin: EdgeInsets.all(16),
      child: Text(mgs),
    );
  }
}
