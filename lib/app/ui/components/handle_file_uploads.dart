import 'dart:convert';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:tiempos_app/models/activity_model.dart';
import 'package:tiempos_app/models/operation_model.dart';
import 'package:tiempos_app/models/people_model.dart';
import 'package:tiempos_app/services/activity_service.dart';
import 'package:tiempos_app/services/operations_service.dart';
import 'package:tiempos_app/services/people_service.dart';
import 'package:tiempos_app/services/resources_service.dart';

Future<void> startFilePicker(String modelToUpload) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );

  if (result != null) {
    try {
      PlatformFile file = result.files.first;
      List<int> fileData = file.bytes!.toList();
      if (modelToUpload == 'activity') {
        handleFileUploadActivity(fileData);
      } else if (modelToUpload == 'people') {}
    } catch (e) {
      print('$e');
    }
  }
}

void handleFileUploadActivity(List<int> fileData) async {
  OperationService operationService = OperationService();
  ActivityService activityService = ActivityService();
  PeopleService peopleService = PeopleService();

  List<List<dynamic>>? csvData;
  // Decode the file data to a String
  String csvString = utf8.decode(fileData);
  var now = DateTime.now();
  var random = Random();
  String newActivityID = '${now.microsecondsSinceEpoch}${random.nextInt(1000)}';

  // Parse the CSV data using the csv package
  csvData = const CsvToListConverter().convert(csvString);

  List<List<dynamic>>? csvDataContent =
      csvData.getRange(1, csvData.length).toList();

  num defaultMinuteRateActivity = 0;
  for (var dmr in csvDataContent) {
    defaultMinuteRateActivity += dmr[3] is! num ? double.parse(dmr[3]) : dmr[3];
  }

  ActivityModel newActivityFromCsv = ActivityModel(
    activity_id: newActivityID.toString(),
    activity_name: 'new_activity ${newActivityID.toString()}'.toString(),
    default_minute_rate: defaultMinuteRateActivity.toInt(),
    notes: "",
  );

  if (defaultMinuteRateActivity != 0) {
    activityService.postActivity(newActivityFromCsv);
    for (List<dynamic> e in csvDataContent) {
      OperationModel newOperationFromCsv =
          OperationModel.readRecordFromCsv(e, newActivityID);
      print(newOperationFromCsv.toMap());
      operationService.postOperation(newOperationFromCsv);
      // // add resource if not exists
      // List existingResources =
      //     await ResourceModel.getCurrentResourcesStringList();
      // if (!existingResources.contains(newOperationFromCsv.machine_id)) {
      //   ResourceModel newResource = ResourceModel(
      //     resource_id: newOperationFromCsv.machine_id,
      //     resource_name: 'resource_to_${newOperationFromCsv.operation_name}',
      //     operations: [newOperationFromCsv.operation_id],
      //   );
      //   resourceService.postResource(newResource);
      // } else {
      //   ResourceModel resourceToEdit = await ResourceModel.getSingleResource(
      //       newOperationFromCsv.machine_id);
      //   // add new operation to resource
      //   if (!resourceToEdit.operations
      //       .contains(newOperationFromCsv.operation_id)) {
      //     resourceService.patchResource(
      //         resourceToEdit.documentId!, resourceToEdit.toMap());
      //   }
      // }
    }
  }
}
