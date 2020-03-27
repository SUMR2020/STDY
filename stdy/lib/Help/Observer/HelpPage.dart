import 'package:flutter/material.dart';
import '../Subject/Entry.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
          centerTitle: true,
          backgroundColor: Color(0x00000000),
          elevation: 0,
          title: Text('ABOUT THE APP')
      ),
        body: ListView.builder(
          itemBuilder: (BuildContext context, int index) =>
              HelpTiles(data[index]),
          itemCount: data.length,
        ),
      );
  }
}
// Displays one Entry. If the entry has children then it's displayed
// with an ExpansionTile.
class HelpTiles extends StatelessWidget {
  const HelpTiles(this.entry);

  final Entry entry;

  Widget _buildTiles(Entry root) {
    if (root.children.isEmpty) return ListTile(title: Text(root.title));
    return ExpansionTile(
      key: PageStorageKey<Entry>(root),
      title: Text(root.title),
      children: root.children.map(_buildTiles).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry);
  }}
