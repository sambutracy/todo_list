import Iter "mo:base/Iter";
import Text "mo:base/Text";
import List "mo:base/List";
import Debug "mo:base/Debug";
import Time "mo:base/Time";
import Int "mo:base/Int";
import Array "mo:base/Array";
import Nat "mo:base/Nat";

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
  
  // Get completed tasks
  public query func getCompletedTasks() : async [Task] {
    let completedTasks = List.filter<Task>(tasks, func(task: Task) : Bool { 
      task.completed 
    });
    return List.toArray(completedTasks);
  };
  
  // Get incomplete tasks
  public query func getIncompleteTasks() : async [Task] {
    let incompleteTasks = List.filter<Task>(tasks, func(task: Task) : Bool { 
      not task.completed 
    });
    return List.toArray(incompleteTasks);
  };
  
  // Get overdue tasks (incomplete tasks with due date in the past)
  public query func getOverdueTasks() : async [Task] {
    let currentTime = Time.now();
    let overdueTasks = List.filter<Task>(tasks, func(task: Task) : Bool { 
      not task.completed and task.dueDate < currentTime
    });
    return List.toArray(overdueTasks);
  };
  
  // Get tasks sorted by due date (earliest first)
  public query func getTasksSortedByDueDate() : async [Task] {
    let tasksArray = List.toArray(tasks);
    let sortedTasks = Array.sort<Task>(
      tasksArray,
      func(a: Task, b: Task) : { #less; #equal; #greater } {
        if (a.dueDate < b.dueDate) { #less }
        else if (a.dueDate == b.dueDate) { #equal }
        else { #greater }
      }
    );
    return sortedTasks;
  };
  
  // Get a specific task by id
  public func getTask(id : Nat) : async ?Task {
    return List.find<Task>(tasks, func(task: Task) : Bool { task.id == id });
  };
  
  // Mark a task as completed
  public func completeTask(id : Nat) : async Bool {
    let taskOpt = List.find<Task>(tasks, func(task: Task) : Bool { task.id == id });
    
    switch (taskOpt) {
      case (null) {
        return false; // Task not found
      };
      case (?task) {
        let updatedTask : Task = {
          id = task.id;
          description = task.description;
          completed = true;
          timestamp = task.timestamp;
          dueDate = task.dueDate;
        };
        
        tasks := List.map<Task, Task>(
          tasks,
          func(t: Task) : Task {
            if (t.id == id) { updatedTask } else { t }
          }
        );
        
        return true;
      };
    };
  };
  
  // Delete a task
  public func deleteTask(id : Nat) : async Bool {
    let tasksBeforeDelete = List.size(tasks);
    tasks := List.filter<Task>(tasks, func(task: Task) : Bool { task.id != id });
    return List.size(tasks) != tasksBeforeDelete;
  };
  
  // Edit task description
  public func editTaskDescription(id : Nat, newDescription : Text) : async Bool {
    let taskOpt = List.find<Task>(tasks, func(task: Task) : Bool { task.id == id });
    
    switch (taskOpt) {
      case (null) {
        return false; // Task not found
      };
      case (?task) {
        let updatedTask : Task = {
          id = task.id;
          description = newDescription;
          completed = task.completed;
          timestamp = task.timestamp;
          dueDate = task.dueDate;
        };
        
        tasks := List.map<Task, Task>(
          tasks,
          func(t: Task) : Task {
            if (t.id == id) { updatedTask } else { t }
          }
        );
        
        return true;
      };
    };
  };
  
  // Edit task due date
  public func editTaskDueDate(id : Nat, newDueDays : Int) : async Bool {
    let taskOpt = List.find<Task>(tasks, func(task: Task) : Bool { task.id == id });
    
    switch (taskOpt) {
      case (null) {
        return false; // Task not found
      };
      case (?task) {
        let currentTime = Time.now();
        let newDueDate = currentTime + daysToNanoseconds(newDueDays);
        
        let updatedTask : Task = {
          id = task.id;
          description = task.description;
          completed = task.completed;
          timestamp = task.timestamp;
          dueDate = newDueDate;
        };
        
        tasks := List.map<Task, Task>(
          tasks,
          func(t: Task) : Task {
            if (t.id == id) { updatedTask } else { t }
          }
        );
        
        return true;
      };
    };
  };
}