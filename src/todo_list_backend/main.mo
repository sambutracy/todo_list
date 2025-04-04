import Iter "mo:base/Iter";
import Text "mo:base/Text";
import List "mo:base/List";
import Debug "mo:base/Debug";
import Time "mo:base/Time";
import Int "mo:base/Int";
import Array "mo:base/Array";

actor TodoList {
  type Task = {
    id : Nat;
    description : Text;
    completed : Bool;
    timestamp : Int;
    dueDate : Int; // Added dueDate field as per requirements
  };
  
  var tasks : List.List<Task> = List.nil();
  var nextId : Nat = 0;
  
  // Helper function to convert days to nanoseconds
  private func daysToNanoseconds(days : Int) : Int {
    return days * 24 * 60 * 60 * 1000000000;
  };
  
  // Add a new task with description and optional due date in days from now
  public func addTask(description : Text, dueDays : Int) : async Nat {
    let currentTime = Time.now();
    let dueDate = currentTime + daysToNanoseconds(dueDays);
    
    let task : Task = {
      id = nextId;
      description = description;
      completed = false;
      timestamp = currentTime;
      dueDate = dueDate;
    };
    
    tasks := List.push(task, tasks);
    nextId += 1;
    return task.id;
  };
  
  // Get all tasks
  public query func getTasks() : async [Task] {
    return List.toArray(tasks);
  };
  
  // Get a specific task by id
  public func getTask(id : Nat) : async ?Task {
    return List.find<Task>(tasks, func(task) { task.id == id });
  };
  
  // Mark a task as completed
  public func completeTask(id : Nat) : async Bool {
    var found = false;
    tasks := List.map<Task, Task>(tasks, func(task) {
      if (task.id == id) {
        found := true;
        return {
          id = task.id;
          description = task.description;
          completed = true;
          timestamp = task.timestamp;
          dueDate = task.dueDate;
        };
      } else {
        return task;
      };
    });
    return found;
  };
  
  // Delete a task by id
  public func deleteTask(id : Nat) : async Bool {
    let oldSize = List.size(tasks);
    tasks := List.filter<Task>(tasks, func(task) { task.id != id });
    return oldSize > List.size(tasks);
  };
  
  // Get only incomplete tasks
  public query func getIncompleteTasks() : async [Task] {
    let incompleteTasks = List.filter<Task>(tasks, func(task) { not task.completed });
    return List.toArray(incompleteTasks);
  };
  
  // Get only completed tasks
  public query func getCompletedTasks() : async [Task] {
    let completedTasks = List.filter<Task>(tasks, func(task) { task.completed });
    return List.toArray(completedTasks);
  };
  
  // Get overdue tasks (due date has passed and not completed)
  public query func getOverdueTasks() : async [Task] {
    let currentTime = Time.now();
    let overdueTasks = List.filter<Task>(tasks, func(task) { 
      not task.completed and task.dueDate < currentTime 
    });
    return List.toArray(overdueTasks);
  };
  
  // Bonus: Edit task description
  public func editTaskDescription(id : Nat, newDescription : Text) : async Bool {
    var found = false;
    tasks := List.map<Task, Task>(tasks, func(task) {
      if (task.id == id) {
        found := true;
        return {
          id = task.id;
          description = newDescription;
          completed = task.completed;
          timestamp = task.timestamp;
          dueDate = task.dueDate;
        };
      } else {
        return task;
      };
    });
    return found;
  };
  
  // Bonus: Edit task due date
  public func editTaskDueDate(id : Nat, dueDays : Int) : async Bool {
    let newDueDate = Time.now() + daysToNanoseconds(dueDays);
    var found = false;
    
    tasks := List.map<Task, Task>(tasks, func(task) {
      if (task.id == id) {
        found := true;
        return {
          id = task.id;
          description = task.description;
          completed = task.completed;
          timestamp = task.timestamp;
          dueDate = newDueDate;
        };
      } else {
        return task;
      };
    });
    return found;
  };
  
  // Bonus: Get tasks sorted by due date (oldest first)
  public query func getTasksSortedByDueDate() : async [Task] {
    let taskArray = List.toArray(tasks);
    
    // Sort the tasks by due date (oldest first)
    let sortedTasks = Array.sort<Task>(taskArray, func(a, b) {
      return Int.compare(a.dueDate, b.dueDate);
    });
    
    return sortedTasks;
  };
}