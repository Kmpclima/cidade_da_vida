
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class TagsManagerScreen extends StatefulWidget {
const TagsManagerScreen({super.key});

@override
State<TagsManagerScreen> createState() => _TagsManagerScreenState();
}

class _TagsManagerScreenState extends State<TagsManagerScreen> {
late Box<List<String>> tagsBox;
List<String> tags = [];

final TextEditingController _tagController = TextEditingController();

@override
void initState() {
super.initState();
tagsBox = Hive.box<List<String>>('tags');
tags = tagsBox.get('tags', defaultValue: []) ?? [];
}

void _addTag(String tag) {
if (tag.isNotEmpty && !tags.contains(tag)) {
tags.add(tag);
tagsBox.put('tags', tags);
setState(() {});
}
}

void _deleteTag(String tag) {
tags.remove(tag);
tagsBox.put('tags', tags);
setState(() {});
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text("Gerenciar Tags")),
body: Column(
children: [
Padding(
padding: const EdgeInsets.all(8.0),
child: Row(
children: [
Expanded(
child: TextField(
controller: _tagController,
decoration: const InputDecoration(
labelText: "Nova Tag",
),
),
),
IconButton(
icon: const Icon(Icons.add),
onPressed: () {
_addTag(_tagController.text.trim());
_tagController.clear();
},
)
],
),
),
Expanded(
child: ListView.builder(
itemCount: tags.length,
itemBuilder: (context, index) {
final tag = tags[index];
return ListTile(
title: Text(tag),
trailing: IconButton(
icon: const Icon(Icons.delete),
onPressed: () => _deleteTag(tag),
),
);
},
),
)
],
),
);
}
}