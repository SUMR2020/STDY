
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
    'Grades Page',
    <Entry>[
      Entry(
        'Audit Page Overview',
        <Entry>[
          Entry('The Audit page shows all your completed and current courses, listed by semester. If you wish to view a course in a semester, press the down arrow to the right of the'
              'semester name, then click on the course. The Stats header showcases the actual and current gpa. The actual GPA includes only all your completed courses, whereas the '
              'current GPA includes every course (The current course grades are taken from the tasks). '),
        ],
      ),
      Entry(
        'Course Page Overview',
        <Entry>[
          Entry('The Course page shows all your completed and current tasks, listed by task type. If you wish to view a task in a task type, press the down arrow to the right of the'
              'task tyoe name, then click on the task. The Stats header showcases the weighted and actual grades. The actual grade is the grade of all your completed tasks, defined by their weight,'
              ' whereas the weighted grade is the average grade you have divided by 100%, to give a more accurate estimate. The letter in the center is your current weighted letter grade. The progress'
              'bar defines how much of the course has been competed by adding up every task weight. '),
        ],
      ),
        Entry(
        'Task Page Overview',
        <Entry>[
          Entry('The task page allows you to view a task and its info. The weight of a task is the percent it takes up in your course grade, the grade of a task is the exact number points that have been earned for'
              'the specific task, and the total marks is what the task has been marked out of (i.e. 34/40, worth 10% in the course'),
        ],
      ),
      Entry(
        'Deleting Course/task',
        <Entry>[
          Entry('To delete either a course or a task, opem the corraponding page (audit/course), then open the drop down expansion pane and click the delete icon on the right.'),
        ],
      ),
      Entry(
        'Entering Current Course',
        <Entry>[
          Entry('To enter a current course, press the floating action button on the bottom right of the page, then select the (+) icon. Then check the "current course" checkbox, you will now be prompted'
              'to type in the course name, after this hit enter. The course should now be added with the current semester (Winter: Jan-Apr, Summer: May-Aug, Fall: Sep-Dec)'),
        ],
      ),
      Entry(
        'Entering Past Course',
        <Entry>[
          Entry('To enter a past course, press the floating action button on the bottom right of the page, then select the (+) icon. Then type in the course name, year, grade earned '
              '(Which can be either a percentage or a letter grade) and the semester (Winter: Jan-Apr, Summer: May-Aug, Fall: Sep-Dec), then press add course to add it.'),
        ],
      ),
      Entry(
        'Updating Task Data',
        <Entry>[
          Entry('To edit a task, you can simply click on the task in the course page. Then you are able to edit the task name, weight, grade and total marks once you press "save".'),
        ],
      ),
      Entry(
        'Completing Current Tasks',
        <Entry>[
          Entry('To complete current tasks, it is using the same method as updating a task or editing one as defined above.'),
        ],
      ),
      Entry(
        'Completing a Course',
        <Entry>[
          Entry("Once a course's total weight has reached 100%, you will be prompted automatically on task addition to have the option to complete a course. If you wish to complete it later, you can "
              "so by pressing the three dot icon on the top right. In the completion page you can complete the course with the current grade earned or type in your own grade (For cases where your course"
              "mark has been boosted, etc.), then press the complete button. Note: You cannot edit courses after completion."),
        ],
      ),
      Entry(
        'Predicting Your GPA',
        <Entry>[
          Entry('To predict your GPA, press the floating icon button on the bottom right, then click the "predictor" option. In here you first need to type in your total GPA out of 12.0, and then press the run'
              'button. By default the predictor determines the grades you will need for all your current courses to attain the desired gpa. However, if you wish you can tap the floating icon and choose from a'
              'list of your current courses to exclude when running the predictor. This means these courses will be treated as "completed" when they are not in reality.'),
        ],
      ),
      Entry(
        'Predicting Your Grades',
        <Entry>[
          Entry('To predict your grades, press the floating icon button on the bottom right, then click the "predictor" option. Here simply choose a desired letter or percentage grade, and press the "run" button.'),
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
