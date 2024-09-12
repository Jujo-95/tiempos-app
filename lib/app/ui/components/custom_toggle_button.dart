import 'package:flutter/material.dart';
import 'package:tiempos_app/app/ui/components/custom_widgets/central_dialog_form.dart';
import 'package:tiempos_app/app/ui/components/forms/operation_form.dart';
import 'package:tiempos_app/models/activity_model.dart';
import 'package:tiempos_app/models/operation_model.dart';

import 'dart:convert';
import 'package:csv/csv.dart';

import 'package:file_picker/file_picker.dart';
import 'package:tiempos_app/services/activity_service.dart';
import 'package:tiempos_app/services/operations_service.dart';

class DropdownMenuImportCsv extends StatefulWidget {
  final ActivityModel activity;

  const DropdownMenuImportCsv({super.key, required this.activity});

  @override
  State<DropdownMenuImportCsv> createState() => _DropdownMenuImportCsvState();
}

class _DropdownMenuImportCsvState extends State<DropdownMenuImportCsv> {
  final layerLink = LayerLink();
  final focusNode = FocusNode();
  OverlayEntry? entry;
  List<List<dynamic>>? csvData;
  OperationService operationService = OperationService();
  ActivityService activityService = ActivityService();

  @override
  void initState() {
    super.initState();
    if (true) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => showOverlay,
      );
    }
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

  _openOperationForm(
    BuildContext context,
    ActivityModel activityParent,
  ) {
    return CentralDialogForm.openEditForm(
        context,
        OperationForm(
          activityParent: activityParent,
          edit: false,
        ));
  }

  Future<void> _startFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      List<int> fileData = file.bytes!.toList();
      _handleFileUpload(fileData);
    }
  }

  void _handleFileUpload(List<int> fileData) async {
    // Decode the file data to a String
    String csvString = utf8.decode(fileData);

    // Parse the CSV data using the csv package
    csvData = const CsvToListConverter().convert(csvString);

    List<List<dynamic>>? csvDataContent =
        csvData!.getRange(1, csvData!.length).toList();

    for (var e in csvDataContent) {
      OperationModel newOperationFromCsv = OperationModel(
          activity_id: widget.activity.activity_id,
          position: e[0],
          operation_id: e[1].toString(),
          operation_name: e[2].toString(),
          operation_sam: e[3],
          notes: e[4]);
      operationService.postOperation(newOperationFromCsv);
    }
  }

  dropdownComponent() => Container(
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
                  _startFilePicker();
                  hideOverlay();
                },
                title: const Text(
                  'Importar operaciones desde csv',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: const Icon(
                  Icons.upload_file,
                  size: 15,
                ),
              ),
              ListTile(
                onTap: () {
                  _startFilePicker();
                  hideOverlay();
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
      );

  Widget buildOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    Widget dropDownMenu = Positioned(
      width: size.width * 2,
      child: CompositedTransformFollower(
        showWhenUnlinked: false,
        link: layerLink,
        offset: Offset(0, size.height + 8),
        child: dropdownComponent(),
      ),
    );

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

  itemsToggleButtonGenerator(List<Widget> listOfButtons) {
    List<Widget> listOfButtonsFormatted = [];
    Widget first = listOfButtons.first;
    listOfButtonsFormatted.add(first);

    Widget separator = Container(
      color: Colors.grey.shade300,
      width: 1,
      height: 25,
    );

    for (var element in listOfButtons) {
      listOfButtonsFormatted.add(separator);
      listOfButtonsFormatted.add(element);
    }
  }

  buttonsComponent() {
    return Container(
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
      child: Row(children: [
        Expanded(
          child: IconButton(
            onPressed: () {
              _openOperationForm(context, widget.activity);
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
        Expanded(
          child: IconButton(
            onPressed: showOverlay,
            splashRadius: 0.1,
            icon: const Icon(
              Icons.more_vert,
              color: Color(0xFF2952E1),
            ),
          ),
        )
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
        link: layerLink, child: buttonsComponent());
  }
}
