import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master_projekt/Screens/task-detail.dart';
import 'package:master_projekt/drawer.dart';

class Tasks extends StatefulWidget {
  const Tasks({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new TasksState();
}
class TasksState extends State<Tasks> {
  var snapshots = FirebaseFirestore.instance.collection('tasks').snapshots();

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
        onWillPop: () async {
          bool willLeave = false;
          // show the confirm dialog
          await showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    title: Text('Go back to Homepage?'),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            willLeave = false;
                            Navigator.of(context).pop();
                            Navigator.pushReplacementNamed(context, '/');
                          },
                          child: Text('Yes')),
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('No'))
                    ],
                  ));
          return willLeave;
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Aufgaben'),
            actions: <Widget>[
              PopupMenuButton(
                  itemBuilder: (context) => [
                        PopupMenuItem(child: Text('Alle'), value: 1),
                        PopupMenuItem(child: Text('Offen'), value: 2),
                        PopupMenuItem(child: Text('Angenommen'), value: 3),
                        PopupMenuItem(child: Text('Abgeschlossen'), value: 4)
                      ],
                  onSelected: getFiltered
              )
            ],
          ),
          drawer: MyDrawer(),
          body: StreamBuilder<QuerySnapshot>(
            stream: snapshots,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData)
                return new Text("Es gibt aktuell keine Aufgaben.");
              return new ListView(
                children: getTasks(snapshot, context),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/task-create');
            },
            child: const Icon(Icons.add_circle),
            backgroundColor: Colors.deepOrange,
          ),
        ));
  }

  getTasks(AsyncSnapshot<QuerySnapshot> snapshot, BuildContext context) {
    return snapshot.data!.docs
        .map((doc) => Card(
            child: ListTile(
                title: new Text(doc['title']),
                subtitle: new Text(doc['description']),
                trailing: Icon(Icons.arrow_forward_ios_rounded),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TaskDetail(
                              title: doc['title'],
                              description: doc['description'],
                              subTasks: doc['subtasks'],
                              xp: doc['xp'],
                              time: doc['time'],
                              id: doc.reference.id)));
                })))
        .toList();
  }

   getFiltered(int value) {
    var tasks = FirebaseFirestore.instance.collection('tasks');
    if(value == 1) {
      setSnapshots(tasks.snapshots());
    } else if (value == 2) {
      setSnapshots(tasks.where('accepted', isEqualTo: false).where('finished', isEqualTo: false).snapshots());
    } else if (value == 3) {
      setSnapshots(tasks.where('accepted', isEqualTo: true).where('finished', isEqualTo: false).snapshots());
    } else if (value == 4) {
      setSnapshots(tasks.where('finished', isEqualTo: true).snapshots());
    }
  }

  setSnapshots(var value) {
    setState(() {
      snapshots = value;
    });
  }
}
