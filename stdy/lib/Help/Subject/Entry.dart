
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
          Entry("How can you see into my eyes like open doors? Leading you down,"
        " into my core Where I've become so numb, without a soul My spirit's "
              "sleeping somewhere cold Until you find it there, and lead it, back,"
              " home Wake me up insideWake me up insideCall my name and save me "
              "from the darkBid my blood to runBefore I come undoneSave me from"
              " the nothing I've becomeNow that I know what I'm withoutYou can't"
              " just leave meBreathe into me and make me realBring me to life Wake "
              "me up insideWake me up insideCall my name and save me from the dark "
              "Bid my blood to runBefore I come undoneSave me from the nothing I've become"),
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
