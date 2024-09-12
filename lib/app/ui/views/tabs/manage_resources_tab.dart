import 'package:flutter/material.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/central_dialog_form.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/controller_search.dart';
import 'package:tiempos_app/app/ui/components/forms/resources_form.dart';
import 'package:tiempos_app/app/ui/views/tables/manage_resources_table.dart';

import 'package:tiempos_app/app/ui/components/handle_file_uploads.dart';

class ManageResourcesTab extends StatefulWidget {
  const ManageResourcesTab({Key? key}) : super(key: key);

  @override
  ManageResourcesTabState createState() => ManageResourcesTabState();
}

class ManageResourcesTabState extends State<ManageResourcesTab> {
  String headerPageName = 'Recursos';
  TextStyle headerTextStyle =
      const TextStyle(fontWeight: FontWeight.bold, fontSize: 30);

  late GenericSearchController genericSearchController =
      GenericSearchController(onTextChanged: _onTextChanged, searchText: '');

  void _onTextChanged(String text) {
    setState(() {
      genericSearchController.searchText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size windowSize = MediaQuery.of(context).size;

    setState(() {
      windowSize = MediaQuery.of(context).size;
    });

    Widget headerWebUI = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Text(
              headerPageName,
              style: headerTextStyle,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.all(28),
            child: genericSearchController,
          ),
        ),
        const Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.all(28),
            child: DropdownMenuImportCsvResources(),
          ),
        ),
      ],
    );

    Widget headerMobileUI = Column(children: [
      SizedBox(
        height: 100,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Text(
            headerPageName,
            style: headerTextStyle,
          ),
        ),
      ),
      const SizedBox(
        height: 50,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28),
          child: DropdownMenuImportCsvResources(),
        ),
      ),
    ]);

    return Column(
      children: [
        windowSize.width <= 800 ? headerMobileUI : headerWebUI,
        const SizedBox(
          height: 12,
        ),
        Expanded(
            child: ManageResourceTable(
          searchText: genericSearchController.searchText,
        )),
        Container(),
      ],
    );
  }
}

class DropdownMenuImportCsvResources extends StatefulWidget {
  const DropdownMenuImportCsvResources({super.key});

  @override
  State<DropdownMenuImportCsvResources> createState() =>
      _DropdownMenuImportCsvResourcesState();
}

class _DropdownMenuImportCsvResourcesState
    extends State<DropdownMenuImportCsvResources> {
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
                      'Importar recurso desde csv',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(
                      Icons.upload_file,
                      size: 15,
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      //startFilePicker('activity');
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
                    label: const Text('Nuevo recurso'),
                    onPressed: () {
                      CentralDialogForm.openEditForm(context, ResourceForm());
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
