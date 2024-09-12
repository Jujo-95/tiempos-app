import 'package:flutter/material.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/central_dialog_form.dart';
import 'package:tiempos_app/app/ui/components/forms/dashboard_form.dart';

import 'package:tiempos_app/app/ui/components/handle_file_uploads.dart';

import 'package:tiempos_app/app/ui/components/forms/stopwatch_component.dart';
import 'package:tiempos_app/app/ui/views/tables/manage_time_records_table.dart';

class ManageTimeRecordsTab extends StatefulWidget {
  const ManageTimeRecordsTab({Key? key}) : super(key: key);

  @override
  ManageTimeRecordsTabState createState() => ManageTimeRecordsTabState();
}

class ManageTimeRecordsTabState extends State<ManageTimeRecordsTab> {
  @override
  Widget build(BuildContext context) {
    Size windowSize = MediaQuery.of(context).size;

    setState(() {
      windowSize = MediaQuery.of(context).size;
    });

    Widget headerWebUI = Container(
      color: Colors.white,
      child: const Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Text(
                  'Registros',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Row(
                  children: [
                    Expanded(child: DropdownMenuImportCsv()),
                  ],
                ),
              ),
            ),
          ]),
    );

    Widget headerMobileUI = const Column(children: [
      SizedBox(
        height: 100,
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Text(
            'Registros',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
        ),
      ),
    ]);

    return Column(
      children: [
        windowSize.width <= 800 ? headerMobileUI : headerWebUI,
        Expanded(child: ManageTimeRecordsTable()),
        Container()
      ],
    );
  }
}

class DropdownMenuImportCsv extends StatefulWidget {
  const DropdownMenuImportCsv({super.key});

  @override
  State<DropdownMenuImportCsv> createState() => _DropdownMenuImportCsvState();
}

class _DropdownMenuImportCsvState extends State<DropdownMenuImportCsv> {
  final layerLink = LayerLink();
  final focusNode = FocusNode();
  OverlayEntry? entry;
  List<List<dynamic>>? csvData;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => showOverlay,
    );
  }

  void _openStopwatchComponent(BuildContext context) {
    CentralDialogForm.openEditForm(context, const StopwatchComponents());
  }

  void showOverlay() {
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
        width: size.width,
        child: CompositedTransformFollower(
          showWhenUnlinked: false,
          link: layerLink,
          offset: Offset(0, size.height + 8),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
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
                children: [
                  ListTile(
                    onTap: () {
                      startFilePicker('activity'); //_startFilePicker();
                    },
                    title: const Text(
                      'Importar referencia desde csv',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(
                      Icons.upload_file,
                      size: 15,
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      startFilePicker('activity');
                    },
                    title: const Text(
                      'Descargar plantilla de importación',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(
                      Icons.download,
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

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
        link: layerLink,
        child: Container(
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(8),
                ),
                border: Border.all(color: Colors.grey.shade300)),
            constraints: const BoxConstraints(
              minHeight: 40.0,
              minWidth: 80.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    label: const Text('Nuevo registro'),
                    onPressed: () {
                      _openStopwatchComponent(context);
                    },
                    icon: const Icon(
                      Icons.add,
                      color: Color(0xFF2952E1),
                    ),
                  ),
                ),
                Container(
                  color: Colors.grey.shade300,
                  width: 1,
                  height: 25,
                ),
                IconButton(
                  onPressed: showOverlay,
                  splashRadius: 0.1,
                  icon: const Icon(
                    Icons.more_vert,
                    color: Color(0xFF2952E1),
                  ),
                )
              ],
            )));
  }
}
