import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study/GoogleAPI/Firestore/ProgressFirestore.dart';


class ProgressData {

  ProgressFirestore fireStore;

   static final List<String> taskTypes = ['assignment', 'reading', 'project', 'lectures', 'notes'];



  ProgressData() {
    fireStore = ProgressFirestore();
  }

  bool withinSevenDays(DateTime t){
    var diff = DateTime.now().difference(t);
    return diff.inDays <= 7;
  }

  _progressTimeline(var task){

  }

  _progressAggregate(var task){
    double weeklyProgress = 0.0;
    double weeklyGoal = 0.0;

    for (int i = 0; i<task.data['allday'].length; i++){
      if (withinSevenDays(task.data['allday'][i].toDate())){
        String goal = task.data['goal'][i].toString();
        String progress = task.data['progress'][i].toString();
        weeklyGoal += double.parse(goal);
        weeklyProgress += double.parse(progress);
      }
    }
    var progressPercentage = {
      "weeklyProgress": weeklyProgress,
      "weeklyGoal": weeklyGoal
    };
    return progressPercentage;
  }

  _courseProgress(var coursesTasks, var task){
    var progressAggregate = _progressAggregate(task);

    if (coursesTasks[task.data['onlyCourse']] != null) {
      var aggregate = coursesTasks[task.data['onlyCourse']];
      //print(percentage.toString());
      aggregate['totalProgress'] += progressAggregate['weeklyProgress'];
      aggregate['totalGoal']  += progressAggregate['weeklyGoal'];
    } else {
      coursesTasks[task.data['onlyCourse']] = {
        "totalProgress": progressAggregate['weeklyProgress'],
        "totalGoal":  progressAggregate['weeklyGoal']
      };
    }
  }

  _taskProgress(var taskProgress, var task, var taskType){
    if (task.data['type'] == taskType) {
      var course = task.data['onlyCourse'];
      var progPerc = _progressAggregate(task);
      if (taskProgress[taskType][course] != null){
        taskProgress[taskType][course]['weeklyProgress'] += progPerc['weeklyProgress'];
        taskProgress[taskType][course]['weeklyGoal'] += progPerc['weeklyGoal'];
      } else{
        taskProgress[taskType][course] = {
          'weeklyProgress': progPerc['weeklyProgress'],
          'weeklyGoal' : progPerc['weeklyGoal']
        };
      }
    }
  }


  _courseTimeline(var courseTimeline, var task){
    print("in course time line");
    print(task.data['allday'].length.toString());
    for (int i = 0; i<task.data['allday'].length; i++){
      print("in loop");
//      print("allday: " + task.data['allday'][i].toDate())
      var allDayTime = task.data['allday'][i].toDate();
      print(allDayTime.toString());
      var timeDiff = allDayTime.difference(DateTime.now()).inDays;
      print("timeDiff: " + timeDiff.toString());
      String goal = task.data['goal'][i].toString();
      String progress = task.data['progress'][i].toString();
      courseTimeline[timeDiff.toString()]['totalGoal'] += double.parse(goal);
      courseTimeline[timeDiff.toString()]['totalProgress'] += double.parse(progress);
    }

  }

  _taskTimeline(var timeline, var task, var t){
    if (task.data['type'] == t){
      for (int i = 0; i<task.data['allday'].length; i++){
        var timeDiff = task.data['allday'][i].toDate().difference(DateTime.now()).inDays;
        print(timeDiff);
        String goal = task.data['goal'][i].toString();
        String progress = task.data['progress'][i].toString();
        timeline[t][timeDiff.toString()]['totalGoal'] += double.parse(goal);
        timeline[t][timeDiff.toString()]['totalProgress'] += double.parse(progress);
      }
    }
  }


  Future<void> fetchProgressData() async{
    List<DocumentSnapshot> tasks = await fireStore.getTasks();
    var progress = {
      'total': {},
      'assignment':{},
      'reading': {},
      'project': {},
      'lectures': {},
      'notes': {}
    };
    var timeline = {
      'total': {
        "-6": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-5": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-4": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-3": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-2": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-1": {"totalGoal": 0.0, "totalProgress": 0.0},
        "0": {"totalGoal": 0.0, "totalProgress": 0.0},
      },
      'assignment':{
        "-6": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-5": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-4": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-3": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-2": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-1": {"totalGoal": 0.0, "totalProgress": 0.0},
        "0": {"totalGoal": 0.0, "totalProgress": 0.0},
        },
      'reading':{
        "-6": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-5": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-4": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-3": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-2": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-1": {"totalGoal": 0.0, "totalProgress": 0.0},
        "0": {"totalGoal": 0.0, "totalProgress": 0.0},
      },
      'project':{
        "-6": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-5": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-4": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-3": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-2": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-1": {"totalGoal": 0.0, "totalProgress": 0.0},
        "0": {"totalGoal": 0.0, "totalProgress": 0.0},
      },
      'lectures':{
        "-6": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-5": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-4": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-3": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-2": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-1": {"totalGoal": 0.0, "totalProgress": 0.0},
        "0": {"totalGoal": 0.0, "totalProgress": 0.0},
      },
      'notes':{
        "-6": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-5": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-4": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-3": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-2": {"totalGoal": 0.0, "totalProgress": 0.0},
        "-1": {"totalGoal": 0.0, "totalProgress": 0.0},
        "0": {"totalGoal": 0.0, "totalProgress": 0.0},
      }
    };

    for (var task in tasks){
      print("task: ");
      print(task.data['name']);
      if (task.data['curr']){
        _courseProgress(progress['total'], task);
        _courseTimeline(timeline['total'], task);
        for (var t in taskTypes){
          _taskProgress(progress, task, t);
          _taskTimeline(timeline, task, t);

        }
      }
    }
//    print(timeline['assignment'].toString());

    double sumTotalProgress = 0.0;
    progress['total'].forEach((k, v) => sumTotalProgress +=  v['totalProgress']);
    progress['total'].forEach((k, v) => v['percent'] = (v['totalProgress']/sumTotalProgress)*100);
    for (var t in taskTypes){
      double sumTotalProgress = 0.0;
      progress[t].forEach((k, v) => sumTotalProgress +=  v['weeklyProgress']);
      for (var v in progress[t].values){
        var percent = 0.0;
        if (v['weeklyProgress'] != 0.0){
          percent = (v['weeklyProgress']/sumTotalProgress)*100;
        }
        v['percent'] = percent;
      }
    }
    return progress;
  }

  Future  getTotalProgressDatat() async{
    print("in get total progress");
    return await fetchProgressData();
  }
}