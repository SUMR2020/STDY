import 'Task.dart';

/*
TaskList
A collection (iterator) class that uses the iterator design pattern to loop through
an underlying data structure.
  _tasks: list of tasks
  _index: current index
 */

class TaskList implements Iterator{
  List _tasks;
  var _index = 0;

  // looping through untim empty
  Task get current => _tasks[_index++];
  bool moveNext() => _index < _tasks.length;

  // ctor
  TaskList(){
    _tasks = new List<Task>();
  }

  //returning the length
  int length(){
    return _tasks.length;
  }

  // getting at specific location
  Task get(int i){
    print (_tasks[i]);
    return _tasks[i];
  }

  // adding task to the list using bubble sort
  void add(Task t) {
    _tasks.add(t);
  }
}
