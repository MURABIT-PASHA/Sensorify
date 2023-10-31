import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensorify/models/record_model.dart';

class FileManager {
  Future<String> get _storagePath async {
    return await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> _localFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  Future<File> writeData(String row, String fileName) async {
    final file = await _localFile(fileName);
    return file.writeAsString(row, mode: FileMode.append);
  }

  Future<String> readData(fileName) async {
    try {
      final file = await _localFile(fileName);
      final contents = await file.readAsString();
      return contents;
    } catch (e) {
      return "";
    }
  }

  Future<bool> saveRecord(RecordModel record) async {
    final String csvFile = "${record.initialName}.csv";
    String readerData = await readData(csvFile);
    if (readerData != "") {
      final values =
          '${record.sensorName},${record.axisX},${record.axisY},${record.axisZ},${record.timestamp}\n';
      await writeData(values, csvFile);
    } else {
      const headers = 'sensorName,axisX,axisY,axisZ,timestamp\n';
      final values =
          '${record.sensorName},${record.axisX},${record.axisY},${record.axisZ},${record.timestamp}\n';
      await writeData(headers + values, csvFile);
    }
    return true;
  }
}