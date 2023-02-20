import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simplenotes/db/notes_db.dart';
import 'package:simplenotes/note_page.dart';

import 'model/note.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "SimpleNotes",
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Note> notes;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SimpleNotes"),
        backgroundColor: Colors.purple.shade900,
      ),
      body: isLoading ? Center(child: CircularProgressIndicator()) : NoteList(),
      floatingActionButton: !isLoading
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return NoteEditPage(null);
                  },
                ));
                refreshNotes();
              },
              child: Container(child: Icon(Icons.add)),
              backgroundColor: Colors.pink,
            )
          : null,
      backgroundColor: Color(0x1f255bff),
    );
  }

  void refreshNotes() async {
    setState(() {
      isLoading = true;
    });
    notes = await NotesDatabase.instance.readAllNote();
    setState(() {
      isLoading = false;
    });
  }
}

class NoteList extends StatefulWidget {
  NoteList({
    super.key,
  });

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  late List<Note> notes;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    refreshNotes();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center()
        : ListView.builder(
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () async {
                  print("Tap $index");
                  await Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return NoteEditPage(notes[index]);
                    },
                  ));
                  refreshNotes();
                },
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                        index % 2 == 0
                            ? Colors.deepPurple.shade900
                            : Colors.deepPurple.shade600,
                        index % 2 == 0
                            ? Colors.deepPurple.shade600
                            : Colors.deepPurple.shade900,
                      ])),
                  child: Center(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10, top: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 350,
                                    child: Text(
                                      maxLines: 1,
                                      notes[index].title,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: notes[index].isImportant
                                              ? Color(0xFFFFCC00)
                                              : Colors.white,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: SizedBox(
                                      width: 350,
                                      child: Text(
                                        notes[index].description,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Expanded(child: Container()),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 3.0, right: 3),
                              child: Text(
                                DateFormat("HH:mm dd MMM yyy")
                                    .format(notes[index].createdTime),
                                style: TextStyle(color: Colors.purpleAccent),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
            itemCount: notes.length,
          );
  }

  void refreshNotes() async {
    setState(() {
      loading = true;
    });
    notes = await NotesDatabase.instance.readAllNote();
    setState(() {
      loading = false;
    });
  }
}
