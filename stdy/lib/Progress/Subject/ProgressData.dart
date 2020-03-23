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

    for (var task in tasks){
      if (task.data['curr']){
        _courseProgress(progress['total'], task);
        for (var t in taskTypes){
          _taskProgress(progress, task, t);

        }
      }
    }

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
    return await fetchProgressData();
  }
}