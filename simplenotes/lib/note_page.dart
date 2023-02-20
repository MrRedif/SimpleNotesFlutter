import 'package:flutter/material.dart';
import 'package:simplenotes/db/notes_db.dart';

import 'model/note.dart';

class NoteEditPage extends StatefulWidget {
  final Note? note;

  const NoteEditPage(this.note, {Key? key}) : super(key: key);

  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController textController = TextEditingController();
  bool isImportant = false;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.note?.title ?? "";
    textController.text = widget.note?.description ?? "";
    if(widget.note != null){
      Note n = widget.note!;
      isImportant = n.isImportant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.note != null ? "Change Note" : "Create Note"),
          backgroundColor: Colors.purple.shade900,
          actions: [
            widget.note != null
                ? IconButton(
                    onPressed: () async {
                      bool del = false;
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.purple.shade900,
                          actionsPadding: EdgeInsets.zero,
                          content: Text("Confirm Deletion",style: TextStyle(color: Colors.white),),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Container(
                                    color: const Color(0x1f255bff),
                                    child: Center(
                                      child: TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            "Back",
                                            textAlign: TextAlign.end,
                                            style: TextStyle(color: Colors.purpleAccent),
                                          )),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    color: Colors.red,
                                    child: Center(
                                      child: TextButton(
                                          onPressed: () async {
                                            int? idd = widget.note?.id;
                                            await NotesDatabase.instance.delete(idd!);
                                            del = true;
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            "Delete",
                                            textAlign: TextAlign.end,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold

                                            ),
                                          ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                      if (del) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete))
                : Container(),
            widget.note != null ?
                IconButton(onPressed: () async{
                  await NotesDatabase.instance.update(widget.note!.copy(isImportant: !isImportant));
                  setState(() {
                    isImportant = !isImportant;
                  });
                }, icon: Icon(isImportant ? Icons.favorite : Icons.favorite_border)) :
                Container(),
            IconButton(
              onPressed: () async {
                if (widget.note != null) {
                  await NotesDatabase.instance.update(widget.note!.copy(
                      title: titleController.text,
                      description: textController.text,isImportant: isImportant));
                } else {
                  await NotesDatabase.instance.create(Note(
                      title: titleController.text,
                      description: textController.text,
                      createdTime: DateTime.now(),
                      isImportant: false,
                      number: 0));
                }
                Navigator.pop(context);
              },
              icon: const Icon(Icons.save),
            ),
          ]),
      backgroundColor: const Color(0x1f255bff),
      body: CustomScrollView(slivers: [
        SliverFillRemaining(
          child: Column(
            children: [TitleField(titleController), DescField(textController)],
          ),
        ),
      ]),
    );
  }
}

class DescField extends StatelessWidget {
  final TextEditingController textController;

  const DescField(
    this.textController, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(color: Colors.deepPurple.shade800),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: TextField(
            expands: true,
            controller: textController,
            maxLines: null,
            minLines: null,
            decoration: const InputDecoration(
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
                hintText: "Desc..."),
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}

class TitleField extends StatelessWidget {
  final TextEditingController titleController;

  const TitleField(
    this.titleController, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0x311B92FF)),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: TextField(
            controller: titleController,
            minLines: 1,
            maxLines: 3,
            maxLength: 100,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              hintText: "Title",
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey),
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              overflow: TextOverflow.clip,
            )),
      ),
    );
  }
}
