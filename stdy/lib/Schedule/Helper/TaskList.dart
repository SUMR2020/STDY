import 'Task.dart';

class TaskList {
  List _tasks;

  TaskList(){
    _tasks = new List<Task>();
  }

  int length(){
    return _tasks.length;
  }

  Task get(int i){
    print (_tasks[i]);
    return _tasks[i];
  }

  void add(Task t) {
    // _tasks.sort((a, b) => a.someProperty.compareTo(b.someProperty));
//    print(t);
//      int n = _tasks.length;
//      int temp = 0;
//      for(int i=0; i < n; i++){
//        for(int j=1; j < (n-i); j++){
//          if(_tasks[j-1].course < _tasks[j].course){
//            temp = _tasks[j-1];
//            _tasks[j-1] = _tasks[j];
//            _tasks[j] = temp;
//          }
//      }
//
//    }
//      print (_tasks);

    _tasks.add(t);
  }
}
