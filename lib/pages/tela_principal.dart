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
  List _toDoList = [];

  Map<String, dynamic> tarefaRemovida = Map();
  int? posTarefaRemovida;

  final _addController = TextEditingController();

  void _addToDo() {
    setState(() {
      Map<String, dynamic> newTodo = Map();
      newTodo["title"] = _addController.text;
      _addController.text = '';
      newTodo["ok"] = false;
      _toDoList.add(newTodo);
      _saveData();
      _refresh();
    });
  }

  @override
  void initState() {
    super.initState();

    _readData().then((value) {
      setState(() {
        _toDoList = json.decode(value!);
      });
    });
  }

  Future _refresh () async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _toDoList.sort((a, b) {
        if (a["ok"] && !b["ok"]){ return 1;}
        else if (!a["ok"] && b["ok"]){ return -1;}
        else {return 0;}
      });
    });
    _saveData();
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
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  itemCount: _toDoList.length,
                  itemBuilder: itemBuilder,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemBuilder(context, index) {
    return Dismissible(
      key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: const Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["ok"],
        onChanged: (e) {
          setState(() {
            _toDoList[index]["ok"] = e;
            _saveData();
          });
        },
        secondary: CircleAvatar(
          child: Icon(_toDoList[index]["ok"] ? Icons.check : Icons.error),
        ),
      ),
      onDismissed: (direction) {
        tarefaRemovida = _toDoList[index];
        posTarefaRemovida = index;

        setState(() {
          _toDoList.removeAt(index);
          _saveData();

          final snack = SnackBar(
            content: Text("Tarefa \"${tarefaRemovida["title"]}\" Removida!"),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: () {
                setState(() {
                  _toDoList.insert(posTarefaRemovida!, tarefaRemovida);
                  _saveData();
                });
              },
            ),
            duration: const Duration(seconds: 4),
          );
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(snack);

        });
      },
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
