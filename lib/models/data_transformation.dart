import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiempos_app/models/time_record_model.dart';

class FirebaseGroupBy<T> {
  CollectionReference<T> collectionRef;

  FirebaseGroupBy(this.collectionRef);

  Future<List<Map<String, dynamic>>> groupByAndAggregate(
      List<String> keyFields, String aggregateField, String aggregateFunction,
      {String? startDate, String? endDate, String? dateFieldName}) async {
    QuerySnapshot snapshot = await collectionRef.get();

    final groupedData = <String, List<double>>{};
    final aggregateMap = <String, double>{};
    List<Map<String, dynamic>> agreggateMapResult = [];

    if (startDate != null && endDate != null && dateFieldName != null) {
      // if the function have startDate, endDate and dateFieldName filter by date:
      final startDateInms = DateTime.parse(startDate).millisecondsSinceEpoch;
      final endDateInms = DateTime.parse(endDate).millisecondsSinceEpoch;

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final keyValues =
            keyFields.map((field) => data[field].toString()).toList();
        final key = keyValues.join('-');
        final value = data[aggregateField] as double;

        if (groupedData.containsKey(key)) {
          if (data.containsKey(dateFieldName)) {
            final recordValueInms =
                DateTime.parse(data[dateFieldName]).millisecondsSinceEpoch;

            if (recordValueInms <= endDateInms &&
                recordValueInms >= startDateInms) {
              groupedData[key]!.add(value);
            } else {
              null;
            }
          } else {
            groupedData[key]!.add(value);
          }
        } else {
          // if the function does not have startDate, endDate and dateFieldName filter by date:
          if (data.containsKey(dateFieldName)) {
            final recordValueInms =
                DateTime.parse(data[dateFieldName]).millisecondsSinceEpoch;

            if (recordValueInms <= endDateInms &&
                recordValueInms >= startDateInms) {
              groupedData[key] = [value];
            } else {
              null;
            }
          } else {
            groupedData[key] = [value];
          }
        }
      }
    } else {
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final keyValues =
            keyFields.map((field) => data[field].toString()).toList();
        final key = keyValues.join('-');
        final value = data[aggregateField] as double;

        if (groupedData.containsKey(key)) {
          groupedData[key]!.add(value);
        } else {
          groupedData[key] = [value];
        }
      }
    }

    for (final entry in groupedData.entries) {
      final key = entry.key;
      final values = entry.value;

      double aggregateValue;
      switch (aggregateFunction) {
        case 'average':
          aggregateValue = _calculateAverage(values);
          break;
        case 'sum':
          aggregateValue = _calculateSum(values);
          break;
        case 'count':
          aggregateValue = values.length.toDouble();
          break;
        default:
          throw ArgumentError('Invalid aggregate function: $aggregateFunction');
      }

      aggregateMap[key] = aggregateValue;
    }

    aggregateMap.forEach((key, value) {
      final values = key.split('-');
      Map<String, dynamic> result = {};
      for (int i = 0; i < keyFields.length; i++) {
        result[keyFields[i]] = values[i];
      }

      result['${aggregateField}_$aggregateFunction'] = value;

      agreggateMapResult.add(result);
    });

    return agreggateMapResult;
  }

  double _calculateAverage(List<double> values) {
    final sum = values.reduce((a, b) => a + b);
    return sum / values.length.toDouble();
  }

  double _calculateSum(List<double> values) {
    return values.reduce((a, b) => a + b);
  }
}

Map<T, List<S>> groupBy<S, T>(Iterable<S> values, T Function(S) key) {
  var map = <T, List<S>>{};
  for (var element in values) {
    (map[key(element)] ??= []).add(element);
  }
  return map;
}

Map<T, double> averageBy<S, T>(
    Iterable<S> values, T Function(S) key, num Function(S) value) {
  var grouped = groupBy(values, key);
  var result = <T, double>{};

  grouped.forEach((k, v) {
    var sum = v.map(value).reduce((a, b) => a + b);
    result[k] = sum / v.length;
  });

  return result;
}

Map<T, num> sumBy<S, T>(
    Iterable<S> values, T Function(S) key, num Function(S) value) {
  var grouped = groupBy(values, key);
  var result = <T, num>{};

  grouped.forEach((k, v) {
    result[k] = v.map(value).reduce((a, b) => a + b);
  });

  return result;
}

List<T> distinctBy<S, T>(Iterable<S> values, T Function(S) keyExtractor) {
  var seen = <T>{};
  var distinctValues = <T>[];

  for (var element in values) {
    var key = keyExtractor(element);
    if (seen.add(key)) {
      distinctValues.add(key);
    }
  }

  return distinctValues;
}

List<Map<String, dynamic>> groupDataArrayAgg<T>(
    List<Map<String, dynamic>> dataList,
    {CollectionReference? collection}) {
  Map<String, List<Map<String, dynamic>>> groupedData = {};

  for (var data in dataList) {
    var idNumber = data['id_number'];
    var workerName = data['worker_name'];
    num? samReference;

    var groupKey = '$idNumber|$workerName';

    if (groupedData.containsKey(groupKey)) {
      groupedData[groupKey]!.add({
        'operation_name': data['operation_name'],
        'sam_average': data['sam_average'],
        'activity_name': data['activity_name'],
        'activity_id': data['activity_id'],
        'operation_id': data['operation_id'],
        'sam_reference': samReference
      });
    } else {
      groupedData[groupKey] = [
        {
          'operation_name': data['operation_name'],
          'sam_average': data['sam_average'],
          'activity_name': data['activity_name'],
          'activity_id': data['activity_id'],
          'operation_id': data['operation_id'],
          'sam_reference': samReference
        }
      ];
    }
  }

  return groupedData.entries.map((entry) {
    var keys = entry.key.split('|');
    return {
      'id_number': int.parse(keys[0]),
      'worker_name': keys[1],
      'group': entry.value,
    };
  }).toList();
}

Future<num?> matchDataWithSamReference(
    CollectionReference collection, String activity, String operation) async {
  try {
    // Access the collection and document you want to retrieve the value from
    QuerySnapshot querySnapshot = await collection
        .where('activity_id', isEqualTo: activity)
        .where('operation_id', isEqualTo: operation)
        .get();

    // Check if any documents were returned
    if (querySnapshot.docs.isNotEmpty) {
      // Extract the value from the first document
      Map<String, dynamic> data =
          querySnapshot.docs[0].data() as Map<String, dynamic>;

      num? value = await data['operation_sam'];

      // Print the value if it exists
      if (value != null) {
        return value;
      } else {}
    } else {}
  } catch (e) {
    // Handle any errors that may occur
  }
  return null;
}
