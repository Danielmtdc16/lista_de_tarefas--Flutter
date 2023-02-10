import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({Key? key}) : super(key: key);

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  final List _toDoList = [];

  final _addController = TextEditingController();

  void _addToDo() {
    setState(() {
      Map<String, dynamic> newTodo = Map();
      newTodo["title"] = _addController.text;
      _addController.text = '';
      newTodo["ok"] = false;
      _toDoList.add(newTodo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Tarefas"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addController,
                    decoration: const InputDecoration(
                      hintText: "Escreva",
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _addToDo,
                  child: const Text("Add"),
                )
              ],
            ),
            const SizedBox(height: 10,),
            Expanded(
              child: ListView.builder(
                itemCount: _toDoList.length,
                itemBuilder: (context, index){
                  return CheckboxListTile(
                    title: Text(_toDoList[index]["title"]),
                    value: _toDoList[index]["ok"],
                    onChanged: (e){
                      setState(() {
                        _toDoList[index]["ok"] = e;
                      });
                    },
                    secondary: CircleAvatar(
                      child: Icon(_toDoList[index]["ok"] ? Icons.check : Icons.error),
                    ),
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/data.json');
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String?> _readData() async {
    try {
      final file = await _getFile();

      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
