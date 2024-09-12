import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/central_dialog_form.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/controller_search.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/report_list_tile.dart';
import 'package:tiempos_app/app/ui/components/forms/user_form.dart';
import 'package:tiempos_app/app/ui/views/tabs/manage_accounts_tab.dart';

import 'package:tiempos_app/app/ui/views/tabs/manage_dashboard_tab.dart';
import 'package:tiempos_app/app/ui/views/tabs/manage_invoices_tab.dart';
import 'package:tiempos_app/app/ui/views/tabs/manage_time_records_tab.dart';
import 'package:tiempos_app/services/firebase_paths.dart';

import 'package:tiempos_app/models/user_model.dart';
import 'package:tiempos_app/services/account_service.dart';
import 'package:tiempos_app/services/activity_service.dart';
import 'package:tiempos_app/services/dashboard_service.dart';
import 'package:tiempos_app/services/invoice_service.dart';
import 'package:tiempos_app/services/operations_service.dart';
import 'package:tiempos_app/services/people_service.dart';
import 'package:tiempos_app/services/user_service.dart';

import '../../views/tabs/manage_activities_tab.dart';
import '../../views/tabs/manage_balance_tab.dart';
import '../../views/tabs/manage_people_tab.dart';
import '../../views/tabs/manage_resources_tab.dart';

class StartPage extends StatefulWidget {
  StartPage({super.key});
  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final newWorkerNameController = TextEditingController();
  final newOperationController = TextEditingController();
  final newReferenceController = TextEditingController();
  var stopwatch = Stopwatch();
  final FirebaseAuth firebaseInstance = FirebaseAuth.instance;
  final UserService userService = UserService();
  int selectedItemNavRail = 0;
  void Function(int)? onDestinationSelected;
  late GenericSearchController genericSearchController =
      GenericSearchController(onTextChanged: _onTextChanged, searchText: '');
  String? userName;
  UserModel? currentUserModel;
  late Future<UserModel?> userInstanceFuture;
  final PeopleService peopleService = PeopleService();
  final DashboardService dashboardService = DashboardService();
  late Stream peopleStream;
  late Stream<QuerySnapshot<Object?>> activitiesStream;
  late Stream<QuerySnapshot<Object?>> operationsStream;
  late Stream<QuerySnapshot<Object?>> dashboardStream;
  late Stream<QuerySnapshot<Object?>> accountsStream;
  late Stream<QuerySnapshot<Object?>> invoicesStream;

  @override
  void initState() {
    super.initState();
    userInstanceFuture = UserService()
        .getUserByEmail(FirebaseAuth.instance.currentUser!.email.toString());
    peopleStream = PeopleService().peopleStream;
    operationsStream = OperationService().operationStream;
    activitiesStream = ActivityService().activityStream;
    dashboardStream = DashboardService().dashboardStream;
    accountsStream = AccountService.accountCollection.snapshots();
    invoicesStream = InvoiceService.invoiceCollection.snapshots();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  void _onTextChanged(String text) {
    setState(() {
      genericSearchController.searchText = text;
    });
  }

  Widget getWidgetBasedOnCondition(int condition) {
    switch (condition) {
      case 0:
        return Flexible(
            child: ManageDashboardTab(
          dashboardStream: dashboardStream,
        ));
      case 1:
        return Flexible(child: ManageTimeRecordsTab());
      case 2:
        return Flexible(
            child: ManageActivitiesTab(
                activitiesStream: activitiesStream,
                operationsStream: operationsStream));
      case 3:
        return Flexible(child: ManagePeopleTab(stream: peopleStream));
      case 4:
        return const Flexible(child: ManageResourcesTab());
      case 5:
        return Flexible(
            child: ManageAccountsTab(
          accountsStream: accountsStream,
        ));
      case 6:
        return Flexible(
            child: ManageInvoicesTab(
          invoicesStream: invoicesStream,
        ));
      default:
        return Flexible(child: ManagePeopleTab(stream: peopleStream));
    }
  }

  @override
  Widget build(BuildContext context) {
    Size windowSize = MediaQuery.of(context).size;

    setState(() {
      windowSize = MediaQuery.of(context).size;
    });

    return Scaffold(
        backgroundColor: Colors.white70,
        body: windowSize.width <= 800
            ? mobileNavigationBarBuilder()
            : wildScreenNavigationBarBuilder(windowSize));
  }

  SizedBox wildScreenNavigationBarBuilder(Size windowSize) {
    return SizedBox(
      height: windowSize.height,
      width: windowSize.width,
      child: Row(children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: NavigationRail(
                selectedIndex: selectedItemNavRail,
                onDestinationSelected: (int index) {
                  setState(() {
                    selectedItemNavRail = index;
                  });
                },
                destinations: const [
                  NavigationRailDestination(
                      icon: Icon(Icons.table_chart_outlined),
                      label: Text('Perfil')),
                  NavigationRailDestination(
                      icon: Icon(Icons.timer_outlined),
                      label: Text('Proveedores')),
                  NavigationRailDestination(
                      icon: Icon(Icons.checkroom_outlined),
                      label: Text('Tablas')),
                  NavigationRailDestination(
                      icon: Icon(Icons.person_outline_outlined),
                      label: Text('Stopwatch')),
                  NavigationRailDestination(
                      icon: Icon(Icons.agriculture_outlined),
                      label: Text('Resources')),
                  NavigationRailDestination(
                      icon: Icon(Icons.account_balance_outlined),
                      label: Text('Proveedores')),
                  NavigationRailDestination(
                      icon: Icon(Icons.fact_check_outlined),
                      label: Text('Proveedores')),
                ],
              ),
            ),
            DropdownMenuImportCsvActivities(
                userInstanceFuture: userInstanceFuture)
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        getWidgetBasedOnCondition(selectedItemNavRail),
      ]),
    );
  }

  Material mobileNavigationBarBuilder() {
    return Material(
      child: Column(
        children: [
          getWidgetBasedOnCondition(selectedItemNavRail),
          Container(
              height: 60,
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(color: Colors.grey.shade300, width: 1))),
              child: bottomNavigationChildBuilder()),
        ],
      ),
    );
  }

  BottomNavigationBar bottomNavigationChildBuilder() {
    return BottomNavigationBar(
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey.shade500,
      currentIndex: selectedItemNavRail,
      onTap: (int index) {
        setState(() {
          selectedItemNavRail = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.table_chart_rounded), label: 'Perfil'),
        BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Proveedores'),
        BottomNavigationBarItem(
            icon: Icon(Icons.account_balance), label: 'Proveedores'),
        BottomNavigationBarItem(
            icon: Icon(Icons.engineering_outlined), label: 'Tablas'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded), label: 'Stopwatch'),
        BottomNavigationBarItem(icon: Icon(Icons.trolley), label: 'Resources'),
      ],
    );
  }
}

class DropdownMenuImportCsvActivities extends StatefulWidget {
  final Future<UserModel?> userInstanceFuture;
  DropdownMenuImportCsvActivities(
      {super.key, required this.userInstanceFuture});

  @override
  State<DropdownMenuImportCsvActivities> createState() =>
      _DropdownMenuImportCsvActivitiesState();
}

class _DropdownMenuImportCsvActivitiesState
    extends State<DropdownMenuImportCsvActivities> {
  final layerLink = LayerLink();
  final focusNode = FocusNode();
  OverlayEntry? entry;
  List<List<dynamic>>? csvData;
  UserService userService = UserService();
  UserForm userForm = const UserForm();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => showImportActivityOptions,
    );
  }

  void _openActivityForm() {
    hideOverlay();
    return CentralDialogForm.openEditForm(context, userForm);
  }

  void singUserOut() async {
    await FirebaseAuth.instance.signOut();
    FirebasePaths.instance.currentUserId = '';
    hideOverlay();
  }

  void showImportActivityOptions() {
    final overlay = Overlay.of(context);

    entry = OverlayEntry(builder: (context) => buildOverlay());

    overlay.insert(entry!);
  }

  void hideOverlay() {
    entry?.remove();
    entry = null;
  }

  Widget buildOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    Widget dropDownMenu = Positioned(
        width: 200,
        child: CompositedTransformFollower(
          showWhenUnlinked: false,
          link: layerLink,
          offset: Offset(size.width, -100 + size.height - 30),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(3, 3),
                ),
              ],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              borderRadius: BorderRadius.circular(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      'Cuenta',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  ListTile(
                    onTap: () => _openActivityForm(),
                    title: const Text(
                      'Editar perfil',
                      style: TextStyle(fontSize: 12),
                    ),
                    leading: const Icon(
                      Icons.settings,
                      size: 15,
                    ),
                  ),
                  ListTile(
                    onTap: () => singUserOut(),
                    title: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(fontSize: 12),
                    ),
                    leading: const Icon(
                      Icons.logout_rounded,
                      size: 15,
                    ),
                  )
                ],
              ),
            ),
          ),
        ));

    return Stack(
      children: <Widget>[
        Positioned.fill(
            child: GestureDetector(
          onTap: hideOverlay,
          child: Container(
            color: Colors.transparent,
          ),
        )),
        dropDownMenu,
      ],
    );
  }

  childAvatarBuilder() => FutureBuilder(
      future: widget.userInstanceFuture,
      builder: (context, userSnapshot) {
        if (userSnapshot.hasData) {
          UserModel userModel = userSnapshot.data!;
          userForm = UserForm(
            edit: true,
            userToEdit: userModel,
          );
          return ClipOval(
            child: Material(
              color: Colors.transparent, // Button color
              child: InkWell(
                splashColor: Colors.grey, // Splash color
                onTap: showImportActivityOptions,
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child:
                      initialsAvatarBuilder(userModel.first_name, null, null),
                ),
              ),
            ),
          );
        } else {
          return const ClipOval(
            child: Material(
              color: Colors.transparent, // Button color
              child: InkWell(
                splashColor: Colors.grey, // Splash color
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
          );
        }
      });

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
        link: layerLink, child: childAvatarBuilder());
  }
}
