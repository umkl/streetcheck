import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streetcheck/model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool _isLoading = false;
  final TextEditingController _textFieldController = TextEditingController();
  List<CheckTask> _checkTasks = <CheckTask>[
    CheckTask('ask someone where Tally Weijl is', false),
    CheckTask(
        'tie your shoe laces before someone without saying something', false),
    CheckTask('scream while passing someone', false)
  ];

  _saveCheckItems(List<CheckTask> list) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        "checklistitems", _checkTasks.map((x) => json.encode(x)).toList());
    return true;
  }

  Future<void> _getSavedList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _checkTasks = prefs.getStringList("checklistitems")!.map((x) {
        return CheckTask.fromJson(jsonDecode(x));
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    setState(() {
      _isLoading = true;
    });

    _getSavedList().then((value) => setState(() {
          _isLoading = false;
        }));
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _getSavedList();
        break;
      case AppLifecycleState.paused:
        _saveCheckItems(_checkTasks);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              children: _checkTasks.map((CheckTask ct) {
                return CheckTaskItem(
                  checkTask: ct,
                  OnCheckStatusChanged: (bool checked) {
                    setState(() {
                      ct.checked = checked;
                    });
                    _saveCheckItems(_checkTasks);
                  },
                );
              }).toList(),
            ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 20,
            left: 30,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _checkTasks.clear();
                });
              },
              tooltip: 'Clear tasks',
              child: Icon(Icons.delete_forever),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 0,
            child: FloatingActionButton(
              onPressed: () => _displayDialog(),
              tooltip: 'Add Item',
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  void _addCheckTaskItem(String name) {
    setState(() {
      _checkTasks.add(CheckTask(name, false));
    });

    _textFieldController.clear();
  }

  Future<void> _displayDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a new check-task'),
          content: TextField(
            controller: _textFieldController,
            decoration:
                const InputDecoration(hintText: 'Type your new check-task'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                Navigator.of(context).pop();
                _addCheckTaskItem(_textFieldController.text);
                _saveCheckItems(_checkTasks);
              },
            ),
          ],
        );
      },
    );
  }
}

class CheckTaskItem extends StatelessWidget {
  final CheckTask checkTask;
  final OnCheckStatusChanged;

  const CheckTaskItem(
      {Key? key, required this.checkTask, required this.OnCheckStatusChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(checkTask.name,
          style: TextStyle(
              decoration: checkTask.checked
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: checkTask.checked ? Colors.grey : Colors.black)),
      onTap: () {
        OnCheckStatusChanged(!checkTask.checked);
      },
      trailing: Checkbox(
        value: checkTask.checked,
        onChanged: (bool? value) {
          OnCheckStatusChanged(!checkTask.checked);
        },
      ),
    );
  }
}
