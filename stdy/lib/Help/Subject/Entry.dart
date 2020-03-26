
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
