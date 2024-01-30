import "package:flutter/material.dart";
import "package:sensorify/backend/file_manager.dart";

class TrainingPage extends StatefulWidget {
  const TrainingPage({Key? key}) : super(key: key);

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  final FileManager _fileManager = FileManager();
  Set<String> _selectedFiles = Set<String>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Sensorify"),
      ),
      body: FutureBuilder<List<String>>(
        future: _fileManager.getDirectoryFileNames(),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("An error occurred!"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No files found."));
          } else {
            List<String>? files = snapshot.data;
            return ListView.builder(
              itemCount: files!.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(files[index]),
                  value: _selectedFiles.contains(files[index]),
                  onChanged: (bool? value) {
                    if (value != null) {
                      setState(() {
                        if (value) {
                          _selectedFiles.add(files[index]);
                        } else {
                          _selectedFiles.remove(files[index]);
                        }
                      });
                    }
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          print("Selected files: $_selectedFiles");
        },
        label: Text("Print Selected"),
        backgroundColor: Colors.blue,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
      ),
    );
  }
}
