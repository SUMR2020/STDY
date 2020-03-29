
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
          Entry("To use the schedule, hold down on the specific day you wish to see events for! This schedule syncs to your"
              " primary Google Calendar."),
        ],
      ),
      Entry(
        'Entering New Task',
        <Entry>[
          Entry("To enter a new task, press the (+) button on the home page, then select the form of task"
              " (reading, assignment, project, lecture or notes) "
              "afterwards, you input the due date, the days of the week you want to work on the task, and the estimated "
          "time it will take to complete. You can always change this later if you think it will take less or more time than originally expected!"
          ),
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
          Entry('The first tab shows the overall progress of all tasks, '
              'the following tabs breakdown progress based on the type of task such as assignments, '
              'projects, readings etc. Flip through the tabs to get a more in-depth look at your progress.'),
        ],
      ),
      Entry(
        'How Progress is Calculated',
        <Entry>[
          Entry('We aggregate the number of tasks in a given week and sum  the number of hours you '
              'plan to spend on them. Then for each task, the  progress you input is calculated as a '
              'percentage of that total time. For the actual vs expected amount of work graph, the expected '
              'amount of work is the time you plan to spend on each task in hours per day, '
              'and the actual amount of work is what you input as progress. '),
        ],
      ),
    ],
  ),
];
