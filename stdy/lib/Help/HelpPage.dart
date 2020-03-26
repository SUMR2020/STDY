import 'package:flutter/material.dart';


class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
          itemBuilder: (BuildContext context, int index) =>
              HelpTiles(data[index]),
          itemCount: data.length,
        ),
      );
  }
}

// One entry in the multilevel list displayed by this app.
class Entry {
  Entry(this.title, [this.children = const <Entry>[]]);

  final String title;
  final List<Entry> children;
}

// The entire multilevel list displayed by this app.
final List<Entry> data = <Entry>[
  Entry(
    'Home Page',
        <Entry>[
          Entry(
            'Viewing Schedule',
            <Entry>[
              Entry('beep'),
            ],
          ),
          Entry(
            'Entering New Task',
            <Entry>[
              Entry('beep'),
            ],
          ),
        ],
  ),
  Entry(
    'Course Page',
    <Entry>[
      Entry(
        'Entering Current Course',
        <Entry>[
          Entry('beep'),
        ],
      ),
      Entry(
        'Entering Past Course',
        <Entry>[
          Entry('beep'),
        ],
      ),
      Entry(
        'Updating Task Data',
        <Entry>[
          Entry('beep'),
        ],
      ),
      Entry(
        'Completing a Course',
        <Entry>[
          Entry('beep'),
        ],
      ),
      Entry(
        'Predicting Your GPA/Grades',
        <Entry>[
          Entry('beep'),
        ],
      ),
    ],
  ),
  Entry(
    'Progress Page',
    <Entry>[
      Entry(
        'Viewing Progress',
        <Entry>[
          Entry('beep'),
        ],
      ),
      Entry(
        'How Progress is Calculated',
        <Entry>[
          Entry('beep'),
        ],
      ),
    ],
  ),
];

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
