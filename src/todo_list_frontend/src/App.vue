<script setup>
import { ref, onMounted, computed } from 'vue';
import { todo_list_backend } from 'declarations/todo_list_backend';

// State
const tasks = ref([]);
const newTaskDescription = ref('');
const dueDays = ref(7);
const isLoading = ref(true);
const selectedTab = ref('all');
const editingTask = ref(null);
const editTaskDescription = ref('');
const editTaskDueDays = ref(0);
const error = ref('');

// Load all tasks
async function loadTasks() {
  isLoading.value = true;
  try {
    if (selectedTab.value === 'all') {
      tasks.value = await todo_list_backend.getTasks();
    } else if (selectedTab.value === 'completed') {
      tasks.value = await todo_list_backend.getCompletedTasks();
    } else if (selectedTab.value === 'incomplete') {
      tasks.value = await todo_list_backend.getIncompleteTasks();
    } else if (selectedTab.value === 'overdue') {
      tasks.value = await todo_list_backend.getOverdueTasks();
    } else if (selectedTab.value === 'byDueDate') {
      tasks.value = await todo_list_backend.getTasksSortedByDueDate();
    }
  } catch (e) {
    error.value = `Error loading tasks: ${e.message}`;
    console.error(e);
  } finally {
    isLoading.value = false;
  }
}

// Add a new task
async function addTask() {
  if (!newTaskDescription.value.trim()) {
    error.value = 'Please enter a task description';
    return;
  }
  
  try {
    await todo_list_backend.addTask(newTaskDescription.value, Number(dueDays.value));
    newTaskDescription.value = '';
    dueDays.value = 7;
    await loadTasks();
    error.value = '';
  } catch (e) {
    error.value = `Error adding task: ${e.message}`;
    console.error(e);
  }
}

// Mark a task as completed
async function completeTask(id) {
  try {
    // You'll need to implement this function in your backend
    await todo_list_backend.completeTask(id);
    await loadTasks();
  } catch (e) {
    error.value = `Error completing task: ${e.message}`;
    console.error(e);
  }
}

// Delete a task
async function deleteTask(id) {
  if (confirm('Are you sure you want to delete this task?')) {
    try {
      // You'll need to implement this function in your backend
      await todo_list_backend.deleteTask(id);
      await loadTasks();
    } catch (e) {
      error.value = `Error deleting task: ${e.message}`;
      console.error(e);
    }
  }
}

// Formatted due date
function formatDueDate(timestamp) {
  const date = new Date(Number(timestamp) / 1000000); // Convert nanoseconds to milliseconds
  return date.toLocaleDateString();
}

// Check if a task is overdue
function isOverdue(task) {
  if (task.completed) return false;
  const now = Date.now() * 1000000; // Current time in nanoseconds
  return Number(task.dueDate) < now;
}

// Add this function to your <script setup> section if not already present
function changeTab(tab) {
  selectedTab.value = tab;
  loadTasks();
}

// Start editing a task
function startEdit(task) {
  // Make a deep copy of the task to avoid reference issues
  editingTask.value = {...task};
  editTaskDescription.value = task.description;
  
  // Calculate due days from now based on the current time
  const currentTimeMs = Date.now() * 1000000; // Convert to nanoseconds
  const dueDateMs = Number(task.dueDate);
  const diffMs = dueDateMs - currentTimeMs;
  const diffDays = Math.round(diffMs / (24 * 60 * 60 * 1000000000));
  editTaskDueDays.value = diffDays > 0 ? diffDays : 1;
}

// Save edited task
async function saveEdit() {
  try {
    // Add null check
    if (!editingTask.value) {
      error.value = "No task is being edited";
      return;
    }
    
    if (!editTaskDescription.value.trim()) {
      error.value = "Task description cannot be empty";
      return;
    }
    
    // Update the task description
    const descriptionUpdated = await todo_list_backend.editTaskDescription(
      editingTask.value.id, 
      editTaskDescription.value
    );
    
    // Update the task due date
    const dueDateUpdated = await todo_list_backend.editTaskDueDate(
      editingTask.value.id, 
      Number(editTaskDueDays.value)
    );
    
    if (descriptionUpdated && dueDateUpdated) {
      // Reset editing state
      editingTask.value = null;
      
      // Reload tasks to show the updated task
      await loadTasks();
      error.value = "";
    } else {
      error.value = "Failed to update task";
    }
  } catch (e) {
    console.error("Edit error:", e);
    error.value = `Error updating task: ${e.message}`;
  }
}

// Cancel editing
function cancelEdit() {
  editingTask.value = null;
  error.value = '';
}

// Load initial data
onMounted(async () => {
  await loadTasks();
});
</script>

<template>
  <main class="container">
    <div class="app-header">
      <h1>✨ My Pretty Todo List ✨</h1>
      <div class="header-decoration"></div>
    </div>
    
    <!-- Error display -->
    <div v-if="error" class="error">{{ error }}</div>
    
    <!-- Add Task Form -->
    <section class="add-task">
      <h2>✏️ Add New Task</h2>
      <form @submit.prevent="addTask">
        <div class="form-group">
          <label for="description">What do you need to do?</label>
          <input 
            id="description" 
            v-model="newTaskDescription" 
            type="text" 
            placeholder="Enter your task here..."
            required
          />
        </div>
        
        <div class="form-group">
          <label for="dueDays">Complete in how many days?</label>
          <input 
            id="dueDays" 
            v-model="dueDays" 
            type="number" 
            min="1" 
            required
          />
        </div>
        
        <button type="submit" class="btn-primary">Add to My List 💖</button>
      </form>
    </section>
    
    <!-- Task Filters -->
    <section class="filters-container">
      <h2>💫 Filter Tasks 💫</h2>
      <div class="filters">
        <button 
          :class="{ active: selectedTab === 'all' }" 
          @click="changeTab('all')"
        >
          <span class="filter-icon">🌈</span>
          <span>All Tasks</span>
        </button>
        
        <button 
          :class="{ active: selectedTab === 'incomplete' }" 
          @click="changeTab('incomplete')"
        >
          <span class="filter-icon">🌱</span>
          <span>Active</span>
        </button>
        
        <button 
          :class="{ active: selectedTab === 'completed' }" 
          @click="changeTab('completed')"
        >
          <span class="filter-icon">✅</span>
          <span>Completed</span>
        </button>
        
        <button 
          :class="{ active: selectedTab === 'overdue' }" 
          @click="changeTab('overdue')"
        >
          <span class="filter-icon">⏰</span>
          <span>Overdue</span>
        </button>
        
        <button 
          :class="{ active: selectedTab === 'byDueDate' }" 
          @click="changeTab('byDueDate')"
        >
          <span class="filter-icon">📅</span>
          <span>By Due Date</span>
        </button>
      </div>
      <div class="filter-decoration"></div>
    </section>
    
    <!-- Task List -->
    <section class="task-list">
      <h2>📝 My Tasks</h2>
      
      <div v-if="isLoading" class="loading">
        <div class="loading-spinner"></div>
        Loading your tasks...
      </div>
      
      <div v-else-if="tasks.length === 0" class="empty-list">
        <p>You have no tasks yet! 🌸</p>
        <p>Add something above to get started.</p>
      </div>
      
      <ul v-else>
        <li v-for="task in tasks" :key="task.id" 
            :class="{ completed: task.completed, overdue: isOverdue(task) }">
          
          <!-- Editing Mode -->
          <div v-if="editingTask && editingTask.id === task.id" class="edit-form">
            <div class="form-group">
              <label for="edit-description">Description:</label>
              <input 
                id="edit-description" 
                v-model="editTaskDescription" 
                type="text"
                required
              />
            </div>
            
            <div class="form-group">
              <label for="edit-due-days">Due in (days):</label>
              <input 
                id="edit-due-days" 
                v-model="editTaskDueDays" 
                type="number" 
                min="1"
                required
              />
            </div>
            
            <div class="edit-buttons">
              <button type="button" @click="saveEdit" class="btn-save">Save</button>
              <button type="button" @click="cancelEdit" class="btn-cancel">Cancel</button>
            </div>
          </div>
          
          <!-- View Mode -->
          <div v-else class="task-item">
            <div class="task-info">
              <div class="task-description" :class="{ 'text-strike': task.completed }">
                {{ task.description }}
                <span v-if="task.completed" class="completion-badge">Completed!</span>
              </div>
              <div class="task-due-date" :class="{ 'overdue-text': isOverdue(task) }">
                Due: {{ formatDueDate(task.dueDate) }}
              </div>
            </div>
            
            <div class="task-actions">
              <button v-if="!task.completed" @click="completeTask(task.id)" class="btn-complete">
                Done ✓
              </button>
              <button @click="startEdit(task)" class="btn-edit">
                Edit ✏️
              </button>
              <button @click="deleteTask(task.id)" class="btn-delete">
                Delete
              </button>
            </div>
          </div>
        </li>
      </ul>
    </section>
    
    <footer class="app-footer">
      Made with 💕 on the Internet Computer
    </footer>
  </main>
</template>

<style>
@import url('https://fonts.googleapis.com/css2?family=Quicksand:wght@400;500;600&family=Dancing+Script&display=swap');

:root {
  --primary-color: #f06292;
  --primary-light: #ffb6c1;
  --primary-dark: #e91e63;
  --accent-color: #9c27b0;
  --text-color: #4a4a4a;
  --light-text: #757575;
  --completed-color: #a7ffeb;
  --overdue-color: #ff80ab;
  --background-color: #fef9fd;
  --card-color: #ffffff;
  --border-color: #f8bbd0;
}

body {
  background-color: var(--background-color);
  background-image: 
    radial-gradient(#fee9f6 15%, transparent 16%),
    radial-gradient(#fce0f3 15%, transparent 16%);
  background-size: 60px 60px;
  background-position: 0 0, 30px 30px;
  margin: 0;
  padding: 0;
  font-family: 'Quicksand', sans-serif;
  color: var(--text-color);
}

.container {
  max-width: 800px;
  margin: 2rem auto;
  padding: 2rem;
  background-color: var(--card-color);
  border-radius: 20px;
  box-shadow: 0 10px 25px rgba(240, 98, 146, 0.1);
}

.app-header {
  text-align: center;
  margin-bottom: 2.5rem;
}

h1 {
  font-family: 'Dancing Script', cursive;
  font-size: 3rem;
  color: var(--primary-dark);
  margin-bottom: 0.5rem;
  letter-spacing: 1px;
}

.header-decoration {
  height: 10px;
  background: linear-gradient(90deg, 
    var(--primary-light) 0%, 
    var(--primary-color) 50%, 
    var(--accent-color) 100%);
  border-radius: 10px;
  margin: 0 auto 1rem;
  width: 60%;
}

h2 {
  color: var(--primary-color);
  margin-bottom: 1.5rem;
  font-weight: 600;
  font-size: 1.5rem;
  position: relative;
  display: inline-block;
}

h2::after {
  content: '';
  position: absolute;
  bottom: -5px;
  left: 0;
  width: 100%;
  height: 3px;
  background-color: var(--primary-light);
  border-radius: 2px;
}

.error {
  background-color: #ffebee;
  color: #d50000;
  padding: 1rem;
  border-radius: 10px;
  margin-bottom: 1.5rem;
  border-left: 4px solid #ff5252;
  font-size: 0.9rem;
}

.form-group {
  margin-bottom: 1.5rem;
}

label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: var(--primary-dark);
}

input[type="text"],
input[type="number"] {
  width: 100%;
  padding: 0.8rem;
  border: 2px solid var(--border-color);
  border-radius: 10px;
  font-size: 1rem;
  transition: border-color 0.3s;
  font-family: 'Quicksand', sans-serif;
}

input[type="text"]:focus,
input[type="number"]:focus {
  border-color: var(--primary-color);
  outline: none;
  box-shadow: 0 0 0 3px rgba(240, 98, 146, 0.2);
}

.btn-primary {
  background-color: var(--primary-color);
  color: white;
  border: none;
  border-radius: 10px;
  padding: 0.8rem 1.5rem;
  font-size: 1rem;
  cursor: pointer;
  transition: background-color 0.3s, transform 0.2s;
  font-weight: 600;
  font-family: 'Quicksand', sans-serif;
  box-shadow: 0 4px 6px rgba(240, 98, 146, 0.25);
}

.btn-primary:hover {
  background-color: var(--primary-dark);
  transform: translateY(-2px);
}

.btn-primary:active {
  transform: translateY(0);
}

.task-list {
  margin-top: 3rem;
}

.loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  color: var(--light-text);
  margin: 2rem 0;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid var (--primary-light);
  border-top: 4px solid var(--primary-color);
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 1rem;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.empty-list {
  text-align: center;
  color: var(--light-text);
  margin: 3rem 0;
  background-color: #fdf9fb;
  padding: 2rem;
  border-radius: 10px;
  border: 2px dashed var(--border-color);
}

.empty-list p {
  margin: 0.5rem 0;
}

ul {
  list-style: none;
  padding: 0;
}

li {
  background-color: var(--card-color);
  border: 2px solid var(--border-color);
  border-radius: 15px;
  margin-bottom: 1rem;
  padding: 1.2rem;
  transition: transform 0.2s, box-shadow 0.2s;
  position: relative;
  overflow: hidden;
}

li:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(240, 98, 146, 0.15);
}

li::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 5px;
  height: 100%;
  background-color: var(--primary-color);
  border-radius: 3px 0 0 3px;
}

li.completed {
  background-color: var(--completed-color);
  border-color: #80cbc4;
}

li.completed::before {
  background-color: #26a69a;
}

li.overdue {
  border-color: var(--overdue-color);
}

li.overdue::before {
  background-color: #e91e63;
}

.task-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.task-info {
  flex: 1;
}

.task-description {
  font-size: 1.1rem;
  margin-bottom: 0.5rem;
  color: var(--text-color);
  font-weight: 500;
}

.completion-badge {
  background-color: #26a69a;
  color: white;
  font-size: 0.7rem;
  padding: 0.2rem 0.5rem;
  border-radius: 10px;
  margin-left: 0.5rem;
  vertical-align: middle;
}

.task-due-date {
  color: var(--light-text);
  font-size: 0.9rem;
}

.text-strike {
  text-decoration: line-through;
  color: var(--light-text);
}

.overdue-text {
  color: #e91e63;
  font-weight: bold;
}

.task-actions {
  display: flex;
  gap: 0.8rem;
  align-items: center;
}

.btn-complete, .btn-delete {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 10px;
  cursor: pointer;
  font-size: 0.9rem;
  font-family: 'Quicksand', sans-serif;
  font-weight: 600;
  transition: background-color 0.3s, transform 0.2s;
}

.btn-complete {
  background-color: #66bb6a;
  color: white;
}

.btn-complete:hover {
  background-color: #43a047;
  transform: translateY(-2px);
}

.btn-delete {
  background-color: #ffcdd2;
  color: #c62828;
}

.btn-delete:hover {
  background-color: #ef9a9a;
  transform: translateY(-2px);
}

.app-footer {
  text-align: center;
  margin-top: 3rem;
  padding-top: 1.5rem;
  border-top: 2px solid var(--primary-light);
  color: var(--light-text);
  font-size: 0.9rem;
}

/* Mobile Responsiveness */
@media (max-width: 600px) {
  .container {
    padding: 1.5rem;
    margin: 1rem;
  }
  
  h1 {
    font-size: 2.2rem;
  }
  
  .task-item {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .task-actions {
    margin-top: 1rem;
    width: 100%;
    justify-content: flex-end;
  }
}

/* Add these styles to your existing <style> section */

.filters-container {
  margin: 2.5rem 0;
  text-align: center;
  padding: 1.5rem;
  background-color: #fef6fa;
  border-radius: 15px;
  border: 2px dashed var(--border-color);
  position: relative;
}

.filters-container h2 {
  margin-top: 0;
}

.filters {
  display: flex;
  justify-content: center;
  flex-wrap: wrap;
  gap: 0.8rem;
  margin: 1rem 0;
}

.filters button {
  display: flex;
  flex-direction: column;
  align-items: center;
  background-color: white;
  border: 2px solid var(--border-color);
  border-radius: 15px;
  padding: 0.8rem 1.2rem;
  cursor: pointer;
  font-family: 'Quicksand', sans-serif;
  font-weight: 600;
  color: var(--text-color);
  transition: all 0.3s ease;
  min-width: 90px;
  box-shadow: 0 3px 6px rgba(0, 0, 0, 0.05);
}

.filters button:hover {
  transform: translateY(-3px);
  box-shadow: 0 5px 15px rgba(240, 98, 146, 0.2);
  border-color: var(--primary-color);
}

.filters button.active {
  background: linear-gradient(135deg, var(--primary-color), var(--accent-color));
  color: white;
  border-color: transparent;
  box-shadow: 0 5px 15px rgba(240, 98, 146, 0.3);
}

.filter-icon {
  font-size: 1.5rem;
  margin-bottom: 0.5rem;
}

.filter-decoration {
  position: absolute;
  bottom: -10px;
  left: 50%;
  transform: translateX(-50%);
  width: 60px;
  height: 20px;
  background-color: white;
  border: 2px solid var(--border-color);
  border-radius: 50%;
  display: flex;
  justify-content: center;
  align-items: center;
}

.filter-decoration::before {
  content: '✨';
  font-size: 0.9rem;
}

@media (max-width: 600px) {
  .filters {
    flex-direction: row;
    overflow-x: auto;
    padding-bottom: 0.5rem;
    justify-content: flex-start;
  }
  
  .filters button {
    min-width: 80px;
    padding: 0.6rem 1rem;
  }
}

.edit-form {
  padding: 1rem;
  background-color: #fef6fa;
  border-radius: 10px;
}

.edit-buttons {
  display: flex;
  gap: 0.8rem;
  margin-top: 1rem;
}

.btn-save, .btn-cancel, .btn-edit {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 10px;
  cursor: pointer;
  font-size: 0.9rem;
  font-family: 'Quicksand', sans-serif;
  font-weight: 600;
  transition: all 0.3s ease;
}

.btn-save {
  background-color: #66bb6a;
  color: white;
}

.btn-save:hover {
  background-color: #43a047;
  transform: translateY(-2px);
}

.btn-cancel {
  background-color: #bdbdbd;
  color: white;
}

.btn-cancel:hover {
  background-color: #9e9e9e;
  transform: translateY(-2px);
}

.btn-edit {
  background-color: #ffb74d;
  color: #4a4a4a;
}

.btn-edit:hover {
  background-color: #ffa726;
  transform: translateY(-2px);
}
</style>
